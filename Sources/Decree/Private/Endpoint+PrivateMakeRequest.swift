//
//  Endpoint+PrivateMakeRequest.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/24/19.
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
    func _makeRequest(to service: Service = Service.shared, callbackQueue: DispatchQueue? = DispatchQueue.main, onProgress: ((Double) -> ())? = nil, onComplete: @escaping (_ result: EmptyResult) -> ()) {
        if let mock = service.sessionOverride as? WebServiceMock<Service> {
            mock.handle(for: self, callbackQueue: callbackQueue, onComplete: onComplete)
            return
        }

        service.makeRequest(to: self, input: .none, callbackQueue: callbackQueue, onProgress: onProgress) { result in
            switch result {
            case .failure(let error):
                onComplete(.failure(error))
            case .success:
                onComplete(.success)
            }
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
    func _makeRequest(to service: Service = Service.shared, with input: Input, callbackQueue: DispatchQueue? = DispatchQueue.main, onProgress: ((Double) -> ())? = nil, onComplete: @escaping (_ result: EmptyResult) -> ()) {
        if let mock = service.sessionOverride as? WebServiceMock<Service> {
            mock.handle(for: self, input: input, callbackQueue: callbackQueue, onComplete: onComplete)
            return
        }

        do {
            let input = try service.encode(input: input, for: self)
            service.makeRequest(to: self, input: input, callbackQueue: callbackQueue, onProgress: onProgress) { result in
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
    func _makeRequest(to service: Service = Service.shared, callbackQueue: DispatchQueue? = DispatchQueue.main, onProgress: ((Double) -> ())? = nil, onComplete: @escaping (_ result: Result<Output, DecreeError>) -> ()) {
        if let mock = service.sessionOverride as? WebServiceMock<Service> {
            mock.handle(for: self, callbackQueue: callbackQueue, onComplete: onComplete)
            return
        }

        service.makeRequest(to: self, input: .none, callbackQueue: callbackQueue, onProgress: onProgress) { result in
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
    func _makeRequest(to service: Service = Service.shared, with input: Input, callbackQueue: DispatchQueue? = DispatchQueue.main, onProgress: ((Double) -> ())? = nil, onComplete: @escaping (_ error: Result<Output, DecreeError>) -> ()) {
        if let mock = service.sessionOverride as? WebServiceMock<Service> {
            mock.handle(for: self, input: input, callbackQueue: callbackQueue, onComplete: onComplete)
            return
        }

        do {
            let input = try service.encode(input: input, for: self)
            service.makeRequest(to: self, input: input, callbackQueue: callbackQueue, onProgress: onProgress) { result in
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
}

