//
//  AppDelegate.swift
//  bmoji
//
//  Created by Aaron Ross on 10/1/20.
//

import Cocoa
import SwiftUI
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    // MARK: - Properties
    
    var menu: NSMenu!
    var popup: Popup<ContentView>!
    var statusBarItem: NSStatusItem!
    var hotKey: HotKey!
    
    // Initialization

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the content view
        let contentView = ContentView(onClick: self.handleEmojiSelect)
        
        // Create the popup
        self.popup = Popup(contentSize: NSSize(width: 405, height: 250), rootView: contentView)
        
        // Create the context menu
        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(NSMenuItem(title: "Quit bmoji", action: #selector(closeApp), keyEquivalent: ""))
        self.menu = menu
        
        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "Icon")
            button.action = #selector(handleStatusItemClick(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Add a global key combo listener
        let hotKey = HotKey(key: .space, modifiers: [.command, .option])
        hotKey.keyDownHandler = { self.showPopup() }
        self.hotKey = hotKey
        
        // TODO: close window when ESC key is pressed
        // TODO: improve popup show/hide
    }
    
    // MARK: - show/hide popup
    
    @objc func handleStatusItemClick(sender: NSStatusItem) {
        if NSApp.currentEvent!.type == .rightMouseUp {
            self.statusBarItem.menu = self.menu
            self.statusBarItem.button?.performClick(nil)
        } else if self.popup.isShown {
            self.hidePopup()
        } else {
            self.showPopup()
        }
    }
    
    func showPopup() {
        self.popup.showAtCursor()
    }
    
    func hidePopup() {
        self.popup.hide()
    }
    
    // MARK: - NSMenuDelegate
    
    @objc func menuDidClose(_ menu: NSMenu) {
        self.statusBarItem.menu = nil
    }
    
    // MARK: - click handlers
    
    func handleEmojiSelect(_ glyph: String) {
        // close the popup and give focus back to the previously active app (the app we want to paste to)
        self.hidePopup()
        
        // paste glyph after a reasonable delay (to allow the previous app to regain focus)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { Paste.withString(glyph) }
        
        // TODO: record most frequently used emojis
    }
    
    @objc func closeApp() {
        NSApplication.shared.terminate(self)
    }

}
