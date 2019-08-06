//
//  WebService+MakeRequest.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation
import XMLCoder

extension WebService {
    /// Make request to any endpoint
    ///
    /// This is the method used by all the speicalized endpoint methods.
    /// It handles creating and executing the task as well as parsing and
    /// validating the basic response.
    ///
    /// The web service can provde extra URLResponse and BasicResponse validation
    ///
    /// - Parameter endpoint: the endpoint for the request
    /// - Parameter body: http body the request
    /// - Parameter callbackQueue: Queue to execute the onComplete callback on. If nil, it will execute on the default queue from URLSession
    /// - Parameter onComplete: callback for when the request completes with the data returned
    func makeRequest<E: Endpoint>(to endpoint: E, input: RequestInput, callbackQueue: DispatchQueue?, onComplete: @escaping (_ result: Result<Data?, DecreeError>) -> ()) {
        self.doMakeRequest(to: nil, for: endpoint, input: input, callbackQueue: callbackQueue, onComplete: onComplete)
    }

    /// JSON encode the given input to data
    ///
    /// The web service can customize the configuration of the encoder
    ///
    /// - Parameter input: input to encode
    /// - Parameter endpoint: the endpoint the input is for
    ///
    /// - Returns: encoded data
    func encode<Input: Encodable, E: EndpointWithInput>(input: Input, for endpoint: E) throws -> RequestInput {
        guard Input.self != Data.self else {
            return .binary(input as! Data)
        }

        guard Input.self != String.self else {
            return .plainText((input as! String).data(using: .utf8) ?? Data())
        }

        do {
            switch E.inputFormat {
            case .JSON:
                var encoder = JSONEncoder()
                try self.configure(&encoder, for: endpoint)
                return .json(try encoder.encode(input))
            case .XML(let rootNode):
                var encoder = XMLEncoder()
                try self.configure(&encoder, for: endpoint)
                return .xml(try encoder.encode(input, withRootKey: rootNode))
            case .urlQuery:
                let encoder = KeyValueEncoder(codingPath: [])
                try input.encode(to: encoder)
                return .urlQuery(encoder.values.map { value in
                    switch value.1 {
                    case .string(let string):
                        return URLQueryItem(name: value.0, value: string)
                    case .none:
                        return URLQueryItem(name: value.0, value: nil)
                    case .data(let data):
                        return URLQueryItem(name: value.0, value: data.base64EncodedString())
                    case .file(let file):
                        return URLQueryItem(name: value.0, value: file.content.base64EncodedString())
                    case .bool(let bool):
                        return URLQueryItem(name: value.0, value: bool ? "true" : "false")
                    }
                })
            case .formURLEncoded:
                let encoder = KeyValueEncoder(codingPath: [])
                try input.encode(to: encoder)
                let body = FormURLEncoder.encode(encoder.values)
                let data = body.data(using: .utf8) ?? Data()
                return .formURLEncoded(data)
            case .formData:
                let encoder = KeyValueEncoder(codingPath: [])
                try input.encode(to: encoder)
                let data = FormDataEncoder.encode(encoder.values)
                return .formData(data)
            }
        }
        catch let error as EncodingError {
            throw endpoint.error(.encoding(input, error))
        }
        catch {
            throw error
        }
    }

    /// JSON decode output from data
    ///
    /// The web service can customize the configuration of the decoder
    ///
    /// - Parameter data: data to decode from
    ///
    /// - Returns: decoded output
    func parse<Output: Decodable, E: Endpoint>(from data: Data?, for endpoint: E) throws -> Output {
        guard let data = data, !data.isEmpty else {
            throw endpoint.error(.missingData)
        }
        guard Output.self != Data.self else {
            return data as! Output
        }
        guard Output.self != String.self else {
            guard let string = String(data: data, encoding: .utf8) else {
                throw DecreeError(.invalidOutputString, operationName: E.operationName)
            }
            return string as! Output
        }
        do {
            switch E.outputFormat {
            case .JSON:
                var decoder = JSONDecoder()
                try self.configure(&decoder, for: endpoint)
                return try decoder.decode(Output.self, from: data)
            case .XML:
                var decoder = XMLDecoder()
                try self.configure(&decoder, for: endpoint)
                return try decoder.decode(Output.self, from: data)
            }
        }
        catch let error as DecodingError {
            throw endpoint.error(.decoding(typeName: "\(Output.self)", error))
        }
        catch {
            throw error
        }
    }
}

