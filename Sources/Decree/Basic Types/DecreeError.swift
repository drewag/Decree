//
//  RequestError.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation

/// Errors thrown and returned by Decree
///
/// They are designed to be user friendly while also exposing detailed diagnostic information.
///
/// Each error includes the following.
///
/// # User Friendly
/// - A **description** for a single, baisc, and user friendly description of what when wrong
/// - A **title** for a very short description of what went wrong (appropriate for error alert titles)
/// - An **alertMessage** for a message to be displayed in an aerror alert
///
/// If an error is determined to be an internal error, the user friendly properties include a message to
/// the user about contacting support: 'An internal error has occured. If it continues, please contact
/// support with the description "<description>"'
///
/// # Diagnostic
/// - A **code** for progamatically analyzing the error that occured
/// - A **reason** a medium length description of the reason for the error
/// - A **description** a more detailed description of the reason for the error
/// - A **debugDescription** for full description of the reason for the error
public struct DecreeError: LocalizedError, CustomStringConvertible, CustomDebugStringConvertible {
    /// Error codes
    ///
    /// Check `description` and `details` on error for detailed information about each code
    public enum Code {
        // MARK: Requests

        /// Failure to encode
        case encoding(Encodable, EncodingError)

        /// The endpoint required authorization but there was none
        case unauthorized

        // MARK: Responses

        /// No response was returned
        case noResponse

        /// No data was returned
        case missingData

        /// Failure to decode
        case decoding(typeName: String, DecodingError)

        /// The endpoint's ErrorResponse was successfully parsed.
        /// Also includes the original error thrown to cause the parsing
        /// of ErrorResponse.
        case parsed(AnyErrorResponse, original: Error)

        /// A bad HTTP status was returned
        case http(HTTPStatus)

        /// An NSURLError was thrown
        case urlError(code: Int)

        /// The response body was an invalid string when the Output was set to a String
        case invalidOutputString

        // MARK: Other

        /// A different Error was thrown
        case other(Error)

        /// A custom error was thrown
        case custom(String, details: String?, isInternal: Bool)

        // MARK: Mocking

        /// A request was made to an endpoint during mocking that was not expected
        case unexpectedEndpoint(String)

        /// A request was made to an endpoint when a different endpoint was expected
        case incorrectExpecation(expected: String, actual: String)

        /// A request was made to the wrong path
        case incorrectExpectationPath(expected: String, actual: String, endpoint: String)

        /// A request was made with unexpected input
        case unexpectedInput(expected: Any, actual: Any, valuePath: String, endpoint: String)
    }

    /// Classificaiton for the type of error
    public let code: Code

    /// What operation was being attempted when this error was thrown
    public let operationName: String?

    /// Short name for the error (good for alert tiels)
    public var title: String {
        guard let operationName = self.operationName else {
            return "Error making request"
        }

        return "Error \(operationName.titleCased)"
    }

    /// Message to be displayed in an alert
    public var alertMessage: String {
        if isInternal {
            return "An internal error has occured. If it continues, please contact support with the description \"\(self.reason)\""
        }
        else {
            return self.reason
        }
    }

    /// Medium length description of the reason for the error
    public var reason: String {
        switch self.code {
        case .unauthorized:
            return "You are not logged in."
        case .encoding(let value, _):
            return "Failed to encode \(value)."
        case .noResponse:
            return "No response returned."
        case .missingData:
            return "No data returned."
        case .decoding(let typeName, _):
            return "Failed to decode \(typeName)."
        case .parsed(let parsed, _):
            return parsed.message
        case .http(let status):
            switch status {
            // Specifics
            case .gone:
                return "This app is out of date. Please update to the latest version."
            case .unauthorized, .forbidden:
                return "You are not authorized."
            case .badGateway:
                return "The web server appears to be down."

            // Catch Alls
            case .other(let other):
                return "Unrecognized HTTP error: \(other)"
            default:
                return "HTTP error: \(status.rawValue) \(status.description)"
            }
        case .urlError(let code):
            return self.reason(forUrlErrorCode: code)
        case .other(let error):
            return "\(error)"
        case .custom(let message, _, _):
            return message
        case .invalidOutputString:
            return "The response body was invalid text."
        case .unexpectedEndpoint(let endpoint):
            return "A request was made to ‘\(endpoint)’ during mocking that was not expected."
        case .incorrectExpecation(let expected, let actual):
            return "A request was made to ‘\(actual)’ when ‘\(expected)’ was expected."
        case .incorrectExpectationPath(_, _, let endpoint):
            return "A request was made to the wrong path of ‘\(endpoint)’."
        case .unexpectedInput(_, _, _, let endpoint):
            return "A request was made to ‘\(endpoint)’ with unexpected input."
        }
    }

