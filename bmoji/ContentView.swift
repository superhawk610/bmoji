//
//  ContentView.swift
//  bmoji
//
//  Created by Aaron Ross on 10/1/20.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject private var viewModel: ViewModel = ViewModel()
    @State private var active: Emoji? = nil
    
    var onClick: EmojiRowClickHandler? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AutofocusTextField("Search...", text: self.$viewModel.query)
                .padding(.all, 10)
            List(self.viewModel.rows, id: \.0) { (_, emojis) in
                EmojiRow(
                    emojis: emojis,
                    onHover: self.onHover,
                    onClick: self.onClick
                )
            }
            if self.active != nil {
                VStack(alignment: .leading) {
                    Text(self.active!.glyph)
                        .padding([.horizontal, .top], 10)
                    Text(([self.active!.id] + self.active!.keywords).joined(separator: ", "))
                        .padding(.all, 10)
                }
            }
        }
        .background(Rectangle().fill(Color(NSColor.windowBackgroundColor)))
        .cornerRadius(5)
    }
    
    init() {}
    
    init(_ active: Emoji) {
        self.active = active
    }
    
    init(onClick: @escaping EmojiRowClickHandler) {
        self.onClick = onClick
    }
    
    func onHover(_ emoji: Emoji) {
        self.active = emoji
    }
    
}

typealias IndexedRow = (Int, [Emoji])

class ViewModel: ObservableObject {
    
    static let emojisPerRow = 11
    
    @Published private(set) var rows: [IndexedRow] = []
    @Published var query: String = "" {
        didSet {
            self.loadRows()
        }
    }
    
    @Debounced(delay: 0.2) private var loadRows: () -> Void
    
    init() {
        let closure = {
            EmojiStore.shared.query(self.query) { emojis in
                let rows = emojis.chunked(into: ViewModel.emojisPerRow)
                DispatchQueue.main.async { self.rows = Array(zip(rows.indices, rows)) }
            }
        }
        
        // immediately invoke the closure to load the rows _without_ debouncing,
        // then store it to the debounced property wrapper
        closure()
        self.loadRows = closure
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewLayout(.fixed(width: 405, height: 250))
            ContentView(EmojiStore.shared.get("grinning")!)
                .previewLayout(.fixed(width: 405, height: 250))
        }
    }
}
