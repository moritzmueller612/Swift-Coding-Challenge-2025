import SwiftUI
import Translation

@available(iOS 18.0, *)
struct AddWordView: View {
    @Binding var isPresented: Bool
    @ObservedObject var settings: Settings

    @State private var newWord = ""           // Eingabe-Wort
    @State private var translatedWord = ""    // Automatische Übersetzung
    @State private var emoji = ""             // Emoji für das Wort
    @State private var configuration: TranslationSession.Configuration?

    var body: some View {
        if isPresented {
            VStack {
                Spacer()

                VStack(spacing: 16) {
                    // 🏷 **Titel**
                    Text("Add New Word")
                        .font(.headline)
                        .padding(.top, 10)

                    // **🌍 Eingabefeld für das Original-Wort**
                    TextField("Enter word...", text: $newWord)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .autocapitalization(.none)

                    // **🎯 Übersetzung + Emoji in einer Reihe**
                    HStack {
                        // **Automatische Übersetzung**
                        TextField("Translation...", text: $translatedWord)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: .infinity)
                            .autocapitalization(.none)

                        // **Emoji-Eingabe**
                        TextField("Emoji", text: $emoji)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    // **🔄 Übersetzungs-Button**
                    Button(action: {
                        triggerTranslation()
                    }) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Translate")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    // **🟢 & ❌ Action Buttons**
                    HStack {
                        // ❌ **Cancel**
                        Button("Cancel") {
                            resetFields()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                        // ✅ **Add**
                        Button("Add") {
                            addNewWord()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(newWord.isEmpty || translatedWord.isEmpty || emoji.isEmpty ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(newWord.isEmpty || translatedWord.isEmpty || emoji.isEmpty)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(40)

                Spacer()
            }
            .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
            // **Automatische Übersetzung über `TranslationSession`**
            .translationTask(configuration) { session in
                do {
                    let response = try await session.translate(newWord)
                    translatedWord = response.targetText // Automatisch speichern
                } catch {
                    print("Translation failed: \(error)")
                }
            }
        }
    }

    // **🌍 Übersetzungs-Logik starten**
    private func triggerTranslation() {
        guard configuration == nil else {
            configuration?.invalidate()
            return
        }

        let sourceLang = "en" // Standard-Eingabesprache
        let targetLang = settings.selectedLanguage // Gewählte Sprache

        configuration = .init(source: Locale.Language(identifier: sourceLang),
                              target: Locale.Language(identifier: targetLang))
    }

    // **✅ Wort speichern**
    private func addNewWord() {
        guard !newWord.isEmpty, !translatedWord.isEmpty, !emoji.isEmpty else { return }

        let newItem = Item(
            id: UUID(),
            name: newWord,
            emoji: emoji
        )

        settings.items.append(newItem)
        resetFields()
    }

    // **🔄 Felder zurücksetzen**
    private func resetFields() {
        newWord = ""
        translatedWord = ""
        emoji = ""
        isPresented = false
    }
}
