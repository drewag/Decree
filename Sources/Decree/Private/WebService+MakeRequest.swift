//
//  WebService+MakeRequest.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation
import XMLCoder

var AllRequestsHandlers = [(service: Any, handler: RequestHandler)]()

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
    func makeRequest<E: Endpoint>(to endpoint: E, input: RequestInput, callbackQueue: DispatchQueue?, onProgress: ((Double) -> ())?, onComplete: @escaping (_ result: Result<Data?, DecreeError>) -> ()) {
        let request = DecreeRequest(for: endpoint, of: self, input: input, callbackQueue: callbackQueue, onProgress: onProgress, onComplete: { result in
            switch result {
            case .failure(let error):
                onComplete(.failure(error))
            case .success(let output):
                if let output = output {
                    switch output {
                    case .data(let data):
                        onComplete(.success(data))
                    case .url:
                        fatalError("Should not get here because this request is being made in memory")
                    }
                }
                else {
                    onComplete(.success(nil))
                }
            }
        })
        request.executeInMemory()
    }

    func makeDownloadRequest<E: Endpoint>(to endpoint: E, input: RequestInput, callbackQueue: DispatchQueue?, onProgress: ((Double) -> ())?, onComplete: @escaping (_ result: Result<URL, DecreeError>) -> ()) {
        let request = DecreeRequest(for: endpoint, of: self, input: input, callbackQueue: callbackQueue, onProgress: onProgress, onComplete: { result in
            switch result {
            case .failure(let error):
                onComplete(.failure(error))
            case .success(let output):
                guard let output = output else {
                    onComplete(.failure(endpoint.error(.missingUrl)))
                    return
                }
                switch output {
                case .data:
                    fatalError("Should not get here because this request is being made to a file")
                case .url(let url):
                    onComplete(.success(url))
                }
            }
        })
        request.executeToFile()
    }
}

// MARK: Coding

extension WebService {
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
                var encoder = KeyValueEncoder(codingPath: [])
                try self.configure(&encoder, for: endpoint)
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
                var encoder = KeyValueEncoder(codingPath: [])
                try self.configure(&encoder, for: endpoint)
                try input.encode(to: encoder)
                let body = FormURLEncoder.encode(encoder.values)
                let data = body.data(using: .utf8) ?? Data()
                return .formURLEncoded(data)
            case .formData:
                var encoder = KeyValueEncoder(codingPath: [])
                try self.configure(&encoder, for: endpoint)
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
