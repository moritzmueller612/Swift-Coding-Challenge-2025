import Foundation

// Modell für die Vokabeln
struct Item: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case name
        case image
        case translations
    }
    
    var id = UUID() // Eindeutige ID für SwiftUI-Integration
    let name: String
    let image: String
    let translations: [String: String]
}
