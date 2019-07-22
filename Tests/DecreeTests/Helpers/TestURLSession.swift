//
//  TestURLSession.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation
import Decree

class TestURLSession: Session {
    static let test = TestURLSession()

    class StartedTask {
        let request: URLRequest
        let complete: (Data?, URLResponse?, Error?) -> Void

        init(request: URLRequest, complete: @escaping (Data?, URLResponse?, Error?) -> Void) {
            self.request = request
            self.complete = complete
        }
    }

    var startedTasks = [StartedTask]()
    var fixedOutput: (data: Data?, response: URLResponse?, error: Error?)?

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return TestURLSessionDataTask(session: self, request: request, completionHandler: completionHandler)
    }
}

private class TestURLSessionDataTask: URLSessionDataTask {
    let session: TestURLSession
    let task: TestURLSession.StartedTask

    init(session: TestURLSession, request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.session = session
        self.task = .init(request: request, complete: completionHandler)
    }

    override func resume() {
        if let output = self.session.fixedOutput {
            self.task.complete(output.data, output.response, output.error)
            return
        }
        self.session.startedTasks.append(self.task)
    }
}

class TestResponse: HTTPURLResponse {
    init!(statusCode: Int = 200, headerFields: [String:String]? = nil) {
        super.init(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: headerFields
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
