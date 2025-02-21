import Foundation

class Settings: ObservableObject {
    @Published var selectedLanguage: String = "en-US" { // ✅ Standard: Englisch (US)
        didSet {
            loadItems() // ✅ Sprache wechseln → Wörter & Flagge neu laden
        }
    }
    @Published var systemLanguage: String = "en" // 🌍 Automatisch erkannte Systemsprache (nur Sprachcode)
    @Published var items: [Item] = []
    @Published var selectedFlag: String = "🇺🇸" // ✅ Standard-Flagge für Englisch
    @Published var availableLanguages: [String: Language] = [:] // ✅ Alle Sprachen aus JSON speichern

    init() {
        loadLanguages() // ✅ Lädt verfügbare Sprachen
        detectSystemLanguage() // ✅ Erkenne System-Sprache
        loadItems()     // ✅ Lädt Wörter für die Standard-Sprache
    }

    /// **🔍 Erkennt die System-Sprache des Geräts, ohne `selectedLanguage` zu ändern**
    private func detectSystemLanguage() {
        let systemLang = Locale.preferredLanguages.first ?? "en-US" // 🌍 Hole erste bevorzugte Sprache
        let languageCode = String(systemLang.prefix(2)) // ✅ Nur die ersten zwei Buchstaben nehmen
        print("🌍 System-Sprache erkannt: \(systemLang), gespeichert als: \(languageCode)")

        // **Systemsprache speichern**
        if availableLanguages.keys.contains(where: { $0.hasPrefix(languageCode) }) {
            systemLanguage = languageCode // ✅ Falls Sprache existiert → Speichern
        } else {
            systemLanguage = "en" // ❗ Fallback auf Englisch
        }
    }

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

                // ✅ **Alle Wörter speichern, damit wir später auf die System-Sprache zugreifen können**
                for (code, language) in decodedData.languages {
                    UserDefaults.standard.set(try? JSONEncoder().encode(language.words), forKey: "items_\(code)")
                }

                self.detectSystemLanguage() // 🌍 **Systemsprache erst nach JSON laden prüfen**
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

    /// **🔄 Lade Wörter für die gewählte Sprache (`selectedLanguage`)**
    func loadItems() {
        if let savedData = UserDefaults.standard.data(forKey: "items_\(selectedLanguage)"),
           let savedItems = try? JSONDecoder().decode([Item].self, from: savedData) {
            self.items = savedItems
        } else if let languageData = availableLanguages[selectedLanguage] {
            self.items = languageData.words
        } else {
            self.items = [] // ❌ Falls nichts existiert
        }

        // ✅ Flagge sofort aktualisieren
        self.selectedFlag = availableLanguages[selectedLanguage]?.flag ?? ""
    }
}
