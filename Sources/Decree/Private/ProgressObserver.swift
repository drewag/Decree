//
//  ProgressObserver.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/24/19.
//

import Foundation

#if canImport(ObjectiveC)
@available(iOS 11.0, OSX 10.13, tvOS 11.0, *)
class ProgressObserver: NSObject {
    @objc dynamic var subject: URLSessionTask
    var observation: NSKeyValueObservation?
    let callbackQueue: DispatchQueue?
    let onChange: (Double) -> ()

    init(for subject: URLSessionTask, callbackQueue: DispatchQueue?, onChange: @escaping (Double) -> ()) {
        self.subject = subject
        self.callbackQueue = callbackQueue
        self.onChange = onChange

        super.init()

        subject.progress.addObserver(self, forKeyPath: "fractionCompleted", options: [.initial, .new], context: nil)
    }

    deinit {
        self.subject.progress.removeObserver(self, forKeyPath: "fractionCompleted")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let value = change?[NSKeyValueChangeKey.newKey] else {
            return
        }
        self.callbackQueue.async {
            self.onChange(value as! Double)
        }
    }
}
#endif
