import Foundation

// 🏷 Modell für ein einzelnes Wort
// 🏷 Modell für ein einzelnes Wort
struct Item: Codable, Identifiable {
    var id: UUID = UUID() // ✅ Automatisch generierte UUID
    let word: String
    let translation: String
    let emoji: String

    // ✅ Custom Initializer, um `id` beim Decoding zu setzen
    init(id: UUID, word: String, translation: String, emoji: String) {
        self.id = UUID()
        self.word = word
        self.translation = translation
        self.emoji = emoji
    }

    // ✅ Eigene `Decodable`-Logik, um `id` beim Laden zu generieren
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID() // ✅ Generiere eine neue UUID
        self.word = try container.decode(String.self, forKey: .word)
        self.translation = try container.decode(String.self, forKey: .translation)
        self.emoji = try container.decode(String.self, forKey: .emoji)
    }
}
// 📚 Modell für eine Sprache mit Name + Wörter
struct Language: Codable {
    let name: String
    let flag: String
    let words: [Item]
}

// 🌍 Modell für die gesamte JSON-Datei
struct LanguageDictionary: Codable {
    let languages: [String: Language] // 🔄 Jetzt auf Language statt [Item] angepasst
}
