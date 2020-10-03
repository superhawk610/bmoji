//
//  ActiveEmojiView.swift
//  bmoji
//
//  Created by Aaron Ross on 10/2/20.
//

import SwiftUI

struct ActiveEmojiView: View {
    var emoji: Emoji
    
    var body: some View {
        VStack {
            Text("emoji")
            Text("keywords")
        }
    }
}

struct ActiveEmojiView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveEmojiView(emoji: EmojiStore.shared.get("grinning")!)
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
