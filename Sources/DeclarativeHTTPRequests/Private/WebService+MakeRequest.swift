//
//  WebService+MakeRequest.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation

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
    /// - Parameter onComplete: callback for when the request completes with the data returned
    func makeRequest<E: Endpoint>(to endpoint: E, input: RequestInput, onComplete: @escaping (_ result: Result<Data?, Error>) -> ()) {
        do {
            let request = try self.createRequest(to: endpoint, input: input)
            let session = self.sessionOverride ?? URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    onComplete(.failure(error))
                    return
                }
                guard let response = response else {
                    onComplete(.failure(ResponseError.noResponse))
                    return
                }
                do {
                    try self.automaticValidate(response, for: endpoint)
                    try self.validate(response, for: endpoint)

                    if !(BasicResponse.self is NoBasicResponse.Type) {
                        let basicResponse: BasicResponse = try self.parse(from: data)
                        try self.validate(basicResponse, for: endpoint)
                    }

                    onComplete(.success(data))
                }
                catch {
                    if ErrorResponse.self != NoErrorResponse.self
                        , let response: ErrorResponse = try? self.parse(from: data)
                    {
                        onComplete(.failure(ResponseError.parsed(response)))
                    }
                    else {
                        onComplete(.failure(error))
                    }
                }
            }
            task.resume()
        }
        catch {
            onComplete(.failure(error))
        }
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
        do {
            switch E.inputFormat {
            case .JSON:
                var encoder = JSONEncoder()
                try self.configure(&encoder)
                return .json(try encoder.encode(input))
            case .urlQuery:
                let encoder = KeyValueEncoder(codingPath: [])
                try input.encode(to: encoder)
                return .urlQuery(encoder.values.map { value in
                    return URLQueryItem(name: value.0, value: value.1)
                })
            case .formURLEncoded:
                let encoder = KeyValueEncoder(codingPath: [])
                try input.encode(to: encoder)
                let body = FormURLEncoder.encode(encoder.values)
                let data = body.data(using: .utf8) ?? Data()
                return .formURLEncoded(data)
            }
        }
        catch let error as EncodingError {
            throw RequestError.encoding(input, error)
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
    func parse<Output: Decodable>(from data: Data?) throws -> Output {
        guard let data = data else {
            throw ResponseError.missingData
        }
        do {
            var decoder = JSONDecoder()
            try self.configure(&decoder)
            return try decoder.decode(Output.self, from: data)
        }
        catch let error as DecodingError {
            throw ResponseError.decoding(typeName: "\(Output.self)", error)
        }
        catch {
            throw error
        }
    }
}

private extension WebService {
    /// Create the actual URLRequest
    ///
    /// The web service can do extra configuration on the request
    ///
    /// - Parameter endoint: endpoint to send the request to
    /// - Parameter body: http body of the request
    ///
    /// - Returns: the created request
    func createRequest<E: Endpoint>(to endpoint: E, input: RequestInput) throws -> URLRequest {
        guard var components = URLComponents(url: self.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw RequestError.custom("invalid url generated")
        }

        switch input {
        case .none, .json, .formURLEncoded:
            break
        case .urlQuery(let query):
            components.queryItems = query
        }

        guard let url = components.url else {
            throw RequestError.custom("invalid url components generated")
        }

        var request = URLRequest(url: url)
        request.httpMethod = E.method.rawValue

        switch input {
        case .none, .urlQuery:
            break
        case .json(let data):
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        case .formURLEncoded(let data):
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        }

        request.setValue("application/json", forHTTPHeaderField: "Accept")

        try self.configure(&request)

        return request
    }

    func automaticValidate<E: Endpoint>(_ response: URLResponse, for endpoint: E) throws {
        guard let response = response as? HTTPURLResponse else {
            return
        }

        switch response.statusCode {
        case let x where x >= 200 && x < 300:
            break

        case 300:
            throw ResponseError.multipleChoices
        case 301:
            throw ResponseError.movedPermanently
        case 302:
            throw ResponseError.found
        case 303:
            throw ResponseError.seeOther
        case 304:
            throw ResponseError.notModified
        case 305:
            throw ResponseError.useProxy
        case 307:
            throw ResponseError.temporaryRedirect

        case 400:
            throw ResponseError.badRequest
        case 401:
            throw ResponseError.unauthorized
        case 402:
            throw ResponseError.paymentRequired
        case 403:
            throw ResponseError.forbidden
        case 404:
            throw ResponseError.notFound
        case 405:
            throw ResponseError.methodNotAllowed
        case 406:
            throw ResponseError.notAcceptable
        case 407:
            throw ResponseError.proxyAuthenticationRequired
        case 408:
            throw ResponseError.requestTimeout
        case 409:
            throw ResponseError.conflict
        case 410:
            throw ResponseError.gone
        case 411:
            throw ResponseError.lengthRequired
        case 412:
            throw ResponseError.preconditionFailed
        case 413:
            throw ResponseError.requestEntityTooLarge
        case 414:
            throw ResponseError.requestURITooLong
        case 415:
            throw ResponseError.unsupportedMediaType
        case 416:
            throw ResponseError.requestedRangeNotSatisfiable
        case 417:
            throw ResponseError.expectationFailed

        case 500:
            throw ResponseError.internalServerError
        case 501:
            throw ResponseError.notImplemented
        case 502:
            throw ResponseError.badGateway
        case 503:
            throw ResponseError.serviceUnavailable
        case 504:
            throw ResponseError.gatewayTimeout
        case 505:
            throw ResponseError.httpVersionNotSupported
        default:
            throw ResponseError.otherStatus(response.statusCode)
        }
    }

}
