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
        self.hidesOnDeactivate = true
        self.isReleasedWhenClosed = false
        self.isMovableByWindowBackground = true
        self.contentViewController = NSHostingController(rootView: rootView)
    }
    
    func showAt(_ point: NSPoint) {
        self.setContentSize(self.contentSize)
        self.setFrameOrigin(point)
        
        self.makeKeyAndOrderFront(nil)
        self.orderFrontRegardless()
        if self.canBecomeMain { self.becomeMain() }
        
        NSApp.unhide(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showAtCursor() {
        self.showAt(NSPoint(x: NSEvent.mouseLocation.x + 5, y: NSEvent.mouseLocation.y + 5))
    }
    
    func hide() {
        self.orderOut(nil)

        NSApp.hide(nil)
    }
}
