//
//  Endpoint+MakeRequest.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation

extension EmptyEndpoint {
    /// Make asynchronous request to this endpoint
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter onComplete: Callback when the request is complete
    public func makeRequest(to service: Service = Service.shared, onComplete: @escaping (_ result: EmptyResult) -> ()) {
        service.makeRequest(to: self, body: nil) { result in
            switch result {
            case .failure(let error):
                onComplete(.failure(error))
            case .success:
                onComplete(.success)
            }
        }
    }

    /// Make synchronous request to this endpoint
    ///
    /// - Parameter service: service to make the request to
    public func makeSynchronousRequest(to service: Service = Service.shared) throws {
        let semephore = DispatchSemaphore(value: 0)
        var result: EmptyResult?
        self.makeRequest(to: service) { output in
            result = output
            semephore.signal()
        }
        semephore.wait()

        switch result! {
        case .success:
            break
        case .failure(let error):
            throw error
        }
    }
}
extension InEndpoint {
    /// Make asynchronous request to this endpoint
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter input: data to pass to endpoint
    /// - Parameter onComplete: Callback when the request is complete
    public func makeRequest(to service: Service = Service.shared, with input: Input, onComplete: @escaping (_ result: EmptyResult) -> ()) {
        do {
            let body = try service.encode(input: input)
            service.makeRequest(to: self, body: body) { result in
                switch result {
                case .failure(let error):
                    onComplete(.failure(error))
                case .success:
                    onComplete(.success)
                }
            }
        }
        catch {
            onComplete(.failure(error))
        }
    }

    /// Make synchronous request to this endpoint
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter input: data to pass to endpoint
    public func makeSynchronousRequest(to service: Service = Service.shared, with input: Input) throws {
        let semephore = DispatchSemaphore(value: 0)
        var result: EmptyResult?
        self.makeRequest(to: service, with: input) { output in
            result = output
            semephore.signal()
        }
        semephore.wait()

        switch result! {
        case .success:
            break
        case .failure(let error):
            throw error
        }
    }
}
extension OutEndpoint {
    /// Make asynchronous request to this endpoint
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter onComplete: Callback when the request is complete that includes output if successful
    public func makeRequest(to service: Service = Service.shared, onComplete: @escaping (_ result: Result<Output, Error>) -> ()) {
        service.makeRequest(to: self, body: nil) { result in
            switch result {
            case .failure(let error):
                onComplete(.failure(error))
            case .success(let data):
                do {
                    onComplete(.success(try service.parse(from: data)))
                }
                catch {
                    onComplete(.failure(error))
                }
            }
        }
    }

    /// Make synchronous request to this endpoint
    ///
    /// - Parameter service: service to make the request to
    ///
    /// - Returns: endpoint's output
    public func makeSynchronousRequest(to service: Service = Service.shared) throws -> Output {
        let semephore = DispatchSemaphore(value: 0)
        var result: Result<Output, Error>?
        self.makeRequest(to: service) { output in
            result = output
            semephore.signal()
        }
        semephore.wait()

        switch result! {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        }
    }
}
extension InOutEndpoint {
    /// Make Asynchronous Request to this endpoint
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter input: data to pass to endpoint
    /// - Parameter onComplete: Callback when the request is complete that includes output if successful
    public func makeRequest(to service: Service = Service.shared, with input: Input, onComplete: @escaping (_ error: Result<Output, Error>) -> ()) {
        do {
            let body = try service.encode(input: input)
            service.makeRequest(to: self, body: body) { result in
                switch result {
                case .failure(let error):
                    onComplete(.failure(error))
                case .success(let data):
                    do {
                        onComplete(.success(try service.parse(from: data)))
                    }
                    catch {
                        onComplete(.failure(error))
                    }
                }
            }
        }
        catch {
            onComplete(.failure(error))
        }
    }

    /// Make Asynchronous Request to this endpoint
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter input: data to pass to endpoint
    ///
    /// - Returns: endpoint's output
    public func makeSynchronousRequest(to service: Service = Service.shared, with input: Input) throws -> Output {
        let semephore = DispatchSemaphore(value: 0)
        var result: Result<Output, Error>?
        self.makeRequest(to: service, with: input) { output in
            result = output
            semephore.signal()
        }
        semephore.wait()

        switch result! {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        }
    }
}
