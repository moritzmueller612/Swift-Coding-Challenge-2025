import Foundation

class Settings: ObservableObject {
    @Published var speechManager = SpeechManager()
    @Published var selectedLanguage: String = "" {
        didSet {
            loadItems()
        }
    }
    @Published var systemLanguage: String = "en"
    @Published var targetItems: [Item] = [] {
        didSet {
            saveItems(for: selectedLanguage, words: targetItems)
        }
    }
    @Published var sourceItems: [Item] = []
    @Published var selectedFlag: String = "🇺🇸"
    @Published var availableLanguages: [String: Language] = [:]
    
    private var localizationData: [String: [String: [String: String]]] = [:]
    
    init() {
        loadLanguages()
        detectSystemLanguage()
        loadItems()
        loadLocalization()
        
        self.targetItems = getItems(for: selectedLanguage)
        self.sourceItems = getItems(for: systemLanguage)
    }
    
    private func detectSystemLanguage() {
        let systemLang = Locale.preferredLanguages.first ?? "en-US"
        let languageCode = String(systemLang.prefix(2))
        
        if availableLanguages.keys.contains(languageCode) {
            systemLanguage = languageCode
        } else {
            systemLanguage = "en"
        }
    }
    
    private func loadLanguages() {
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json") else {
            print("Fehler: JSON-Datei nicht gefunden")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(LanguageDictionary.self, from: data)
            
            DispatchQueue.main.async {
                self.availableLanguages = decodedData.languages
                
                for (code, language) in decodedData.languages {
                    let key = "items_\(code)"
                    
                    if UserDefaults.standard.data(forKey: key) == nil {
                        UserDefaults.standard.set(try? JSONEncoder().encode(language.words), forKey: key)
                    }
                }
                
                self.detectSystemLanguage()
            }
        } catch {
            print("Fehler beim Dekodieren der JSON-Daten:", error)
        }
    }
    
    public func saveItems(for language: String, words: [Item]) {
        do {
            let encodedData = try JSONEncoder().encode(words)
            UserDefaults.standard.set(encodedData, forKey: "items_\(language)")
        } catch {
            print("Fehler beim Speichern der Items für \(language):", error)
        }
    }
    
    public func getItems(for language: String) -> [Item] {
        if let savedData = UserDefaults.standard.data(forKey: "items_\(language)"),
           let savedItems = try? JSONDecoder().decode([Item].self, from: savedData) {
            return savedItems
        } else if let languageData = availableLanguages[language] {
            return languageData.words
        }
        return []
    }
    
    func loadItems() {
        self.targetItems = getItems(for: selectedLanguage)
        self.sourceItems = getItems(for: systemLanguage)
        self.selectedFlag = availableLanguages[selectedLanguage]?.flag ?? ""
    }
    
    func deleteItem(_ item: Item) {
        targetItems.removeAll { $0.id == item.id }
        saveItems(for: selectedLanguage, words: targetItems)
    }
    
    private func loadLocalization() {
        guard let url = Bundle.main.url(forResource: "localization", withExtension: "json") else {
            print("Fehler: Lokalisierungsdatei nicht gefunden")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode([String: [String: [String: String]]].self, from: data)
            self.localizationData = decodedData
        } catch {
            print("Fehler beim Dekodieren der Lokalisierungsdaten:", error)
        }
    }
    
    func localizedText(for key: String, in category: String) -> String {
        return localizationData[systemLanguage]?[category]?[key] ??
        localizationData["en"]?[category]?[key] ?? "MISSING_TEXT"
    }
    
    public func saveHighscore(for language: String, score: Int) {
        let key = "highscore_\(language)"
        UserDefaults.standard.set(score, forKey: key)
    }
    
    public func getHighscore(for language: String) -> Int {
        let key = "highscore_\(language)"
        return UserDefaults.standard.integer(forKey: key)
    }
    
    public func getWordCount(for language: String) -> Int {
        return getItems(for: language).count
    }
}
