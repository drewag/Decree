//
//  Endpoint+MakeRequest.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation

extension EmptyEndpoint {
    /// Make asynchronous request to this endpoint
    ///
    /// This is generally most appropriate in front-ends so that the interface remains reactive
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter callbackQueue: Queue to execute the onComplete callback on. If nil, it will execute on an unpredictable queue. Defaults to the main queue.
    /// - Parameter onComplete: Callback when the request is complete
    public func makeRequest(to service: Service = Service.shared, callbackQueue: DispatchQueue? = DispatchQueue.main, onComplete: @escaping (_ result: EmptyResult) -> ()) {
        service.makeRequest(to: self, input: .none, callbackQueue: callbackQueue) { result in
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
    /// This is generally most appropriate on back-ends to keep the handling of requests on the same thread
    ///
    /// - Parameter service: service to make the request to
    public func makeSynchronousRequest(to service: Service = Service.shared) throws {
        let semephore = DispatchSemaphore(value: 0)
        var result: EmptyResult?
        self.makeRequest(to: service, callbackQueue: nil) { output in
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

extension InEndpoint where Input: Encodable {
    /// Make asynchronous request to this endpoint
    ///
    /// This is generally most appropriate in front-ends so that the interface remains reactive
    ///
    /// **Important**: The Input must be Encodable
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter input: data to pass to endpoint
    /// - Parameter callbackQueue: Queue to execute the onComplete callback on. If nil, it will execute on an unpredictable queue. Defaults to the main queue.
    /// - Parameter onComplete: Callback when the request is complete
    public func makeRequest(to service: Service = Service.shared, with input: Input, callbackQueue: DispatchQueue? = DispatchQueue.main, onComplete: @escaping (_ result: EmptyResult) -> ()) {
        do {
            let input = try service.encode(input: input, for: self)
            service.makeRequest(to: self, input: input, callbackQueue: callbackQueue) { result in
                switch result {
                case .failure(let error):
                    onComplete(.failure(error))
                case .success:
                    onComplete(.success)
                }
            }
        }
        catch {
            callbackQueue.async {
                onComplete(.failure(DecreeError(other: error, for: self)))
            }
        }
    }

    /// Make synchronous request to this endpoint
    ///
    /// This is generally most appropriate on back-ends to keep the handling of requests on the same thread
    ///
    /// **Important**: The Input must be Encodable
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter input: data to pass to endpoint
    public func makeSynchronousRequest(to service: Service = Service.shared, with input: Input) throws {
        let semephore = DispatchSemaphore(value: 0)
        var result: EmptyResult?
        self.makeRequest(to: service, with: input, callbackQueue: nil) { output in
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

extension OutEndpoint where Output: Decodable {
    /// Make asynchronous request to this endpoint
    ///
    /// This is generally most appropriate in front-ends so that the interface remains reactive
    ///
    /// **Important**: The Output must be Decodable
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter callbackQueue: Queue to execute the onComplete callback on. If nil, it will execute on an unpredictable queue. Defaults to the main queue.
    /// - Parameter onComplete: Callback when the request is complete that includes output if successful
    public func makeRequest(to service: Service = Service.shared, callbackQueue: DispatchQueue? = DispatchQueue.main, onComplete: @escaping (_ result: Result<Output, DecreeError>) -> ()) {
        service.makeRequest(to: self, input: .none, callbackQueue: callbackQueue) { result in
            switch result {
            case .failure(let error):
                onComplete(.failure(error))
            case .success(let data):
                do {
                    onComplete(.success(try service.parse(from: data, for: self)))
                }
                catch {
                    onComplete(.failure(DecreeError(other: error, for: self)))
                }
            }
        }
    }

    /// Make synchronous request to this endpoint
    ///
    /// This is generally most appropriate on back-ends to keep the handling of requests on the same thread
    ///
    /// **Important**: The Output must be Decodable
    ///
    /// - Parameter service: service to make the request to
    ///
    /// - Returns: endpoint's output
    public func makeSynchronousRequest(to service: Service = Service.shared) throws -> Output {
        let semephore = DispatchSemaphore(value: 0)
        var result: Result<Output, DecreeError>?
        self.makeRequest(to: service, callbackQueue: nil) { output in
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

extension InOutEndpoint where Input: Encodable, Output: Decodable {
    /// Make Asynchronous Request to this endpoint
    ///
    /// This is generally most appropriate in front-ends so that the interface remains reactive
    ///
    /// **Important**: The Input must be Encodable and the Output must be Decodable
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter input: data to pass to endpoint
    /// - Parameter callbackQueue: Queue to execute the onComplete callback on. If nil, it will execute on an unpredictable queue. Defaults to the main queue.
    /// - Parameter onComplete: Callback when the request is complete that includes output if successful
    public func makeRequest(to service: Service = Service.shared, with input: Input, callbackQueue: DispatchQueue? = DispatchQueue.main, onComplete: @escaping (_ error: Result<Output, DecreeError>) -> ()) {
        do {
            let input = try service.encode(input: input, for: self)
            service.makeRequest(to: self, input: input, callbackQueue: callbackQueue) { result in
                switch result {
                case .failure(let error):
                    onComplete(.failure(error))
                case .success(let data):
                    do {
                        onComplete(.success(try service.parse(from: data, for: self)))
                    }
                    catch {
                        onComplete(.failure(DecreeError(other: error, for: self)))
                    }
                }
            }
        }
        catch {
            callbackQueue.async {
                onComplete(.failure(DecreeError(other: error, for: self)))
            }
        }
    }

    /// Make Asynchronous Request to this endpoint
    ///
    /// This is generally most appropriate on back-ends to keep the handling of requests on the same thread
    ///
    /// **Important**: The Input must be Encodable and the Output must be Decodable
    ///
    /// - Parameter service: service to make the request to
    /// - Parameter input: data to pass to endpoint
    ///
    /// - Returns: endpoint's output
    public func makeSynchronousRequest(to service: Service = Service.shared, with input: Input) throws -> Output {
        let semephore = DispatchSemaphore(value: 0)
        var result: Result<Output, DecreeError>?
        self.makeRequest(to: service, with: input, callbackQueue: nil) { output in
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
