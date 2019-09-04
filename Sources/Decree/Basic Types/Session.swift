//
//  Session.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation

/// Instance to make HTTP requests with
public protocol Session {
//    var configuration: URLSessionConfiguration {get}
//    var delegate: URLSessionDelegate? {get}
//    var delegateQueue: OperationQueue {get}

//    init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?)

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask
}

extension URLSession: Session {}
