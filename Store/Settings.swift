import Foundation

class Settings: ObservableObject {
    @Published var selectedLanguage: String = "en-US" {
        didSet {
            loadItems() // ✅ Wörter sofort neu laden, wenn sich die Sprache ändert
        }
    }
    @Published var items: [Item] = [] // ❗ Nur das Array der Wörter für die ausgewählte Sprache

    init() {
        loadItems()
    }

    func loadItems() {
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json") else {
            print("❌ JSON-Datei nicht gefunden")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            
            // ✅ Dekodiere das vollständige JSON
            let decodedData = try JSONDecoder().decode(LanguageDictionary.self, from: data)
            
            // ✅ Prüfe, ob die gewählte Sprache existiert und speichere nur die Wörter
            if let languageData = decodedData.languages[selectedLanguage] {
                DispatchQueue.main.async {
                    self.items = languageData.words
                }
                print("✅ Geladene Wörter für \(selectedLanguage):", self.items)
            } else {
                print("⚠️ Keine Einträge für Sprache \(selectedLanguage) gefunden")
                self.items = []
            }

        } catch {
            print("❌ Fehler beim Dekodieren der Items:", error)
        }
    }
}