private extension WebService {
    /// Make request to any endpoint
    ///
    /// This is the method used by all the speicalized endpoint methods.
    /// It handles creating and executing the task as well as parsing and
    /// validating the basic response.
    ///
    /// The web service can provde extra URLResponse and BasicResponse validation
    ///
    /// - Parameter endpoint: the endpoint for the request
    /// - Parameter body: http body the request
    /// - Parameter onComplete: callback for when the request completes with the data returned
    func doMakeRequest<E: Endpoint>(to url: URL?, for endpoint: E, input: RequestInput, callbackQueue: DispatchQueue?, onComplete: @escaping (_ result: Result<Data?, DecreeError>) -> ()) {
        do {
            let request: URLRequest
            if let url = url {
                request = try self.createRequest(to: url, for: endpoint, input: input)
            }
            else {
                request = try self.createRequest(to: endpoint, input: input)
            }

            let session = self.sessionOverride ?? URLSession.shared
            self.log(request, for: endpoint)
            let task = session.dataTask(with: request) { data, response, error in
                callbackQueue.async {
                    self.logResponse(data: data, response: response, error: error, for: endpoint)
                    if let error = error {
                        onComplete(.failure(DecreeError(other: error, for: endpoint)))
                        return
                    }
                    guard let response = response else {
                        onComplete(.failure(endpoint.error(.noResponse)))
                        return
                    }
                    do {
                        try self.automaticValidate(response, for: endpoint)
                        try self.validate(response, for: endpoint)

                        if !(BasicResponse.self is NoBasicResponse.Type) {
                            let basicResponse: BasicResponse = try self.parse(from: data, for: endpoint)
                            try self.validate(basicResponse, for: endpoint)
                        }

                        onComplete(.success(data))
                    }
                    catch {
                        self.handle(error, withResponse: response, data: data, endpoint: endpoint, withInput: input, callbackQueue: callbackQueue, onComplete: onComplete)
                    }
                }
            }
            task.resume()
        }
        catch {
            callbackQueue.async {
                onComplete(.failure(DecreeError(other: error, for: endpoint)))
            }
        }
    }

    func handle<E: Endpoint>(_ error: Error, withResponse response: URLResponse, data: Data?, endpoint: E, withInput input: RequestInput, callbackQueue: DispatchQueue?, onComplete: @escaping (_ result: Result<Data?, DecreeError>) -> ()) {
        let decreeError: DecreeError
        if ErrorResponse.self != NoErrorResponse.self
            , let parsed: ErrorResponse = try? self.parse(from: data, for: endpoint)
        {
            decreeError = endpoint.error(.parsed(parsed, original: error))
        }
        else {
            decreeError = DecreeError(other: error, for: endpoint)
        }

        switch self.handle(decreeError, response: response, from: endpoint) {
        case .error(let new):
            onComplete(.failure(new))
        case .redirect(let url):
            self.doMakeRequest(to: url, for: endpoint, input: input, callbackQueue: callbackQueue, onComplete: onComplete)
        }
    }

    /// Create the actual URLRequest
    ///
    /// The web service can do extra configuration on the r≥equest
    ///
    /// - Parameter endoint: endpoint to send the request to
    /// - Parameter body: http body of the request
    ///
    /// - Returns: the created request
    func createRequest<E: Endpoint>(to endpoint: E, input: RequestInput) throws -> URLRequest {
        let url = try self.createUrl(to: endpoint, input: input)
        return try self.createRequest(to: url, for: endpoint, input: input)
    }

    /// Create the actual URLRequest
    ///
    /// The web service can do extra configuration on the r≥equest
    ///
    /// - Parameter url: url to send the request to
    /// - Parameter endpoint: endpoint to send the request to
    /// - Parameter body: http body of the request
    ///
    /// - Returns: the created request
    func createRequest<E: Endpoint>(to url: URL, for endpoint: E, input: RequestInput) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = E.method.rawValue

