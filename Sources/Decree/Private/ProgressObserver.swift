//
//  ProgressObserver.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/24/19.
//

import Foundation

#if canImport(ObjectiveC)
@available(iOS 11.0, OSX 10.13, *)
class ProgressObserver: NSObject {
    @objc dynamic var subject: URLSessionTask
    var observation: NSKeyValueObservation?
    let callbackQueue: DispatchQueue?

    init(for subject: URLSessionTask, callbackQueue: DispatchQueue?, onChange: @escaping (Double) -> ()) {
        self.subject = subject
        self.callbackQueue = callbackQueue

        super.init()

        self.observation = self.observe(\.subject.progress.fractionCompleted, options: [.initial, .new], changeHandler: { [unowned self] object, change in
            guard let value = change.newValue else {
                return
            }
            self.callbackQueue.async {
                onChange(value as Double)
            }
        })
    }
}
#endif
