//
//  DecreeErrorTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/25/19.
//

import XCTest
@testable import Decree

class DecreeErrorTests: XCTestCase {
    func testCustomOperations() {
        var error = DecreeError(.missingData, operationName: nil)
        XCTAssertEqual(error.title, "Error making request")
        XCTAssertEqual(error.description, #"Error making request: An internal error has occured. If it continues, please contact support with the description "No data returned.""#)

        error = DecreeError(.missingData, operationName: "doing")
        XCTAssertEqual(error.title, "Error Doing")
        XCTAssertEqual(error.description, #"Error doing: An internal error has occured. If it continues, please contact support with the description "No data returned.""#)

        error = DecreeError(.missingData, operationName: "doing the thing")
        XCTAssertEqual(error.title, "Error Doing the Thing")
        XCTAssertEqual(error.description, #"Error doing the thing: An internal error has occured. If it continues, please contact support with the description "No data returned.""#)

        error = DecreeError(.missingData, operationName: "doing a thing")
        XCTAssertEqual(error.title, "Error Doing a Thing")
        XCTAssertEqual(error.description, #"Error doing a thing: An internal error has occured. If it continues, please contact support with the description "No data returned.""#)

        error = DecreeError(.missingData, operationName: "doing an operation")
        XCTAssertEqual(error.title, "Error Doing an Operation")
        XCTAssertEqual(error.description, #"Error doing an operation: An internal error has occured. If it continues, please contact support with the description "No data returned.""#)

        error = DecreeError(.missingData, operationName: "sending to endpoint")
        XCTAssertEqual(error.title, "Error Sending to Endpoint")
        XCTAssertEqual(error.description, #"Error sending to endpoint: An internal error has occured. If it continues, please contact support with the description "No data returned.""#)
    }

    func testSimpleErrors() {
        var error = DecreeError(.unauthorized, operationName: nil)
        XCTAssertEqual(error.reason, "You are not logged in.")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, false)

        error = DecreeError(.noResponse, operationName: nil)
        XCTAssertEqual(error.reason, "No response returned.")
        XCTAssertEqual(error.details, "The data task did not return an error, but it also didn\'t return a response.")
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.missingData, operationName: nil)
        XCTAssertEqual(error.reason, "No data returned.")
        XCTAssertEqual(error.details, "The data task did not return an error, but it also didn\'t return any data.")
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.invalidOutputString, operationName: nil)
        XCTAssertEqual(error.reason, "The response body was invalid text.")
        XCTAssertNil(error.details)
        XCTAssertEqual(error.isInternal, true)
    }

    func testEncodingErrors() {
        enum CodingKeys: String, CodingKey {
            case key1, key2
        }

        let underlyingError = OtherError("other")
        let encodingError = EncodingError.invalidValue("value", .init(codingPath: [CodingKeys.key1,CodingKeys.key2], debugDescription: "debug description", underlyingError: underlyingError))
        let error = DecreeError(.encoding(TestInput(date: nil), encodingError), operationName: nil)
        XCTAssertEqual(error.reason, "Failed to encode TestInput(date: nil, string: \"weird&=?<>characters\", otherError: false).")
        XCTAssertEqual(error.details, """
            Invalid Value: value
            Key Path: key1.key2
            Debug Description: debug description
            Underyling Error: other

            Debugging: To see raw requests and responses, turn on logging with `Logger.shared.level = .info(filter: nil)`.
            """
        )
        XCTAssertEqual(error.isInternal, true)
    }

    func testDecodingErrors() {
        enum CodingKeys: String, CodingKey {
            case key1, key2
        }

        let underlyingError = OtherError("other")
        let context = DecodingError.Context(codingPath: [CodingKeys.key1,CodingKeys.key2], debugDescription: "debug description", underlyingError: underlyingError)
        var decodingError = DecodingError.dataCorrupted(context)
        var error = DecreeError(.decoding(typeName: "TestOutput", decodingError), operationName: nil)
        XCTAssertEqual(error.reason, "Failed to decode TestOutput.")
        XCTAssertEqual(error.details, """
            TestOutput Data Corrupted
            Key Path: key1.key2
            Debug Description: debug description
            Underyling Error: other

            Debugging: To see raw requests and responses, turn on logging with `Logger.shared.level = .info(filter: nil)`.
            """
        )
        XCTAssertEqual(error.isInternal, true)

        decodingError = DecodingError.keyNotFound(CodingKeys.key1, context)
        error = DecreeError(.decoding(typeName: "TestOutput", decodingError), operationName: nil)
        XCTAssertEqual(error.reason, "Failed to decode TestOutput.")
        XCTAssertEqual(error.details, """
            Key not found for key1
            Key Path: key1.key2
            Debug Description: debug description
            Underyling Error: other

            Debugging: To see raw requests and responses, turn on logging with `Logger.shared.level = .info(filter: nil)`.
            """
        )
        XCTAssertEqual(error.isInternal, true)

        decodingError = DecodingError.typeMismatch(TestOutput.self, context)
        error = DecreeError(.decoding(typeName: "TestOutput", decodingError), operationName: nil)
        XCTAssertEqual(error.reason, "Failed to decode TestOutput.")
        XCTAssertEqual(error.details, """
            Type mismatch for TestOutput
            Key Path: key1.key2
            Debug Description: debug description
            Underyling Error: other

            Debugging: To see raw requests and responses, turn on logging with `Logger.shared.level = .info(filter: nil)`.
            """
        )
        XCTAssertEqual(error.isInternal, true)

        decodingError = DecodingError.valueNotFound(TestOutput.self, context)
        error = DecreeError(.decoding(typeName: "TestOutput", decodingError), operationName: nil)
        XCTAssertEqual(error.reason, "Failed to decode TestOutput.")
        XCTAssertEqual(error.details, """
            Value not found for TestOutput
            Key Path: key1.key2
            Debug Description: debug description
            Underyling Error: other

            Debugging: To see raw requests and responses, turn on logging with `Logger.shared.level = .info(filter: nil)`.
            """
        )
        XCTAssertEqual(error.isInternal, true)
    }

    func testParsedErrors() {
        var error = DecreeError(.parsed(TestService.ErrorResponse(message: "some message"), original: OtherError("other")), operationName: nil)
        XCTAssertEqual(error.reason, "some message")
        XCTAssertEqual(error.details, """
            Parsed: ErrorResponse(message: \"some message\")
            Original: other
            """)
        XCTAssertEqual(error.isInternal, true)

        var original = DecreeError(.http(.multipleChoices), operationName: nil)
        error = DecreeError(.parsed(TestService.ErrorResponse(message: "some message"), original: original), operationName: nil)
        XCTAssertEqual(error.reason, "some message")
        XCTAssertEqual(error.details, """
            Parsed: ErrorResponse(message: "some message")
            Original: HTTP error: 300 MULTIPLE CHOICES
            """)
        XCTAssertEqual(error.isInternal, true)

        original = DecreeError(.http(.forbidden), operationName: nil)
        error = DecreeError(.parsed(TestService.ErrorResponse(message: "some message"), original: original), operationName: nil)
        XCTAssertEqual(error.reason, "some message")
        XCTAssertEqual(error.details, """
            Parsed: ErrorResponse(message: "some message")
            Original: You are not authorized.
            HTTP error: 403 FORBIDDEN
            """)
        XCTAssertEqual(error.isInternal, true)
    }

    func testHTTPErrors() {
        var error = DecreeError(.http(.multipleChoices), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 300 MULTIPLE CHOICES")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.movedPermanently), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 301 MOVED PERMANENTLY")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.found), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 302 FOUND")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.seeOther), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 303 SEE OTHER")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.notModified), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 304 NOT MODIFIED")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.useProxy), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 305 USE PROXY")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.temporaryRedirect), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 307 TEMPORARY REDIRECT")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.badRequest), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 400 BAD REQUEST")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.unauthorized), operationName: nil)
        XCTAssertEqual(error.reason, "You are not authorized.")
        XCTAssertEqual(error.details, "HTTP error: 401 UNAUTHORIZED")
        XCTAssertEqual(error.isInternal, false)

        error = DecreeError(.http(.paymentRequired), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 402 PAYMENT REQUIRED")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.forbidden), operationName: nil)
        XCTAssertEqual(error.reason, "You are not authorized.")
        XCTAssertEqual(error.details, "HTTP error: 403 FORBIDDEN")
        XCTAssertEqual(error.isInternal, false)

        error = DecreeError(.http(.notFound), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 404 NOT FOUND")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.methodNotAllowed), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 405 METHOD NOT ALLOWED")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.notAcceptable), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 406 NOT ACCEPTABLE")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.proxyAuthenticationRequired), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 407 PROXY AUTHENTICATION REQUIRED")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.requestTimeout), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 408 REQUEST TIMEOUT")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.conflict), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 409 CONFLICT")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.gone), operationName: nil)
        XCTAssertEqual(error.reason, "This app is out of date. Please update to the latest version.")
        XCTAssertEqual(error.details, "HTTP error: 410 GONE")
        XCTAssertEqual(error.isInternal, false)

        error = DecreeError(.http(.lengthRequired), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 411 LENGTH REQUIRED")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.preconditionFailed), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 412 PRECONDITION FAILED")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.requestEntityTooLarge), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 413 REQUEST ENTITY TOO LARGE")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.requestURITooLong), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 414 REQUEST URI TOO LONG")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.unsupportedMediaType), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 415 UNSUPPORTED MEDIA TYPE")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.requestedRangeNotSatisfiable), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 416 REQUESTED RANGE NOT SATISFIABLE")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.expectationFailed), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 417 EXPECTATION FAILED")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.internalServerError), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 500 INTERNAL ERROR")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.notImplemented), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 501 NOT IMPLEMENTED")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.badGateway), operationName: nil)
        XCTAssertEqual(error.reason, "The web server appears to be down.")
        XCTAssertEqual(error.details, "HTTP error: 502 BAD GATEWAY")
        XCTAssertEqual(error.isInternal, false)

        error = DecreeError(.http(.serviceUnavailable), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 503 SERVICE UNAVAILABLE")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.gatewayTimeout), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 504 GATEWAY TIMEOUT")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.httpVersionNotSupported), operationName: nil)
        XCTAssertEqual(error.reason, "HTTP error: 505 HTTP VERSION NOT SUPPORTED")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        error = DecreeError(.http(.other(601)), operationName: nil)
        XCTAssertEqual(error.reason, "Unrecognized HTTP error: 601")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)
    }

    func testFoundationErrors() {
        var underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
        var error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -999")
        XCTAssertEqual(error.details, "An asynchronous load has been canceled.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1000")
        XCTAssertEqual(error.details, "A malformed URL prevented a URL request from being initiated.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "The request timed out. Please try again.")
        XCTAssertEqual(error.details, "An asynchronous operation timed out.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1002")
        XCTAssertEqual(error.details, "A properly formed URL couldn’t be handled by the framework.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotFindHost, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "The web server appears to be down. Please try again later.")
        XCTAssertEqual(error.details, "The host name for a URL couldn’t be resolved.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "The web server appears to be down. Please try again later.")
        XCTAssertEqual(error.details, "An attempt to connect to a host failed.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "Your internet connection was lost. Please make sure your internet is working and try again. If it continues to happen, please reach out to support.")
        XCTAssertEqual(error.details, "A client or server connection was severed in the middle of an in-progress load.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorDNSLookupFailed, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "The web server appears to be down. Please try again later.")
        XCTAssertEqual(error.details, "The host address couldn’t be found via DNS lookup.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorHTTPTooManyRedirects, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1007")
        XCTAssertEqual(error.details, "A redirect loop was detected or the threshold for number of allowable redirects was exceeded.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorResourceUnavailable, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1008")
        XCTAssertEqual(error.details, "A requested resource couldn’t be retrieved.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "You're not connected to the internet.")
        XCTAssertEqual(error.details, "A network resource was requested, but an internet connection has not been established and can’t be established automatically.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorRedirectToNonExistentLocation, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1010")
        XCTAssertEqual(error.details, "A redirect was specified by way of server response code, but the server didn’t accompany this code with a redirect URL.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1011")
        XCTAssertEqual(error.details, "The URL Loading System received bad data from the server.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorUserCancelledAuthentication, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "You are not authorized.")
        XCTAssertEqual(error.details, "An asynchronous request for authentication has been canceled by the user.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorUserAuthenticationRequired, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "You are not authorized.")
        XCTAssertEqual(error.details, "Authentication was required to access a resource.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorZeroByteResource, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1014")
        XCTAssertEqual(error.details, "A server reported that a URL has a non-zero content length, but terminated the network connection gracefully without sending any data.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotDecodeRawData, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1015")
        XCTAssertEqual(error.details, "Content data received during a connection request couldn’t be decoded for a known content encoding.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotDecodeContentData, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1016")
        XCTAssertEqual(error.details, "Content data received during a connection request had an unknown content encoding.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotParseResponse, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1017")
        XCTAssertEqual(error.details, "A response to a connection request couldn’t be parsed.")
        XCTAssertEqual(error.isInternal, true)

        if #available(iOS 9.0, macOS 10.11, *) {
            underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorAppTransportSecurityRequiresSecureConnection, userInfo: nil)
            error = DecreeError(other: underlyingError, for: Empty())
            XCTAssertEqual(error.reason, "NSURLError -1022")
            XCTAssertEqual(error.details, "App Transport Security disallowed a connection because there is no secure network connection.")
            XCTAssertEqual(error.isInternal, true)
        }

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorFileDoesNotExist, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1100")
        XCTAssertEqual(error.details, "The specified file doesn’t exist.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorFileIsDirectory, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1101")
        XCTAssertEqual(error.details, "A request for an FTP file resulted in the server responding that the file is not a plain file, but a directory.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNoPermissionsToReadFile, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1102")
        XCTAssertEqual(error.details, "A resource couldn’t be read because of insufficient permissions.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorDataLengthExceedsMaximum, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1103")
        XCTAssertEqual(error.details, "The length of the resource data exceeded the maximum allowed.")
        XCTAssertEqual(error.isInternal, true)

        #if os(iOS) || os(macOS)
            if #available(iOS 10.3, macOS 10.12.4, *) {
                underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorFileOutsideSafeArea, userInfo: nil)
                error = DecreeError(other: underlyingError, for: Empty())
                XCTAssertEqual(error.reason, "NSURLError -1104")
                XCTAssertEqual(error.details, "An internal file operation failed.")
                XCTAssertEqual(error.isInternal, true)
            }
        #endif

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorSecureConnectionFailed, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "The web server can no longer be trusted. Please update to the latest version of this app.")
        XCTAssertEqual(error.details, "An attempt to establish a secure connection failed for reasons that can’t be expressed more specifically.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorServerCertificateHasBadDate, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError \(NSURLErrorServerCertificateHasBadDate)")
        XCTAssertEqual(error.details, "A server certificate is expired, or is not yet valid.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorServerCertificateUntrusted, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "The web server can no longer be trusted. Please update to the latest version of this app.")
        XCTAssertEqual(error.details, "A server certificate was signed by a root server that isn’t trusted.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorServerCertificateHasUnknownRoot, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "The web server can no longer be trusted. Please update to the latest version of this app.")
        XCTAssertEqual(error.details, "A server certificate wasn’t signed by any root server.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorServerCertificateNotYetValid, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "The web server can no longer be trusted. Please update to the latest version of this app.")
        XCTAssertEqual(error.details, "A server certificate isn’t valid yet.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorClientCertificateRejected, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "The web server can no longer be trusted. Please update to the latest version of this app.")
        XCTAssertEqual(error.details, "A server certificate was rejected.")
        XCTAssertEqual(error.isInternal, false)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorClientCertificateRequired, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError \(NSURLErrorClientCertificateRequired)")
        XCTAssertEqual(error.details, "A client certificate was required to authenticate an SSL connection during a connection request.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotLoadFromNetwork, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -2000")
        XCTAssertEqual(error.details, "A specific request to load an item only from the cache couldn\'t be satisfied.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -3000")
        XCTAssertEqual(error.details, "A download task couldn’t create the downloaded file on disk because of an I/O failure.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -3001")
        XCTAssertEqual(error.details, "A downloaded file on disk couldn’t be opened.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCloseFile, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -3002")
        XCTAssertEqual(error.details, "A download task couldn’t close the downloaded file on disk.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotWriteToFile, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -3003")
        XCTAssertEqual(error.details, "A download task couldn’t write the file to disk.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotRemoveFile, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -3004")
        XCTAssertEqual(error.details, "A downloaded file couldn’t be removed from disk.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotMoveFile, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -3005")
        XCTAssertEqual(error.details, "A downloaded file on disk couldn’t be moved.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorDownloadDecodingFailedMidStream, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -3006")
        XCTAssertEqual(error.details, "A download task failed to decode an encoded file during the download.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorDownloadDecodingFailedToComplete, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -3007")
        XCTAssertEqual(error.details, "A download task failed to decode an encoded file after downloading.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorInternationalRoamingOff, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1018")
        XCTAssertEqual(error.details, "The attempted connection required activating a data context while roaming, but international roaming is disabled.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCallIsActive, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1019")
        XCTAssertEqual(error.details, "A connection was attempted while a phone call was active on a network that doesn’t support simultaneous phone and data communication, such as EDGE or GPRS.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorDataNotAllowed, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1020")
        XCTAssertEqual(error.details, "The cellular network disallowed a connection.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorRequestBodyStreamExhausted, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -1021")
        XCTAssertEqual(error.details, "A body stream was needed but the client did not provide one.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorBackgroundSessionRequiresSharedContainer, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -995")
        XCTAssertEqual(error.details, "The shared container identifier of the URL session configuration is needed but hasn’t been set.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorBackgroundSessionInUseByAnotherProcess, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "NSURLError -996")
        XCTAssertEqual(error.details, "An app or app extension attempted to connect to a background session that is already connected to a process.")
        XCTAssertEqual(error.isInternal, true)

        underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorBackgroundSessionWasDisconnected, userInfo: nil)
        error = DecreeError(other: underlyingError, for: Empty())
        XCTAssertEqual(error.reason, "Your internet connection was lost. Please make sure your internet is working and try again. If it continues to happen, please reach out to support.")
        XCTAssertEqual(error.details, "The app is suspended or exits while a background data task is processing.")
        XCTAssertEqual(error.isInternal, false)
    }

    func testOtherErrors() {
        let error = DecreeError(.other(OtherError("other error")), operationName: nil)
        XCTAssertEqual(error.reason, "other error")
        XCTAssertEqual(error.details, """
            OtherErrorDomain 7
            Failure Reason: You did something wrong
            Recovery Suggestion: Fix it dummy
            User Info:
                key1: value1
            """
        )
        XCTAssertEqual(error.isInternal, true)
    }

    func testCustomErrors() {
        var error = DecreeError(.custom("custom", details: nil, isInternal: true), operationName: nil)
        XCTAssertEqual(error.alertMessage, #"An internal error has occured. If it continues, please contact support with the description "custom""#)
        XCTAssertEqual(error.description, #"Error making request: An internal error has occured. If it continues, please contact support with the description "custom""#)
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.debugDescription, #"Error making request: An internal error has occured. If it continues, please contact support with the description "custom""#)

        error = DecreeError(.custom("custom", details: nil, isInternal: false), operationName: nil)
        XCTAssertEqual(error.alertMessage, "custom")
        XCTAssertEqual(error.description, #"Error making request: custom"#)
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.debugDescription, #"Error making request: custom"#)

        error = DecreeError(.custom("custom", details: "some details", isInternal: false), operationName: nil)
        XCTAssertEqual(error.alertMessage, "custom")
        XCTAssertEqual(error.description, #"Error making request: custom"#)
        XCTAssertEqual(error.details, "some details")
        XCTAssertEqual(error.debugDescription, #"Error making request: custom\#nsome details"#)

        error = DecreeError(.custom("custom", details: "some details", isInternal: false), operationName: nil)
        XCTAssertEqual(error.alertMessage, "custom")
        XCTAssertEqual(error.description, #"Error making request: custom"#)
        XCTAssertEqual(error.details, "some details")
        XCTAssertEqual(error.debugDescription, #"Error making request: custom\#nsome details"#)
    }

    func testMockingErrors() {
        var error = DecreeError(.unexpectedEndpoint("SomeEndpoint"), operationName: nil)
        XCTAssertEqual(error.alertMessage, "A request was made to ‘SomeEndpoint’ during mocking that was not expected.")
        XCTAssertEqual(error.description, "Error making request: A request was made to ‘SomeEndpoint’ during mocking that was not expected.")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.debugDescription, "Error making request: A request was made to ‘SomeEndpoint’ during mocking that was not expected.")

        error = DecreeError(.incorrectExpecation(expected: "Right", actual: "Wrong"), operationName: nil)
        XCTAssertEqual(error.alertMessage, "A request was made to ‘Wrong’ when ‘Right’ was expected.")
        XCTAssertEqual(error.description, "Error making request: A request was made to ‘Wrong’ when ‘Right’ was expected.")
        XCTAssertEqual(error.details, nil)
        XCTAssertEqual(error.debugDescription, "Error making request: A request was made to ‘Wrong’ when ‘Right’ was expected.")

        error = DecreeError(.incorrectExpectationPath(expected: "Right/Path", actual: "Wrong/Path", endpoint: "SomeEndpoint"), operationName: nil)
        XCTAssertEqual(error.alertMessage, "A request was made to the wrong path of ‘SomeEndpoint’.")
        XCTAssertEqual(error.description, "Error making request: A request was made to the wrong path of ‘SomeEndpoint’.")
        XCTAssertEqual(error.details, "Path was ‘Wrong/Path’ but expected ‘Right/Path‘.")
        XCTAssertEqual(error.debugDescription, """
            Error making request: A request was made to the wrong path of ‘SomeEndpoint’.
            Path was ‘Wrong/Path’ but expected ‘Right/Path‘.
            """
        )

        error = DecreeError(.unexpectedInput(expected: "Right", actual: "Wrong", endpoint: "SomeEndpoint"), operationName: nil)
        XCTAssertEqual(error.alertMessage, "A request was made to ‘SomeEndpoint’ with unexpected input.")
        XCTAssertEqual(error.description, "Error making request: A request was made to ‘SomeEndpoint’ with unexpected input.")
        XCTAssertEqual(error.details, "Got ‘Wrong’ but expected ‘Right’.")
        XCTAssertEqual(error.debugDescription, """
            Error making request: A request was made to ‘SomeEndpoint’ with unexpected input.
            Got ‘Wrong’ but expected ‘Right’.
            """
        )
    }
}
