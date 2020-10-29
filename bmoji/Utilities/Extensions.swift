//
//  Extensions.swift
//  bmoji
//
//  Created by Aaron Ross on 10/2/20.
//

import Foundation
import Cocoa

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension NSScreen {
    /** Get the screen containing the mouse cursor (if any). */
    static func containingCursor() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        
        return screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }
    }
}
