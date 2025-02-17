import Foundation

class Settings: ObservableObject {
    @Published var selectedLanguage: String = ""
    @Published var items: [Item] = []    
    init() {
        loadItems()
    }
    
    func loadItems() {
        // Angenommen, die JSON-Datei heißt "vocabulary.json" und ist im Bundle
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json") else {
            print("JSON-Datei nicht gefunden")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedItems = try JSONDecoder().decode([Item].self, from: data)
            self.items = decodedItems
        } catch {
            print("Fehler beim Decodieren der Items: \(error)")
        }
    }
}
