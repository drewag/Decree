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
    func makeRequest<E: Endpoint>(to endpoint: E, body: Data?, onComplete: @escaping (_ result: Result<Data?, Error>) -> ()) {
        do {
            let request = try self.createRequest(to: endpoint, body: body)
            let session = self.sessionOverride ?? URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    onComplete(.failure(error))
                    return
                }
                guard let response = response else {
                    onComplete(.failure(RequestError.noResponse))
                    return
                }
                do {
                    try self.validate(response, for: endpoint)

                    if BasicResponse.self != NoBasicResponse.self {
                        let basicResponse: BasicResponse = try self.parse(from: data)
                        try self.validate(basicResponse, for: endpoint)
                    }

                    onComplete(.success(data))
                }
                catch {
                    if BasicResponse.self != NoErrorResponse.self, let response: ErrorResponse = try? self.parse(from: data) {
                        onComplete(.failure(RequestError.parsed(response)))
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
    ///
    /// - Returns: encoded data
    func encode<Input: Encodable>(input: Input) throws -> Data {
        var encoder = JSONEncoder()
        do {
            try self.configure(&encoder)
            return try encoder.encode(input)
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
            throw RequestError.missingData
        }
        do {
            var decoder = JSONDecoder()
            try self.configure(&decoder)
            return try decoder.decode(Output.self, from: data)
        }
        catch let error as DecodingError {
            throw RequestError.decoding(typeName: "\(Output.self)", error)
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
    func createRequest<E: Endpoint>(to endpoint: E, body: Data?) throws -> URLRequest {
        let url = self.baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = E.method.rawValue
        request.httpBody = body

        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        try self.configure(&request)

        return request
    }
}