    /// Detailed description of the reason for the error
    public var details: String? {
        switch self.code {
        case .unauthorized:
            return nil
        case .encoding(_, let encodingError):
            var details = ""

            switch encodingError {
            case .invalidValue(let value, let context):
                details += "Invalid Value: \(value)"
                details += "\nKey Path: " + context.codingPath.map({$0.stringValue}).joined(separator: ".")
                details += "\nDebug Description: \(context.debugDescription)"
                if let error = context.underlyingError {
                    details += "\nUnderyling Error: \(error)"
                }
            @unknown default:
                details += "Unrecognized Encoding Error"
                details += "Description: \(encodingError.localizedDescription)"
            }

            details += "\n\nDebugging: To see raw requests and responses, turn on logging with `Logger.shared.level = .info(filter: nil)`."
            return details
        case .noResponse:
            return "The data task did not return an error, but it also didn't return a response."
        case .missingData:
            return "The data task did not return an error, but it also didn't return any data."
        case .decoding(let typeName, let decodingError):
            var details = ""

            func add(_ context: DecodingError.Context) {
                details += "\nKey Path: " + context.codingPath.map({$0.stringValue}).joined(separator: ".")
                details += "\nDebug Description: \(context.debugDescription)"
                if let error = context.underlyingError {
                    details += "\nUnderyling Error: \(error)"
                }
            }

            switch decodingError {
            case .dataCorrupted(let context):
                details += "\(typeName) Data Corrupted"
                add(context)
            case .keyNotFound(let key, let context):
                details += "Key not found for \(key.stringValue)"
                add(context)
            case .typeMismatch(let type, let context):
                details += "Type mismatch for \(type)"
                add(context)
            case .valueNotFound(let type, let context):
                details += "Value not found for \(type)"
                add(context)
            @unknown default:
                details += "Unrecognized Decoding Error"
                details += "Description: \(decodingError.localizedDescription)"
            }

            details += "\n\nDebugging: To see raw requests and responses, turn on logging with `Logger.shared.level = .info(filter: nil)`."
            return details
        case .parsed(let parsed, let original):
            if let original = original as? DecreeError {
                if let details = original.details {
                    return """
                        Parsed: \(parsed)
                        Original: \(original.reason)
                        \(details)
                        """
                }
                else {
                    return """
                        Parsed: \(parsed)
                        Original: \(original.reason)
                        """
                }
            }
            else {
                return """
                    Parsed: \(parsed)
                    Original: \(original)
                    """
            }
        case .http(let status):
            switch status {
            // Specifics
            case .gone, .unauthorized, .forbidden, .badGateway:
                return "HTTP error: \(status.rawValue) \(status.description)"

            // Catch Alls
            default:
                return nil
            }
        case .urlError(let code):
            return self.details(forUrlErrorCode: code)
        case .other(let error):
            let nsError = error as NSError
            var output = "\(nsError.domain) \(nsError.code)"

            if let reason = nsError.localizedFailureReason {
                output += "\nFailure Reason: \(reason)"
            }

            if let suggestion = nsError.localizedRecoverySuggestion {
                output += "\nRecovery Suggestion: \(suggestion)"
            }

            if !nsError.userInfo.isEmpty {
                output += "\nUser Info:"
                for (key, value) in nsError.userInfo {
                    output += "\n    \(key): \(value)"
                }
            }

            return output
        case .custom(_, let description, _):
            return description
        case .invalidOutputString:
            return nil
        case .unexpectedEndpoint:
            return nil
        case .incorrectExpecation:
            return nil
        case .incorrectExpectationPath(let expected, let actual, _):
            return "Path was ‘\(actual)’ but expected ‘\(expected)‘."
        case .unexpectedInput(let expected, let actual, let path, _):
            if path.isEmpty {
                return "Got ‘\(actual)’ but expected ‘\(expected)’. A difference was found at the root."
            }
            else {
                return "Got ‘\(actual)’ but expected ‘\(expected)’. A difference was found at the path ‘\(path)‘."
            }
        }
    }