        switch input {
        case .none, .urlQuery:
            break
        case .json(let data):
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        case .xml(let data):
            request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        case .plainText(let data):
            request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        case .binary(let data):
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        case .formURLEncoded(let data):
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        case .formData(let data):
            request.setValue("multipart/form-data; charset=utf-8; boundary=\(FormDataEncoder.boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        }

        switch E.outputFormat {
        case .JSON:
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        case .XML:
            request.setValue("text/xml", forHTTPHeaderField: "Accept")
        }

        switch E.authorizationRequirement {
        case .none:
            break
        case .optional:
            try self.addAuthorization(to: &request, isRequired: false, for: endpoint)
        case .required:
            try self.addAuthorization(to: &request, isRequired: true, for: endpoint)
        }

        try self.configure(&request, for: endpoint)

        return request
    }

    /// Create the URL to send the input to the given endpoint
    ///
    /// - Parameter endpoint: endpoint defining url path
    /// - Parameter input: the input to upload
    ///
    /// - Returns: the URL to send the input to
    func createUrl<E: Endpoint>(to endpoint: E, input: RequestInput) throws -> URL{
        var withoutQuery = self.baseURL
        if !endpoint.path.isEmpty {
            withoutQuery.appendPathComponent(endpoint.path)
        }

        guard var components = URLComponents(url: withoutQuery, resolvingAgainstBaseURL: false) else {
            throw endpoint.error(.custom("Invalid URL generated.", details: "The generate URL was '\(withoutQuery)'", isInternal: true))
        }

        switch input {
        case .none, .json, .formURLEncoded, .xml, .binary, .formData, .plainText:
            break
        case .urlQuery(let query):
            components.queryItems = query
        }

        guard let url = components.url else {
            throw endpoint.error(.custom("Invalid URL components generated.", details: "The components were '\(components.debugDescription)'", isInternal: true))
        }
        return url
    }

    func addAuthorization<E: Endpoint>(to request: inout URLRequest, isRequired: Bool, for endpoint: E) throws {
        switch self.authorization {
        case .none:
            if isRequired {
                throw endpoint.error(.unauthorized)
            }
        case let .basic(username, password):
            guard let base64Token = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
                throw endpoint.error(.custom("Invalid username and/or password for basic auth", details: "Username was '\(username)' and password was '\(password)'", isInternal: true))
            }
            request.setValue("Basic \(base64Token)", forHTTPHeaderField: "Authorization")
        case .bearer(let base64Token):
            request.setValue("Bearer \(base64Token)", forHTTPHeaderField: "Authorization")
        case .custom(let key, let value):
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    func automaticValidate<E: Endpoint>(_ response: URLResponse, for endpoint: E) throws {
        guard let response = response as? HTTPURLResponse else {
            return
        }

        switch response.statusCode {
        case let x where x >= 200 && x < 300:
            break
        default:
            let status = HTTPStatus(rawValue: response.statusCode)
            throw endpoint.error(.http(status))
        }
    }
}

// MARK: Logging

private extension WebService {
    func log<E: Endpoint>(_ request: URLRequest, for endpoint: E) {
        Logger.shared.logInfo("""
            --------------------------------------------------------------
            Making Decree Request to \(E.Service.self).\(E.self)
            \(request.logDescription)
            --------------------------------------------------------------
            """
            , for: endpoint
        )
    }

    func logResponse<E: Endpoint>(data: Data?, response: URLResponse?, error: Error?, for endpoint: E) {
        var log = """
            --------------------------------------------------------------
            Received Decree Response from \(E.Service.self).\(E.self)

            """

        if let error = error {
            log += "ERROR: \(error.localizedDescription)\n"
        }

        if let response = response {
            log += response.logDescription
        }
        else {
            log += "NO RESPONSE"
        }

        if let data = data {
            if let string = String(data: data, encoding: .utf8) {
                log += "\n\(string)"
            }
            else {
                log += "\n\(data)"
            }
        }

        log += "\n--------------------------------------------------------------"

        Logger.shared.logInfo(log, for: endpoint)
    }
}
