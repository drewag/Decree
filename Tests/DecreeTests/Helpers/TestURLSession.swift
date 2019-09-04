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

        #if canImport(ObjectiveC)
            let progress: TestProgress

            init(request: URLRequest, progress: TestProgress, complete: @escaping (Data?, URLResponse?, Error?) -> Void) {
                self.request = request
                self.complete = complete
                self.progress = progress
            }
        #else
            init(request: URLRequest, complete: @escaping (Data?, URLResponse?, Error?) -> Void) {
                self.request = request
                self.complete = complete
            }
        #endif
    }

    class StartedDownloadTask {
        let request: URLRequest
        let complete: (URL?, URLResponse?, Error?) -> Void

        #if canImport(ObjectiveC)
        let progress: TestProgress

        init(request: URLRequest, progress: TestProgress, complete: @escaping (URL?, URLResponse?, Error?) -> Void) {
            self.request = request
            self.complete = complete
            self.progress = progress
        }
        #else
        init(request: URLRequest, complete: @escaping (URL?, URLResponse?, Error?) -> Void) {
            self.request = request
            self.complete = complete
        }
        #endif
    }

    var startedTasks = [StartedTask]()
    var startedDownloadTasks = [StartedDownloadTask]()
    var fixedOutput: (data: Data?, response: URLResponse?, error: Error?)?
    var fixedDownloadOutput: (url: URL?, response: URLResponse?, error: Error?)?

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return TestURLSessionDataTask(session: self, request: request, completionHandler: completionHandler)
    }

    func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        return TestURLSessionDownloadTask(session: self, request: request, completionHandler: completionHandler)
    }
}

#if canImport(ObjectiveC)
class TestProgress: Progress {
    var _factionCompleted: Double = 0 {
        willSet {
            self.willChangeValue(for: \.fractionCompleted)
        }
        didSet {
            self.didChangeValue(for: \.fractionCompleted)
        }
    }
    override var fractionCompleted: Double {
        get {
            return self._factionCompleted
        }
    }
}
#endif

private class TestURLSessionDataTask: URLSessionDataTask {
    let session: TestURLSession
    let task: TestURLSession.StartedTask
    #if canImport(ObjectiveC)
    let _progress = TestProgress()
    override var progress: Progress {
        return self._progress
    }
    #endif

    init(session: TestURLSession, request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.session = session
        #if canImport(ObjectiveC)
            self.task = .init(request: request, progress: self._progress, complete: completionHandler)
        #else
            self.task = .init(request: request, complete: completionHandler)
        #endif
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

private class TestURLSessionDownloadTask: URLSessionDownloadTask {
    let session: TestURLSession
    let task: TestURLSession.StartedDownloadTask
    #if canImport(ObjectiveC)
    let _progress = TestProgress()
    override var progress: Progress {
        return self._progress
    }
    #endif

    init(session: TestURLSession, request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) {
        self.session = session
        #if canImport(ObjectiveC)
            self.task = .init(request: request, progress: self._progress, complete: completionHandler)
        #else
            self.task = .init(request: request, complete: completionHandler)
        #endif
    }

    override func resume() {
        if let output = self.session.fixedDownloadOutput {
            self.task.complete(output.url, output.response, output.error)
            return
        }
        self.session.startedDownloadTasks.append(self.task)
    }
}
