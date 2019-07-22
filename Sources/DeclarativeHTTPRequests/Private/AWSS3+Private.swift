//
//  AWSS3+Private.swift
//  DeclarativeHTTPRequestsTests
//
//  Created by Andrew J Wagner on 7/21/19.
//

import Foundation
import CryptoSwift

extension AWSS3Endpoint {
    public func presignURL() throws -> URL {
        return try self.presignURL(for: Service.shared)
    }

    public func presignURL(for service: Service) throws -> URL {
        let (timestampString, dateString) = service.generateTimestamps()

        var params = try service.queryParams(queryBased: true, timestampString: timestampString, dateString: dateString)
        params.append(("X-Amz-Signature", try service.signature(queryBased: true, requestBody: Data(), timestampString: timestampString, dateString: dateString, endpoint: self)))

        let rawURL = service.baseURL.appendingPathComponent(self.path)
        guard var components = URLComponents(url: rawURL, resolvingAgainstBaseURL: false) else {
            throw RequestError.custom("invalid url generated")
        }

        components.queryItems = params.map({ URLQueryItem(name: $0, value: $1) })
        guard let url = components.url else {
            throw RequestError.custom("signing url because the result was not valid")
        }
        return url
    }
}

extension AWS.S3 {
    func generateTimestamps() -> (timestampString: String, dateString: String) {
        let timestampFormatter = DateFormatter()
        timestampFormatter.timeZone = TimeZone(identifier: "UTC")
        timestampFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = Date.now
        let timestampString = timestampFormatter.string(from: date)
        let dateString = dateFormatter.string(from: date)
        return (timestampString, dateString)
    }

    var host: String {
        return "\(self.bucket).s3.amazonaws.com"
    }

    var uri: String {
        return "http://\(self.host)"
    }

    func scope(dateString: String) -> String {
        return "\(dateString)/\(self.region)/s3/aws4_request"
    }

    func credentials(dateString: String) -> String {
        return "\(self.accessKey)/\(self.scope(dateString: dateString))"
    }

    func canonicalQueryString(params: [(String,String?)]) -> String {
        return params.map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? ""
            let encodedValue = value?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? ""
            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
    }

    func canonicalHeaders(headers: [(String,String?)]) throws -> String {
        return headers.map { key, value in
            return "\(key):\(value?.trimmingWhitespaceOnEnds ?? "")\n"
        }.joined()
    }

    func signedHeaders(queryBased: Bool) -> String {
        if queryBased {
            return "host"
        }
        else {
            return "host;x-amz-content-sha256;x-amz-date"
        }
    }

    func canonicalRequest<E: Endpoint>(queryBased: Bool, requestBody: Data, endpoint: E, timestampString: String, dateString: String) throws -> String {
        return """
        \(E.method.rawValue)
        \(endpoint.path)
        \(self.canonicalQueryString(params: try self.queryParams(queryBased: queryBased, timestampString: timestampString, dateString: dateString)))
        \(try self.canonicalHeaders(headers: try self.headers(queryBased: queryBased, requestBody: requestBody, timestampString: timestampString)))
        \(self.signedHeaders(queryBased: queryBased))
        \(queryBased ? "UNSIGNED-PAYLOAD" : self.contentHash(ofRequestBody: requestBody))
        """
    }

    func stringToSign<E: Endpoint>(queryBased: Bool, requestBody: Data, timestampString: String, dateString: String, endpoint: E) throws -> String {
        return """
        AWS4-HMAC-SHA256
        \(timestampString)
        \(self.scope(dateString: dateString))
        \(try self.canonicalRequest(queryBased: queryBased, requestBody: requestBody, endpoint: endpoint, timestampString: timestampString, dateString: dateString).sha256())
        """
    }

    func dateKey(dateString: String) throws -> Array<UInt8> {
        return try HMAC(key: "AWS4\(self.secretKey)".bytes, variant: .sha256)
            .authenticate(dateString.bytes)
    }

    func dateRegionKey(dateString: String) throws -> Array<UInt8> {
        return try HMAC(key: try self.dateKey(dateString: dateString), variant: .sha256)
            .authenticate(self.region.bytes)
    }

    func dateRegionServiceKey(dateString: String) throws -> Array<UInt8> {
        return try HMAC(key: try self.dateRegionKey(dateString: dateString), variant: .sha256)
            .authenticate("s3".bytes)
    }


    func signingKey(dateString: String) throws -> Array<UInt8> {
        return try HMAC(key: try self.dateRegionServiceKey(dateString: dateString), variant: .sha256)
            .authenticate("aws4_request".bytes)
    }

    func signature<E: Endpoint>(queryBased: Bool, requestBody: Data, timestampString: String, dateString: String, endpoint: E) throws -> String {
        return try HMAC(key: try self.signingKey(dateString: dateString), variant: .sha256)
            .authenticate(self.stringToSign(queryBased: queryBased, requestBody: requestBody, timestampString: timestampString, dateString: dateString, endpoint: endpoint).bytes).toHexString()
    }

    func authorization<E: Endpoint>(queryBased: Bool, requestBody: Data, timestampString: String, dateString: String, endpoint: E) throws -> String {
        var output = "AWS4-HMAC-SHA256"
        output += " Credential=\(self.credentials(dateString: dateString))"
        output += ", SignedHeaders=\(self.signedHeaders(queryBased: queryBased)), Signature="
        output += try self.signature(queryBased: false, requestBody: requestBody, timestampString: timestampString, dateString: dateString, endpoint: endpoint)
        return output
    }

    func contentHash(ofRequestBody body: Data) -> String {
        return body.sha256().toHexString()
    }

    func headers(queryBased: Bool, requestBody: Data, timestampString: String) throws -> [(String,String?)] {
        var headers: [(String,String?)] = [
            ("host", self.host),
        ]
        if !queryBased {
            headers.append(("x-amz-content-sha256", self.contentHash(ofRequestBody: requestBody)))
            headers.append(("x-amz-date", timestampString))
        }
        return headers
    }

    func queryParams(queryBased: Bool, timestampString: String, dateString: String) throws -> [(String,String?)] {
        if !queryBased {
            return []
        }
        else {
            return [
                ("X-Amz-Algorithm", "AWS4-HMAC-SHA256"),
                ("X-Amz-Credential", self.credentials(dateString: dateString)),
                ("X-Amz-Date", timestampString),
                ("X-Amz-Expires", "3600"),
                ("X-Amz-SignedHeaders", "host"),
            ]
        }
    }
}