    /// False if this error was caused by the end user
    ///
    /// If true, the message will include a request to report the bug if
    /// it continues to occur.
    public var isInternal: Bool {
        switch self.code {
        case .unauthorized:
            return false
        case .encoding:
            return true
        case .noResponse, .missingData, .decoding:
            return true
        case .parsed(let parsed, _):
            return parsed.isInternal
        case .http(let status):
            switch status {
            // Specifics
            case .gone, .unauthorized, .forbidden, .badGateway:
                return false

            // Catch Alls
            default:
                return true
            }
        case .urlError(let code):
            return self.isInternal(forUrlErrorCode: code)
        case .other:
            return true
        case .custom(_, _, let isInternal):
            return isInternal
        case .invalidOutputString:
            return true
        case .unexpectedEndpoint, .incorrectExpecation, .incorrectExpectationPath, .unexpectedInput:
            return false
        }
    }

    /// Create a DecreeError
    ///
    /// - Parameters:
    ///     - code: The code designation for this error
    ///     - operationName: Optional name for what was being attempted when error was created
    public init(_ code: Code, operationName: String? = nil) {
        self.code = code
        self.operationName = operationName
    }

    init<E: Endpoint>(other error: Error, for endpoint: E) {
        if let error = error as? DecreeError {
            self = error
            return
        }

        if (error as NSError).domain == NSURLErrorDomain {
            self = .init(.urlError(code: (error as NSError).code), operationName: E.operationName)
            return
        }

        self.init(.other(error), operationName: E.operationName)
    }
}

extension Endpoint {
    func error(_ code: DecreeError.Code) -> DecreeError {
        return DecreeError(code, operationName: Self.operationName)
    }
}

extension DecreeError {
    public var errorDescription: String? {
        return self.description
    }

    public var description: String {
        let title: String
        if let operationName = self.operationName {
            title = "Error \(operationName.lowercased())"
        }
        else {
            title = "Error making request"
        }

        return "\(title): \(alertMessage)"
    }

    public var debugDescription: String {
        let basic = "\(title): \(alertMessage)"

        guard let details = self.details else {
            return basic
        }

        return "\(basic)\n\(details)"
    }
}

extension DecreeError {
    func reason(forUrlErrorCode code: Int) -> String {
        switch code {
        case NSURLErrorBackgroundSessionWasDisconnected, NSURLErrorNetworkConnectionLost:
            return "Your internet connection was lost. Please make sure your internet is working and try again. If it continues to happen, please reach out to support."
        case NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost, NSURLErrorDNSLookupFailed:
            return "The web server appears to be down. Please try again later."
        case NSURLErrorClientCertificateRejected, NSURLErrorSecureConnectionFailed, NSURLErrorServerCertificateHasUnknownRoot, NSURLErrorServerCertificateNotYetValid, NSURLErrorServerCertificateUntrusted:
            return "The web server can no longer be trusted. Please update to the latest version of this app."
        case NSURLErrorNotConnectedToInternet:
            return "You're not connected to the internet."
        case NSURLErrorTimedOut:
            return "The request timed out. Please try again."
        case NSURLErrorUserAuthenticationRequired, NSURLErrorUserCancelledAuthentication:
            return "You are not authorized."
        default:
            return "NSURLError \(code)"
        }
    }

