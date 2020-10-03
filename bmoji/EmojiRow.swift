//
//  EmojiCell.swift
//  bmoji
//
//  Created by Aaron Ross on 10/2/20.
//

import SwiftUI

typealias EmojiRowHoverHandler = (Emoji) -> Void
typealias EmojiRowClickHandler = (String) -> Void

struct EmojiRow: View {
    var emojis: [Emoji]
    var onHover: EmojiRowHoverHandler?
    var onClick: EmojiRowClickHandler?
    
    // TODO: track this at the ContentView level, so it can
    // be manipulated by keyboard events
    @State private var hoverId: String? = nil

    var body: some View {
        HStack {
            ForEach(self.emojis, id: \.id) { emoji in
                Text(emoji.glyph)
                    .frame(width: 24, height: 24)
                    .padding(.all, 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.blue, lineWidth: self.hoverId == emoji.id ? 2 : 0)
                    )
                    .onHover { isHovered in
                        self.hoverId = isHovered ? emoji.id : nil
                        if isHovered { self.onHover?(emoji) }
                    }
                    .onTapGesture { self.onClick?(emoji.glyph) }
            }
        }
    }
}

struct EmojiRow_Previews: PreviewProvider {
    static var previews: some View {
        EmojiRow(emojis: (1...11).map { _ in EmojiStore.shared.get("grinning")! }, onClick: handleClick)
            .previewLayout(.fixed(width: 300, height: 40))
    }
    
    static func handleClick(_ glyph: String) {
        print("clicked on emoji:", glyph)
    }
}
