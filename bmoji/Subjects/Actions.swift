//
//  Actions.swift
//  bmoji
//
//  Created by Aaron Ross on 10/27/20.
//

import Foundation
import Combine

enum Action {
    case close
    case paste(Emoji)
}

typealias ActionSubject = PassthroughSubject<Action, Never>

struct Actions {
    
    static let subject: ActionSubject = PassthroughSubject()
    
}