    func details(forUrlErrorCode code: Int) -> String? {
        switch code {
        case NSURLErrorBackgroundSessionInUseByAnotherProcess:
            return "An app or app extension attempted to connect to a background session that is already connected to a process."
        case NSURLErrorBackgroundSessionRequiresSharedContainer:
            return "The shared container identifier of the URL session configuration is needed but hasn’t been set."
        case NSURLErrorBackgroundSessionWasDisconnected:
            return "The app is suspended or exits while a background data task is processing."
        case NSURLErrorBadServerResponse:
            return "The URL Loading System received bad data from the server."
        case NSURLErrorBadURL:
            return "A malformed URL prevented a URL request from being initiated."
        case NSURLErrorCallIsActive:
            return "A connection was attempted while a phone call was active on a network that doesn’t support simultaneous phone and data communication, such as EDGE or GPRS."
        case NSURLErrorCancelled:
            return "An asynchronous load has been canceled."
        case NSURLErrorCannotCloseFile:
            return "A download task couldn’t close the downloaded file on disk."
        case NSURLErrorCannotConnectToHost:
            return "An attempt to connect to a host failed."
        case NSURLErrorCannotCreateFile:
            return "A download task couldn’t create the downloaded file on disk because of an I/O failure."
        case NSURLErrorCannotDecodeContentData:
            return "Content data received during a connection request had an unknown content encoding."
        case NSURLErrorCannotDecodeRawData:
            return "Content data received during a connection request couldn’t be decoded for a known content encoding."
        case NSURLErrorCannotFindHost:
            return "The host name for a URL couldn’t be resolved."
        case NSURLErrorCannotLoadFromNetwork:
            return "A specific request to load an item only from the cache couldn't be satisfied."
        case NSURLErrorCannotMoveFile:
            return "A downloaded file on disk couldn’t be moved."
        case NSURLErrorCannotOpenFile:
            return "A downloaded file on disk couldn’t be opened."
        case NSURLErrorCannotParseResponse:
            return "A response to a connection request couldn’t be parsed."
        case NSURLErrorCannotRemoveFile:
            return "A downloaded file couldn’t be removed from disk."
        case NSURLErrorCannotWriteToFile:
            return "A download task couldn’t write the file to disk."
        case NSURLErrorClientCertificateRejected:
            return "A server certificate was rejected."
        case NSURLErrorClientCertificateRequired:
            return "A client certificate was required to authenticate an SSL connection during a connection request."
        case NSURLErrorDNSLookupFailed:
            return "The host address couldn’t be found via DNS lookup."
        case NSURLErrorDataLengthExceedsMaximum:
            return "The length of the resource data exceeded the maximum allowed."
        case NSURLErrorDataNotAllowed:
            return "The cellular network disallowed a connection."
        case NSURLErrorDownloadDecodingFailedMidStream:
            return "A download task failed to decode an encoded file during the download."
        case NSURLErrorDownloadDecodingFailedToComplete:
            return "A download task failed to decode an encoded file after downloading."
        case NSURLErrorFileDoesNotExist:
            return "The specified file doesn’t exist."
        case NSURLErrorFileIsDirectory:
            return "A request for an FTP file resulted in the server responding that the file is not a plain file, but a directory."
        case NSURLErrorHTTPTooManyRedirects:
            return "A redirect loop was detected or the threshold for number of allowable redirects was exceeded."
        case NSURLErrorInternationalRoamingOff:
            return "The attempted connection required activating a data context while roaming, but international roaming is disabled."
        case NSURLErrorNetworkConnectionLost:
            return "A client or server connection was severed in the middle of an in-progress load."
        case NSURLErrorNoPermissionsToReadFile:
            return "A resource couldn’t be read because of insufficient permissions."
        case NSURLErrorNotConnectedToInternet:
            return "A network resource was requested, but an internet connection has not been established and can’t be established automatically."
        case NSURLErrorRedirectToNonExistentLocation:
            return "A redirect was specified by way of server response code, but the server didn’t accompany this code with a redirect URL."
        case NSURLErrorRequestBodyStreamExhausted:
            return "A body stream was needed but the client did not provide one."
        case NSURLErrorResourceUnavailable:
            return "A requested resource couldn’t be retrieved."
        case NSURLErrorSecureConnectionFailed:
            return "An attempt to establish a secure connection failed for reasons that can’t be expressed more specifically."
        case NSURLErrorServerCertificateHasBadDate:
            return "A server certificate is expired, or is not yet valid."
        case NSURLErrorServerCertificateHasUnknownRoot:
            return "A server certificate wasn’t signed by any root server."
        case NSURLErrorServerCertificateNotYetValid:
            return "A server certificate isn’t valid yet."
        case NSURLErrorServerCertificateUntrusted:
            return "A server certificate was signed by a root server that isn’t trusted."
        case NSURLErrorTimedOut:
            return "An asynchronous operation timed out."
        case NSURLErrorUnsupportedURL:
            return "A properly formed URL couldn’t be handled by the framework."
        case NSURLErrorUserAuthenticationRequired:
            return "Authentication was required to access a resource."
        case NSURLErrorUserCancelledAuthentication:
            return "An asynchronous request for authentication has been canceled by the user."
        case NSURLErrorZeroByteResource:
            return "A server reported that a URL has a non-zero content length, but terminated the network connection gracefully without sending any data."
        default:
            if #available(iOS 9.0, macOS 10.11, *), code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
                return "App Transport Security disallowed a connection because there is no secure network connection."
            }
            #if os(iOS) || os(macOS)
                if #available(iOS 10.3, macOS 10.12.4, *), code == NSURLErrorFileOutsideSafeArea {
                    return "An internal file operation failed."
                }
            #endif
            return nil
        }
    }

    func isInternal(forUrlErrorCode code: Int) -> Bool {
        switch code {
        case NSURLErrorBackgroundSessionInUseByAnotherProcess:
            return true
        case NSURLErrorBackgroundSessionRequiresSharedContainer:
            return true
        case NSURLErrorBackgroundSessionWasDisconnected:
            return false
        case NSURLErrorBadServerResponse:
            return true
        case NSURLErrorBadURL:
            return true
        case NSURLErrorCallIsActive:
            return true
        case NSURLErrorCancelled:
            return true
        case NSURLErrorCannotCloseFile:
            return true
        case NSURLErrorCannotConnectToHost:
            return false
        case NSURLErrorCannotCreateFile:
            return true
        case NSURLErrorCannotDecodeContentData:
            return true
        case NSURLErrorCannotDecodeRawData:
            return true
        case NSURLErrorCannotFindHost:
            return false
        case NSURLErrorCannotLoadFromNetwork:
            return true
        case NSURLErrorCannotMoveFile:
            return true
        case NSURLErrorCannotOpenFile:
            return true
        case NSURLErrorCannotParseResponse:
            return true
        case NSURLErrorCannotRemoveFile:
            return true
        case NSURLErrorCannotWriteToFile:
            return true
        case NSURLErrorClientCertificateRejected:
            return false
        case NSURLErrorClientCertificateRequired:
            return true
        case NSURLErrorDNSLookupFailed:
            return false
        case NSURLErrorDataLengthExceedsMaximum:
            return true
        case NSURLErrorDataNotAllowed:
            return true
        case NSURLErrorDownloadDecodingFailedMidStream:
            return true
        case NSURLErrorDownloadDecodingFailedToComplete:
            return true
        case NSURLErrorFileDoesNotExist:
            return true
        case NSURLErrorFileIsDirectory:
            return true
        case NSURLErrorHTTPTooManyRedirects:
            return true
        case NSURLErrorInternationalRoamingOff:
            return true
        case NSURLErrorNetworkConnectionLost:
            return false
        case NSURLErrorNoPermissionsToReadFile:
            return true
        case NSURLErrorNotConnectedToInternet:
            return false
        case NSURLErrorRedirectToNonExistentLocation:
            return true
        case NSURLErrorRequestBodyStreamExhausted:
            return true
        case NSURLErrorResourceUnavailable:
            return true
        case NSURLErrorSecureConnectionFailed:
            return false
        case NSURLErrorServerCertificateHasBadDate:
            return true
        case NSURLErrorServerCertificateHasUnknownRoot:
            return false
        case NSURLErrorServerCertificateNotYetValid:
            return false
        case NSURLErrorServerCertificateUntrusted:
            return false
        case NSURLErrorTimedOut:
            return false
        case NSURLErrorUnsupportedURL:
            return true
        case NSURLErrorUserAuthenticationRequired:
            return false
        case NSURLErrorUserCancelledAuthentication:
            return false
        case NSURLErrorZeroByteResource:
            return true
        default:
            if #available(iOS 9.0, macOS 10.11, *), code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
                return true
            }
            #if os(iOS) || os(macOS)
                if #available(iOS 10.3, macOS 10.12.4, *), code == NSURLErrorFileOutsideSafeArea {
                    return true
                }
            #endif
            return true
        }
    }
}
