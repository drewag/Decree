//
//  AWSS3.swift
//  Decree
//
//  Created by Andrew Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation

/// Protocol for AWS S3 Endpoints
public protocol AWSS3Endpoint: Endpoint where Service == AWS.S3 {
    /// Generate a signed URL using the shared service
    ///
    /// - Returns: A presigned URL that can be used to execute this request by a third party
    func presignURL() throws -> URL

    /// Generate a signed URL using given service
    ///
    /// - Parameter service: the serivce to use to generate this url
    ///
    /// - Returns: A presigned URL that can be used to execute this request by a third party
    func presignURL(for service: Service) throws -> URL
}

public struct AWS {
    /// Amazon S3 Web Service
    public struct S3: WebService {

        /// Get an object
        public struct GetObject: OutEndpoint, AWSS3Endpoint {
            public typealias Service = AWS.S3

            public typealias Output = Data
            public static let outputFormat = OutputFormat.XML

            public let path: String

            /// - Parameter name: the name of the object to get
            public init(name: String) {
                self.path = "/\(name)"
            }
        }

        /// Add an object
        public struct AddObject: InEndpoint, AWSS3Endpoint {
            public typealias Service = AWS.S3

            public static let method = Method.put

            public typealias Input = Data
            public static let outputFormat = OutputFormat.XML

            public let path: String

            /// - Parameter name: the name of the object to add
            public init(name: String) {
                self.path = "/\(name)"
            }
        }

        /// Delete an object
        public struct DeleteObject: EmptyEndpoint, AWSS3Endpoint {
            public typealias Service = AWS.S3

            public static let method = Method.delete

            public static let outputFormat = OutputFormat.XML

            public let path: String

            /// - Parameter name: the name of the object to delete
            public init(name: String) {
                self.path = "/\(name)"
            }
        }

        public struct ErrorResponse: AnyErrorResponse {
            public enum CodingKeys: String, CodingKey {
                case code = "Code", message = "Message", requestId = "RequestId"
            }

            public let code: ErrorCode
            public let message: String
            public let requestId: String
        }
        public typealias BasicResponse = NoBasicResponse

        public var sessionOverride: Session?

        let region: String
        let bucket: String
        let accessKey: String
        let secretKey: String

        /// Create a service for a specific bucket with authentication
        ///
        /// - Parameter region: bucket region e.g. "us-west-1"
        /// - Parameter bucket: the bucket name
        /// - Parameter accessKey: the access key you generated for this S3 bucket
        /// - Parameter secretKey: the secret key you generated for this S3 bucket
        public init(region: String, bucket: String, accessKey: String, secretKey: String) {
            self.region = region
            self.bucket = bucket
            self.accessKey = accessKey
            self.secretKey = secretKey
        }

        /// Customize this shared instance for your target bucket
        public static var shared = AWS.S3(region: "us-west1", bucket: "default", accessKey: "", secretKey: "")

        public var baseURL: URL {
            guard let url = URL(string: self.uri) else {
                return URL(string: "http://invalid")!
            }
            return url
        }

