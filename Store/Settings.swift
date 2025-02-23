import Foundation

class Settings: ObservableObject {
    @Published var speechManager = SpeechManager()
    
    // Stores the selected language, triggers item loading when changed
    @Published var selectedLanguage: String = "" {
        didSet {
            loadItems()
        }
    }
    
    // Stores the system's default language
    @Published var systemLanguage: String = "en"
    
    // List of vocabulary items in the selected language
    @Published var targetItems: [Item] = [] {
        didSet {
            saveItems(for: selectedLanguage, words: targetItems)
        }
    }
    
    // List of vocabulary items in the system language
    @Published var sourceItems: [Item] = []
    
    // Stores the selected flag emoji for the language
    @Published var selectedFlag: String = "🇺🇸"
    
    // Stores available languages with their metadata (flag, name, words)
    @Published var availableLanguages: [String: Language] = [:]
    
    // Stores localization data for UI text translations
    private var localizationData: [String: [String: [String: String]]] = [:]
    
    init() {
        loadLanguages()
        detectSystemLanguage()
        loadItems()
        loadLocalization()
        
        self.targetItems = getItems(for: selectedLanguage)
        self.sourceItems = getItems(for: systemLanguage)
    }
    
    // Detects the system language and sets it as default
    private func detectSystemLanguage() {
        let systemLang = Locale.preferredLanguages.first ?? "en-US"
        let languageCode = String(systemLang.prefix(2))
        
        if availableLanguages.keys.contains(languageCode) {
            systemLanguage = languageCode
        } else {
            systemLanguage = "en"
        }
    }
    
    // Loads language data from the bundled JSON file
    private func loadLanguages() {
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json") else {
            print("Error: Vocabulary JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(LanguageDictionary.self, from: data)
            
            DispatchQueue.main.async {
                self.availableLanguages = decodedData.languages
                
                // Ensures vocabulary data is only set once in UserDefaults
                for (code, language) in decodedData.languages {
                    let key = "items_\(code)"
                    
                    if UserDefaults.standard.data(forKey: key) == nil {
                        UserDefaults.standard.set(try? JSONEncoder().encode(language.words), forKey: key)
                    }
                }
                
                self.detectSystemLanguage()
            }
        } catch {
            print("Error decoding vocabulary JSON:", error)
        }
    }
    
    // Saves the vocabulary list for a specific language in UserDefaults
    public func saveItems(for language: String, words: [Item]) {
        do {
            let encodedData = try JSONEncoder().encode(words)
            UserDefaults.standard.set(encodedData, forKey: "items_\(language)")
        } catch {
            print("Error saving items for \(language):", error)
        }
    }
    
    // Retrieves the vocabulary list for a given language
    public func getItems(for language: String) -> [Item] {
        if let savedData = UserDefaults.standard.data(forKey: "items_\(language)"),
           let savedItems = try? JSONDecoder().decode([Item].self, from: savedData) {
            return savedItems
        } else if let languageData = availableLanguages[language] {
            return languageData.words
        }
        return []
    }
    
    // Loads vocabulary items based on the selected and system language
    func loadItems() {
        self.targetItems = getItems(for: selectedLanguage)
        self.sourceItems = getItems(for: systemLanguage)
        self.selectedFlag = availableLanguages[selectedLanguage]?.flag ?? ""
    }
    
    // Deletes a specific word from the vocabulary list
    func deleteItem(_ item: Item) {
        targetItems.removeAll { $0.id == item.id }
        saveItems(for: selectedLanguage, words: targetItems)
    }
    
    // Loads localization data for UI text
    private func loadLocalization() {
        guard let url = Bundle.main.url(forResource: "localization", withExtension: "json") else {
            print("Error: Localization file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode([String: [String: [String: String]]].self, from: data)
            self.localizationData = decodedData
        } catch {
            print("Error decoding localization data:", error)
        }
    }
    
    // Retrieves localized text for UI elements
    func localizedText(for key: String, in category: String) -> String {
        return localizationData[systemLanguage]?[category]?[key] ??
        localizationData["en"]?[category]?[key] ?? "MISSING_TEXT"
    }
    
    // Saves the high score for a specific language
    public func saveHighscore(for language: String, score: Int) {
        let key = "highscore_\(language)"
        UserDefaults.standard.set(score, forKey: key)
    }
    
    // Retrieves the saved high score for a specific language
    public func getHighscore(for language: String) -> Int {
        let key = "highscore_\(language)"
        return UserDefaults.standard.integer(forKey: key)
    }
    
    // Returns the total number of saved words for a specific language
    public func getWordCount(for language: String) -> Int {
        return getItems(for: language).count
    }
}
