//
//  WebService+AllRequestHandling.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/6/19.
//

import Foundation

extension WebService {
    /// Closure to manually handle web service request
    public typealias AllRequestsHandler = (URLRequest) -> (Data?, URLResponse?, Error?)

    /// Set a handler for handling all requests made to all isntances of this web service
    ///
    /// - Parameter handler: Handle for responding to all requests
    ///
    /// The handler returns the following three things:
    /// - An optional response body as Data.
    /// - An optional URLResponse (will usually be an HTTPURLResponse)
    /// - An optional error
    ///
    /// These are the 3 things that are usually returned from the underlying URLSession data task.
    public static func startHandlingAllRequests(handler: @escaping AllRequestsHandler) {
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
