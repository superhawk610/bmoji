//
//  KeypressSubject.swift
//  bmoji
//
//  Created by Aaron Ross on 10/3/20.
//

import Foundation
import Combine

enum Key {
    case up
    case down
    case left
    case right
    case tab
    case shiftTab
    case enter
}

typealias KeypressSubject = PassthroughSubject<Key, Never>

struct Keypresses {

    static let subject: KeypressSubject = PassthroughSubject()
    
}
