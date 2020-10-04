//
//  EmojiCell.swift
//  bmoji
//
//  Created by Aaron Ross on 10/2/20.
//

import SwiftUI

typealias EmojiRowHoverHandler = (Int, Int) -> Void
typealias EmojiRowClickHandler = (Emoji) -> Void

struct EmojiRow: View {
    
    var rowIdx: Int
    var activeIdx: Int? = nil
    
    var emojis: [Emoji]
    
    var onHover: EmojiRowHoverHandler?
    var onClick: EmojiRowClickHandler?
    
    var body: some View {
        HStack {
            ForEach(self.emojis.indices, id: \.self) { idx in
                Text(self.emojis[idx].glyph)
                    .frame(width: 24, height: 24)
                    .padding(.all, 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.blue, lineWidth: self.activeIdx == idx ? 2 : 0)
                    )
                    .onHover { isHovered in if isHovered { self.onHover?(self.rowIdx, idx) } }
                    .onTapGesture { self.onClick?(self.emojis[idx]) }
            }
        }
    }
}

struct EmojiRow_Previews: PreviewProvider {
    static var previews: some View {
        EmojiRow(
            rowIdx: 0,
            emojis: (1...11).map { _ in EmojiStore.shared.get("grinning")! },
            onClick: handleClick
        )
        .previewLayout(.fixed(width: 300, height: 40))
    }
    
    static func handleClick(_ emoji: Emoji) {
        print("clicked on emoji:", emoji.glyph)
    }
}
