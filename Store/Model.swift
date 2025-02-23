import Foundation

struct Item: Codable, Identifiable {
    var id: UUID = UUID()
    let word: String
    let translation: String
    let emoji: String

    init(id: UUID, word: String, translation: String, emoji: String) {
        self.id = UUID()
        self.word = word
        self.translation = translation
        self.emoji = emoji
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.word = try container.decode(String.self, forKey: .word)
        self.translation = try container.decode(String.self, forKey: .translation)
        self.emoji = try container.decode(String.self, forKey: .emoji)
    }
}

struct Language: Codable {
    let name: String
    let flag: String
    var words: [Item]
}


struct LanguageDictionary: Codable {
    let languages: [String: Language]
}
