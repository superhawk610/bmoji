//
//  Popup.swift
//  bmoji
//
//  Created by Aaron Ross on 10/2/20.
//

import Cocoa
import SwiftUI

class Popup<Content>: NSWindow where Content: View {
    private var contentSize: NSSize!
    
    var isShown: Bool { get { self.isVisible } }
    override var canBecomeKey: Bool { get { true } }
    override var acceptsFirstResponder: Bool { get { true } }
    
    init(contentSize: NSSize, rootView: Content) {
        super.init(
            contentRect: NSRect(origin: .zero, size: .zero),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        
        self.contentSize = contentSize
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hidesOnDeactivate = false
        self.isReleasedWhenClosed = false
        self.isMovableByWindowBackground = true
        self.collectionBehavior = .canJoinAllSpaces
        self.contentViewController = NSHostingController(rootView: rootView)
    }
    
    func showAt(_ point: NSPoint) {
        self.setContentSize(self.contentSize)
        self.setFrameOrigin(point)
        
        self.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showAtCursor() {
        let cursor = NSEvent.mouseLocation
        guard let activeScreen = NSScreen.containingCursor() else {
            self.showAt(NSPoint(x: cursor.x + 5, y: cursor.y + 5))
            return
        }
        
        if cursor.x + self.contentSize.width > activeScreen.frame.width {
            self.showAt(NSPoint(x: activeScreen.frame.width - self.contentSize.width - 5, y: cursor.y + 5))
        } else {
            self.showAt(NSPoint(x: cursor.x + 5, y: cursor.y + 5))
        }
    }
    
    func hide() {
        self.orderOut(nil)
    }
}
