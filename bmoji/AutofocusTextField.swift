//
//  AutofocusTextField.swift
//  bmoji
//
//  Created by Aaron Ross on 10/3/20.
//

import Foundation
import Cocoa
import SwiftUI

struct AutofocusTextField: NSViewRepresentable {
    private var placeholder: String
    @Binding var text: String

    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(string: text)
        textField.delegate = context.coordinator
        textField.placeholderString = self.placeholder
        textField.isBordered = false
        textField.backgroundColor = nil
        textField.focusRingType = .none
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        // this is a bit hacky, but it's the cleanest thing I could find
        // that works, so here we go
        if !context.coordinator.hasBecomeFirstResponder && nsView.window != nil {
            nsView.becomeFirstResponder()
            context.coordinator.hasBecomeFirstResponder = true
        }
        
        nsView.stringValue = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator { self.text = $0 }
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var hasBecomeFirstResponder: Bool = false
        var setter: (String) -> Void

        init(_ setter: @escaping (String) -> Void) {
            self.setter = setter
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                setter(textField.stringValue)
            }
        }

    }

}
