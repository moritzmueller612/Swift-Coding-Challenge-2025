import Foundation

class Settings: ObservableObject {
    @Published var selectedLanguage: String = "en-US" { // ✅ Standard: Englisch (US)
        didSet {
            loadItems() // ✅ Sprache wechseln → Wörter & Flagge neu laden
        }
    }
    @Published var items: [Item] = []
    @Published var selectedFlag: String = "🇺🇸" // ✅ Standard-Flagge für Englisch
    @Published var availableLanguages: [String: Language] = [:] // ✅ Alle Sprachen aus JSON speichern
    @Published var systemLanguage: String = "en-US"

    init() {
        loadLanguages() // ✅ Lädt verfügbare Sprachen
        loadItems()     // ✅ Lädt Wörter für die Standard-Sprache
    }

    /// **🔄 Lade alle Sprachen aus JSON**
    private func loadLanguages() {
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json") else {
            print("❌ JSON-Datei nicht gefunden")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(LanguageDictionary.self, from: data)

            DispatchQueue.main.async {
                self.availableLanguages = decodedData.languages
                print("✅ Geladene Sprachen:", self.availableLanguages.keys)
            }
        } catch {
            print("❌ Fehler beim Dekodieren der Sprachen:", error)
        }
    }

    /// **🛠 Speichern der Wörter in UserDefaults**
    private func saveItems() {
        do {
            let encodedData = try JSONEncoder().encode(items)
            UserDefaults.standard.set(encodedData, forKey: "items_\(selectedLanguage)")
        } catch {
            print("❌ Fehler beim Speichern der Items: \(error)")
        }
    }

    /// **🔄 Lade Wörter für die gewählte Sprache**
    func loadItems() {
        // **1️⃣ Prüfe, ob Daten in UserDefaults gespeichert sind**
        if let savedData = UserDefaults.standard.data(forKey: "items_\(selectedLanguage)"),
           let savedItems = try? JSONDecoder().decode([Item].self, from: savedData) {
            self.items = savedItems
            self.selectedFlag = availableLanguages[selectedLanguage]?.flag ?? "❓"
            print("✅ Geladene Wörter aus Speicher für \(selectedLanguage)")
            return
        }

        // **2️⃣ Falls nichts gespeichert ist → JSON laden**
        if let languageData = availableLanguages[selectedLanguage] {
            DispatchQueue.main.async {
                self.items = languageData.words
                self.selectedFlag = languageData.flag
            }
            print("✅ Geladene Wörter aus JSON für \(selectedLanguage):", self.items)
            print("✅ Flagge für \(selectedLanguage): \(self.selectedFlag)")
        } else {
            print("⚠️ Keine Einträge für Sprache \(selectedLanguage) gefunden")
            self.items = []
            self.selectedFlag = "❓" // ❗ Fallback-Flagge
        }
    }
}
