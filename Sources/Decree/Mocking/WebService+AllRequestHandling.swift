//
//  WebService+AllRequestHandling.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/6/19.
//

import Foundation

public protocol RequestHandler {
    /// Handle data requests
    ///
    /// This method returns the 3 things that are usually returned from the underlying
    /// URLSession data task.
    ///
    /// - parameter dataRequest: the request to respond to
    ///
    /// - returns:
    ///     - An optional response body as Data.
    ///     - An optional URLResponse (will usually be an HTTPURLResponse)
    ///     - An optional error
    func handle(dataRequest: URLRequest) -> (Data?, URLResponse?, Error?)

    /// Handle download requests
    ///
    /// This method returns the 3 things that are usually returned from the underlying
    /// URLSession download task.
    ///
    /// - parameter downloadRequest: the request to respond to
    ///
    /// - returns:
    ///     - An optional url for the download
    ///     - An optional URLResponse (will usually be an HTTPURLResponse)
    ///     - An optional error
    func handle(downloadRequest: URLRequest) -> (URL?, URLResponse?, Error?)
}

extension WebService {
    /// Closure to manually handle web service request
    public typealias AllRequestsHandler = (URLRequest) -> (Data?, URLResponse?, Error?)

    /// Set a handler for handling all requests made to all instances of this web service
    ///
    /// - Parameter handler: Handle for responding to all requests
    ///
    /// The handler returns the following three things:
    /// - An optional response body as Data.
    /// - An optional URLResponse (will usually be an HTTPURLResponse)
    /// - An optional error
    ///
    /// These are the 3 things that are usually returned from the underlying URLSession data task.
    @available(*, deprecated, message: "This does not support handling download requests. Use the protocol version of this call instead.")
    public static func startHandlingAllRequests(handler: @escaping AllRequestsHandler) {
        self.stopHandlingAllRequests()

        AllRequestsHandlers.append((service: self, handler: ClosureHandler(handler: handler)))
    }

    /// Set a handler for handling all requests made to all instances of this web service
    ///
    /// - Parameter handler: An object implementing the RequestHandler protocol
    public static func startHandlingAllRequests(handler: RequestHandler) {
        self.stopHandlingAllRequests()

        AllRequestsHandlers.append((service: self, handler: handler))
    }

    /// Stop handling all requests made to all instances of this web service
    public static func stopHandlingAllRequests() {
        let index = AllRequestsHandlers.firstIndex(where: { spec in
            return spec.service is Self.Type
        })

        guard let actualIndex = index else {
            return
        }
        AllRequestsHandlers.remove(at: actualIndex)
    }
}

private class ClosureHandler: RequestHandler {
    let handler: WebService.AllRequestsHandler

    init(handler: @escaping WebService.AllRequestsHandler) {
        self.handler = handler
    }

    func handle(dataRequest: URLRequest) -> (Data?, URLResponse?, Error?) {
        return self.handler(dataRequest)
    }

    func handle(downloadRequest: URLRequest) -> (URL?, URLResponse?, Error?) {
        return (nil, nil, DecreeError(.custom(
            "Using deprecated all requests handler that does not support download requests",
            details: "Use protocol oriented version instead",
            isInternal: true
        )))
    }
}
