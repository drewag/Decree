//
//  DecreeRequest.swift
//  Decree
//
//  Created by Andrew J Wagner on 9/2/19.
//

import Foundation

class DecreeRequest<E: Endpoint, S: WebService> {
    enum Output {
        case data(Data)
        case url(URL)

        init?(_ data: Data?) {
            guard let data = data else {
                return nil
            }
            self = .data(data)
        }

        init?(_ url: URL?) {
            guard let url = url else {
                return nil
            }
            self = .url(url)
        }
    }

    let service: S

    let endpoint: E
    let input: RequestInput
    let callbackQueue: DispatchQueue?
    let onProgress: ((Double) -> ())?
    let onComplete: (_ result: Result<Output?, DecreeError>) -> ()

    var url: URL? = nil
    var progressObserver: AnyObject?

    init(for endpoint: E, of service: S, input: RequestInput, callbackQueue: DispatchQueue?, onProgress: ((Double) -> ())?, onComplete: @escaping (_ result: Result<Output?, DecreeError>) -> ()) {
        self.service = service
        self.endpoint = endpoint
        self.input = input
        self.callbackQueue = callbackQueue
        self.onProgress = onProgress
        self.onComplete = onComplete
    }

    func executeInMemory() {
        self.callbackQueue.async {
            self.onProgress?(0)
        }
        do {
            let request = try self.createRequest()

            let session = self.service.sessionOverride ?? URLSession.shared
            let task = session.execute(request, for: self.service, onComplete: { data, response, error in
                let output = Output(data)
                self.handleResponse(output, response: response, error: error)
            })
            self.observeProgress(of: task)
        }
        catch {
            callbackQueue.async {
                self.handleResult(.failure(DecreeError(other: error, for: self.endpoint)))
            }
        }
    }

    func executeToFile() {
        self.callbackQueue.async {
            self.onProgress?(0)
        }
        do {
            let request = try self.createRequest()

            let session = self.service.sessionOverride ?? URLSession.shared
            let task = session.executeDownload(request, for: self.service, onComplete: { url, response, error in
                let output = Output(url)
                self.handleResponse(output, response: response, error: error)
            })
            self.observeProgress(of: task)
        }
        catch {
            callbackQueue.async {
                self.handleResult(.failure(DecreeError(other: error, for: self.endpoint)))
            }
        }
    }
}

private extension Session {
    func execute<S: WebService>(_ request: URLRequest, for webService: S, onComplete: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTask? {
        for handlerSpec in AllRequestsHandlers {
            if handlerSpec.service is S.Type {
                let (data, response, error) = handlerSpec.handler.handle(dataRequest: request)
                onComplete(data, response, error)
                return nil
            }
        }
        let task = self.dataTask(with: request, completionHandler: onComplete)
        task.resume()
        return task
    }

    func executeDownload<S: WebService>(_ request: URLRequest, for webService: S, onComplete: @escaping (URL?, URLResponse?, Error?) -> ()) -> URLSessionDownloadTask? {
        for handlerSpec in AllRequestsHandlers {
            if handlerSpec.service is S.Type {
                let (url, response, error) = handlerSpec.handler.handle(downloadRequest: request)
                onComplete(url, response, error)
                return nil
            }
        }
        let task = self.downloadTask(with: request, completionHandler: onComplete)
        task.resume()
        return task
    }
}

// MARK: Request Creation

private extension DecreeRequest {
    func createRequest() throws -> URLRequest {
        let request: URLRequest
        if let url = url {
            request = try self.createRequest(to: url, for: endpoint, input: input)
        }
        else {
            request = try self.createRequest(to: endpoint, input: input)
        }
        self.log(request, for: self.endpoint)
        return request
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

        try self.service.configure(&request, for: endpoint)

        return request
    }

    /// Create the URL to send the input to the given endpoint
    ///
    /// - Parameter endpoint: endpoint defining url path
    /// - Parameter input: the input to upload
    ///
    /// - Returns: the URL to send the input to
    func createUrl<E: Endpoint>(to endpoint: E, input: RequestInput) throws -> URL{
        var withoutQuery = self.service.baseURL
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
        switch self.service.authorization {
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

// MARK: Progress Reporting

private extension DecreeRequest {
    func observeProgress(of task: URLSessionTask?) {
        #if canImport(ObjectiveC)
        if #available(iOS 11.0, OSX 10.13, tvOS 11.0, *) {
            if let task = task, let onProgress = onProgress {
                self.progressObserver = ProgressObserver(for: task, callbackQueue: callbackQueue, onChange: onProgress)
            }
        }
        #endif
    }
}

// MARK: Response handling

private extension DecreeRequest {
    func handleResponse(_ output: Output?, response: URLResponse?, error: Error?) {
        self.callbackQueue.async {
            self.logResponse(output: output, response: response, error: error, for: self.endpoint)
            if let error = error {
                self.handleResult(.failure(DecreeError(other: error, for: self.endpoint)))
                return
            }
            guard let response = response else {
                self.handleResult(.failure(self.endpoint.error(.noResponse)))
                return
            }
            do {
                try self.automaticValidate(response, for: self.endpoint)
                try self.service.validate(response, for: self.endpoint)

                if let output = output {
                    switch output {
                    case .data(let data):
                        if !(S.BasicResponse.self is NoBasicResponse.Type) {
                            let basicResponse: S.BasicResponse = try self.service.parse(from: data, for: self.endpoint)
                            try self.service.validate(basicResponse, for: self.endpoint)
                        }
                    case .url:
                        break
                    }
                }

                self.handleResult(.success(output))
            }
            catch {
                let handling = self.handle(error, withResponse: response, output: output, endpoint: self.endpoint)
                switch handling {
                case .error(let error):
                    self.handleResult(.failure(error))
                case .redirect(let url):
                    self.url = url
                    self.executeInMemory()
                }
            }
        }
    }

    /// WARNING: Must be called on callbackQueue
    func handleResult(_ result: Result<Output?, DecreeError>) {
        self.onProgress?(1)
        self.onComplete(result)
    }

    func handle<E: Endpoint>(_ error: Error, withResponse response: URLResponse, output: Output?, endpoint: E) -> ErrorHandling {
        let loadedData: Data?
        if let output = output {
            switch output {
            case .data(let data):
                loadedData = data
            case .url(let url):
                loadedData = try? Data(contentsOf: url)
            }
        }
        else {
            loadedData = nil
        }

        let decreeError: DecreeError
        if S.ErrorResponse.self != NoErrorResponse.self
            , let parsed: S.ErrorResponse = try? self.service.parse(from: loadedData, for: endpoint)
        {
            decreeError = endpoint.error(.parsed(parsed, original: error))
        }
        else {
            decreeError = DecreeError(other: error, for: endpoint)
        }

        return self.service.handle(decreeError, response: response, from: endpoint)
    }
}

// MARK: Logging

private extension DecreeRequest {
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

    func logResponse<E: Endpoint>(output: Output?, response: URLResponse?, error: Error?, for endpoint: E) {
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

        if let output = output {
            switch output {
            case .data(let data):
                if let string = String(data: data, encoding: .utf8) {
                    log += "\n\(string)"
                }
                else {
                    log += "\n\(data)"
                }
            case .url(let url):
                log += "\n\(url.relativePath)"
                log += "Note: This file is unlikely to still exist as it's only guaranteed to exist until the callback exits."
            }
        }

        log += "\n--------------------------------------------------------------"

        Logger.shared.logInfo(log, for: endpoint)
    }
}
