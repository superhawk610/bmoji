//
//  ListScrollingHelper.swift
//  bmoji
//
//  Created by Aaron Ross on 11/13/20.
//

import SwiftUI

struct ListScrollingHelper: NSViewRepresentable {
    
    let proxy: ListScrollingProxy
    
    func makeNSView(context: Context) -> NSView {
        return NSView()
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        proxy.catchScrollView(for: nsView)
    }
    
}

class ListScrollingProxy {
    
    private var scrollView: NSScrollView?
    
    var currentScrollY: CGFloat? {
        get {
            if let scroller = self.scrollView {
                return scroller.contentView.bounds.origin.y
            }
            
            return nil
        }
    }
    
    func catchScrollView(for view: NSView) {
        if let enclosingScrollView = view.enclosingScrollView {
            self.scrollView = enclosingScrollView
        }
    }
    
    func scrollTo(_ y: CGFloat) {
        if let scroller = self.scrollView {
            scroller.contentView.scroll(to: NSPoint(x: 0, y: y))
            scroller.reflectScrolledClipView(scroller.contentView)
        }
    }
    
}
