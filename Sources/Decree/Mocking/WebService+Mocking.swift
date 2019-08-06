//
//  WebService+Mocking.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/5/19.
//

import Foundation

extension WebService {
    /// Start mocking requests to this service
    /// - Tag: WebServiceMocking
    ///
    /// Returns a [WebServiceMock](x-source-tag://WebServiceMock) that allows you to set expectations. While mocking,
    /// if you do not set an expectation, requests will always throw an error.
    public mutating func startMocking() -> WebServiceMock {
        if let existing = self.sessionOverride as? WebServiceMock {
            return existing
        }

        let mock = WebServiceMock()
        self.sessionOverride = mock
        return mock
    }

    /// Stop mocking requests to this service
    ///
    /// Afterwards, all requests will be made for real
    public mutating func stopMocking() {
        if self.sessionOverride is WebServiceMock {
            self.sessionOverride = nil
        }
    }
}
