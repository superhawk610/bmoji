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
        
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AutofocusTextField("Search...", text: self.$viewModel.query)
                .padding(.all, 10)
            List(self.viewModel.rows, id: \.0) { (rowIdx, emojis) in
                EmojiRow(
                    rowIdx: rowIdx,
                    activeIdx: self.viewModel.activeRowIdx == rowIdx ? self.viewModel.activeColIdx : nil,
                    emojis: emojis,
                    onHover: self.onHover,
                    onClick: self.onClick
                )
            }
            if self.viewModel.active != nil {
                VStack(alignment: .leading) {
                    Text(self.viewModel.active!.glyph)
                        .padding([.horizontal, .top], 10)
                    Text(([self.viewModel.active!.id] + self.viewModel.active!.keywords).joined(separator: ", "))
                        .padding(.all, 10)
                }
            }
        }
        .background(Rectangle().fill(Color(NSColor.windowBackgroundColor)))
        .cornerRadius(5)
    }
    
    func onHover(_ rowIdx: Int, _ colIdx: Int) {
        self.viewModel.activeIdx = rowIdx * ViewModel.emojisPerRow + colIdx
    }
    
    func onClick(_ emoji: Emoji) {
        Actions.subject.send(.paste(emoji))
    }
    
}

typealias IndexedRow = (Int, [Emoji])

class ViewModel: ObservableObject {
    
    static let emojisPerRow = 11
    
    private var cellCount: Int = 0
    @Published private(set) var rows: [IndexedRow] = []
    @Published private(set) var active: Emoji? = nil
    @Published var query: String = "" { didSet { self.loadRows() } }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - row loading
    
    @Debounced(delay: 0.2) private var loadRows: () -> Void
    
    init() {
        let closure = {
            EmojiStore.shared.query(self.query) { emojis in
                let rows = emojis.chunked(into: ViewModel.emojisPerRow)
                DispatchQueue.main.async {
                    self.cellCount = emojis.count
                    self.rows = Array(zip(rows.indices, rows))
                    self.activeIdx = -1
                }
            }
        }
        
        // immediately invoke the closure to load the rows _without_ debouncing,
        // then store it to the debounced property wrapper
        closure()
        self.loadRows = closure

        Keypresses.subject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] key in self?.handleKey(key) }
            .store(in: &self.cancellables)
    }
    
    // MARK: - row/col navigation
    
    private var _activeIdx: Int = -1
    private(set) var activeRowIdx: Int = -1
    private(set) var activeColIdx: Int = -1
    var activeIdx: Int {
        get { self._activeIdx }
        set {
            if newValue < 0 {
                self.activeRowIdx = 0
                self.activeColIdx = 0
                self._activeIdx = 0
                self.active = nil
            } else if newValue >= self.cellCount {
                self.activeIdx = self.cellCount - 1
            } else {
                let rowIdx = newValue / ViewModel.emojisPerRow
                let (_, row) = self.rows[rowIdx]
                let colIdx = newValue % ViewModel.emojisPerRow
                
                self.activeRowIdx = rowIdx
                self.activeColIdx = colIdx
                self._activeIdx = newValue
                self.active = row[colIdx]
            }
        }
    }
    
    // MARK: - keypress handling
    
    func handleKey(_ key: Key) {
        switch key {
        case .up: return self.selectUp()
        case .down: return self.selectDown()
        case .left: return self.selectLeft()
        case .right: return self.selectRight()
        case .tab: return self.selectNext()
        case .shiftTab: return self.selectPrev()
        case .esc: return self.handleEsc()
        case .enter: return self.handleReturn()
        }
    }
    
    func handleEsc() {
        Actions.subject.send(.close)
    }
    
    func handleReturn() {
        if self.active != nil {
            Actions.subject.send(.paste(self.active!))
        }
    }
    
    func selectNext() {
        self.activeIdx += 1
    }
    
    func selectPrev() {
        self.activeIdx -= 1
    }
    
    func selectUp() {
        self.activeIdx -= ViewModel.emojisPerRow
    }
    
    func selectDown() {
        self.activeIdx += ViewModel.emojisPerRow
    }
    
    func selectLeft() {
        if self.activeIdx % ViewModel.emojisPerRow != 0 {
            selectPrev()
        }
    }
    
    func selectRight() {
        if self.activeIdx % ViewModel.emojisPerRow != ViewModel.emojisPerRow - 1 {
            selectNext()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 405, height: 250))
    }
}
