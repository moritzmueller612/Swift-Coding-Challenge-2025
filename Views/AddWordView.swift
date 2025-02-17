import SwiftUI
import Translation

@available(iOS 18.0, *)
struct AddWordView: View {
    @Binding var isPresented: Bool
    @ObservedObject var settings: Settings

    @State private var newWord = "" // Eingabewort
    @State private var translatedWord = "" // Übersetztes Wort
    @State private var configuration: TranslationSession.Configuration?

    var body: some View {
        if isPresented {
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    Text("Add New Word")
                        .font(.headline)
                        .padding(.top, 10)

                    // **🌍 Eingabefeld für das Original-Wort**
                    TextField("Enter word...", text: $newWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    // **🔄 Übersetzungs-Button**
                    Button("Translate") {
                        triggerTranslation()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    // **🎯 Übersetztes Wort anzeigen**
                    Text(translatedWord)
                        .font(.title2)
                        .foregroundColor(.gray)

                    HStack {
                        // ❌ **Abbrechen-Button**
                        Button("Cancel") {
                            isPresented = false
                            newWord = ""
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)

                        // ✅ **Hinzufügen-Button**
                        Button("Add") {
                            addNewWord()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(newWord.isEmpty || translatedWord.isEmpty) // Verhindert leere Einträge
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(40)

                Spacer()
            }
            .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
            // 🎯 **Übersetzung durchführen, sobald `configuration` gesetzt ist**
            .translationTask(configuration) { session in
                do {
                    let response = try await session.translate(newWord)
                    translatedWord = response.targetText // Speichert die korrekte Übersetzung
                } catch {
                    print("Translation failed: \(error)")
                }
            }
        }
    }

    // 🌍 **Trigger Übersetzung**
    private func triggerTranslation() {
        guard configuration == nil else {
            configuration?.invalidate()
            return
        }

        // 💡 Sprache explizit setzen:
        let sourceLang = "en" // Standard-Eingabesprache
        let targetLang = settings.selectedLanguage // Gewählte Sprache des Nutzers

        configuration = .init(source: Locale.Language(identifier: sourceLang),
                              target: Locale.Language(identifier: targetLang))
    }

    // **📌 Wort speichern**
    private func addNewWord() {
        guard !newWord.isEmpty, !translatedWord.isEmpty else { return }

        let newItem = Item(
            id: UUID(),
            name: newWord,
            image: newWord.capitalized,
            translations: [settings.selectedLanguage: translatedWord] // Richtig übersetzt speichern
        )

        settings.items.append(newItem)
        newWord = "" // Eingabe zurücksetzen
        translatedWord = ""
        isPresented = false
    }
}