        public func configure<E: Endpoint>(_ request: inout URLRequest, for endpoint: E) throws {
            let (timestampString, dateString) = self.generateTimestamps()
            let authorization = try self.authorization(queryBased: false, requestBody: request.httpBody ?? Data(), timestampString: timestampString, dateString: dateString, endpoint: endpoint)
            request.setValue(authorization, forHTTPHeaderField: "Authorization")

            for (key, value) in try self.headers(queryBased: false, requestBody: request.httpBody ?? Data(), timestampString: timestampString) {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
}

extension AWS.S3 {
    /// Errors that S3 might return
    public enum ErrorCode: String, Decodable {
        case accountProblem = "AccountProblem"
        case allAccessDisabled = "AllAccessDisabled"
        case ambiguousGrantByEmailAddress = "AmbiguousGrantByEmailAddress"
        case authorizationHeaderMalformed = "AuthorizationHeaderMalformed"
        case badDigest = "BadDigest"
        case bucketAlreadyExists = "BucketAlreadyExists"
        case bucketAlreadyOwnedByYou = "BucketAlreadyOwnedByYou"
        case bucketNotEmpty = "BucketNotEmpty"
        case credentialsNotSupported = "CredentialsNotSupported"
        case crossLocationLoggingProhibited = "CrossLocationLoggingProhibited"
        case entityTooSmall = "EntityTooSmall"
        case entityTooLarge = "EntityTooLarge"
        case expiredToken = "ExpiredToken"
        case illegalVersioningConfigurationException = "IllegalVersioningConfigurationException"
        case incompleteBody = "IncompleteBody"
        case incorrectNumberOfFilesInPostRequest = "IncorrectNumberOfFilesInPostRequest"
        case inlineDataTooLarge = "InlineDataTooLarge"
        case internalError = "InternalError"
        case invalidAccessKeyId = "InvalidAccessKeyId"
        case invalidAddressingHeader = "InvalidAddressingHeader"
        case invalidArgument = "InvalidArgument"
        case invalidBucketName = "InvalidBucketName"
        case invalidBucketState = "InvalidBucketState"
        case invalidDigest = "InvalidDigest"
        case invalidEncryptionAlgorithmError = "InvalidEncryptionAlgorithmError"
        case invalidLocationConstraint = "InvalidLocationConstraint"
        case invalidObjectState = "InvalidObjectState"
        case invalidPart = "InvalidPart"
        case invalidPartOrder = "InvalidPartOrder"
        case invalidPayer = "InvalidPayer"
        case invalidPolicyDocument = "InvalidPolicyDocument"
        case invalidRange = "InvalidRange"
        case invalidRequest = "InvalidRequest"
        case invalidSecurity = "InvalidSecurity"
        case invalidSOAPRequest = "InvalidSOAPRequest"
        case invalidStorageClass = "InvalidStorageClass"
        case invalidTargetBucketForLogging = "InvalidTargetBucketForLogging"
        case invalidToken = "InvalidToken"
        case invalidURI = "InvalidURI"
        case keyTooLongError = "KeyTooLongError"
        case malformedACLError = "MalformedACLError"
        case malformedPOSTRequest = "MalformedPOSTRequest"
        case malformedXML = "MalformedXML"
        case maxMessageLengthExceeded = "MaxMessageLengthExceeded"
        case maxPostPreDataLengthExceededError = "MaxPostPreDataLengthExceededError"
        case metadataTooLarge = "MetadataTooLarge"
        case methodNotAllowed = "MethodNotAllowed"
        case missingAttachment = "MissingAttachment"
        case missingContentLength = "MissingContentLength"
        case missingRequestBodyError = "MissingRequestBodyError"
        case missingSecurityElement = "MissingSecurityElement"
        case missingSecurityHeader = "MissingSecurityHeader"
        case noLoggingStatusForKey = "NoLoggingStatusForKey"
        case noSuchBucket = "NoSuchBucket"
        case noSuchBucketPolicy = "NoSuchBucketPolicy"
        case noSuchKey = "NoSuchKey"
        case noSuchLifecycleConfiguration = "NoSuchLifecycleConfiguration"
        case noSuchUpload = "NoSuchUpload"
        case noSuchVersion = "NoSuchVersion"
        case notImplemented = "NotImplemented"
        case notSignedUp = "NotSignedUp"
        case operationAborted = "OperationAborted"
        case permanentRedirect = "PermanentRedirect"
        case preconditionFailed = "PreconditionFailed"
        case redirect = "Redirect"
        case restoreAlreadyInProgress = "RestoreAlreadyInProgress"
        case requestIsNotMultiPartContent = "RequestIsNotMultiPartContent"
        case requestTimeout = "RequestTimeout"
        case requestTimeTooSkewed = "RequestTimeTooSkewed"
        case requestTorrentOfBucketError = "RequestTorrentOfBucketError"
        case signatureDoesNotMatch = "SignatureDoesNotMatch"
        case serviceUnavailable = "ServiceUnavailable"
        case slowDown = "SlowDown"
        case temporaryRedirect = "TemporaryRedirect"
        case tokenRefreshRequired = "TokenRefreshRequired"
        case tooManyBuckets = "TooManyBuckets"
        case unexpectedContent = "UnexpectedContent"
        case unresolvableGrantByEmailAddress = "UnresolvableGrantByEmailAddress"
        case userKeyMustBeSpecified = "UserKeyMustBeSpecified"
        case serverSideEncryptionConfigurationNotFoundError = "ServerSideEncryptionConfigurationNotFoundError"
    }
}
