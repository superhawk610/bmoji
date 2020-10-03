//
//  Debouncer.swift
//  bmoji
//
//  Created by Aaron Ross on 10/2/20.
//

import Foundation

@propertyWrapper
struct Debounced {
    
    let delay: TimeInterval
    let queue: DispatchQueue
    var action: () -> Void = {}
    
    var wrappedValue: () -> Void {
        get { return action }
        set {
            var workItem: DispatchWorkItem?
            
            self.action = { [queue, delay] in
                workItem?.cancel()
                workItem = DispatchWorkItem(block: newValue)
                queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
            }
        }
    }
    
    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

}
