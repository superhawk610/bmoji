//
//  Emoji.swift
//  bmoji
//
//  Created by Aaron Ross on 10/2/20.
//

import Cocoa
import Fuse
import SwiftyJSON

struct Emoji: Identifiable, Equatable {
    static func == (lhs: Emoji, rhs: Emoji) -> Bool { lhs.id == rhs.id }
    
    var id: String
    var glyph: String
    var category: String
    var keywords: [String]
    
    // whether or not the emoji supports the Fitzpatrick scale (skin tones)
    // TODO: enable Fitzpatrick tone selection
    var fitz: Bool = false
    
    init(fromJson json: JSON) {
        self.id = json["key"].stringValue
        self.glyph = json["glyph"].stringValue
        self.category = json["category"].stringValue
        self.keywords = json["keywords"].arrayValue.map { $0.stringValue }
    }
}

class EmojiStore: ObservableObject {
    
    // MARK: - Properties
    
    static let shared = EmojiStore()
    static let scoreThreshold = 0.22
    
    // MARK: -
    
    private(set) var emojis: [Emoji] = []
    
    // Initialization
    
    init() {
        guard
            let path = Bundle.main.path(forResource: "emoji", ofType: "json")
        else {
            print("Unable to load emoji.json")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSON(data: data)
            self.emojis = json.arrayValue.map { Emoji(fromJson: $0) }
        } catch {
            print("error parsing JSON")
            print(error)
        }
    }
    
    // MARK: - Methods
    
    func get(_ key: String) -> Emoji? {
        self.emojis.first(where: { $0.id == key })
    }
    
    func querySync(_ query: String) -> [Emoji] {
        if query == "" { return self.emojis }
        
        let fuse = Fuse()
        let pattern = fuse.createPattern(from: query)
        
        let scored: [(Double?, Emoji?)] = self.emojis
            .map { emoji in
                let res = fuse.search(pattern, in: emoji.id)
                if res?.score ?? 1 < EmojiStore.scoreThreshold { return (res?.score, emoji) }
                
                for keyword in emoji.keywords {
                    let res = fuse.search(pattern, in: keyword)
                    if res?.score ?? 1 < EmojiStore.scoreThreshold { return (res?.score, emoji) }
                }
                
                return (nil, nil)
            }
        
        let filtered = scored.filter { (score, emoji) in emoji != nil }
        
        let sorted = filtered.sorted(by: { (a, b) in a.0! < b.0! })
        
        return sorted.map { (_, emoji) in emoji! }
    }
    
    func query(_ query: String, effect: @escaping (([Emoji]) -> ())) {
        DispatchQueue.global(qos: .userInitiated).async {
            let res = self.querySync(query)
            effect(res)
        }
    }
}
