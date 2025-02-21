import SwiftUI
import AVFoundation

@available(iOS 18.0, *)
struct SetupView: View {
    @Binding var setupComplete: Bool
    @Binding var selectLanguage: Bool
    @EnvironmentObject var settings: Settings

    @State private var showAddWordOverlay = false // Overlay für neue Wörter
    private let speechSynthesizer = AVSpeechSynthesizer() // 🔊 Text-to-Speech-Engine

    var body: some View {
        VStack {
            // **Navigation Bar Look**
            HStack {
                // 🔙 **Back Button**
                Button(action: {
                    selectLanguage = true
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(12)

                Spacer()

                Text("\(settings.selectedFlag) \(settings.availableLanguages[settings.selectedLanguage]?.name ?? "")")
                    .font(.system(size: 18, weight: .medium))

                Spacer()

                // ➕ **Add Word Button**
                Button(action: {
                    showAddWordOverlay = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(12)
            }
            .background(
                VisualEffectBlurView(style: .systemMaterial)
                    .edgesIgnoringSafeArea(.top)
                    .allowsHitTesting(false) // ✅ Blur-View blockiert keine Klicks mehr
            )

            // **Word List mit optimierter Breite**
            List {
                ForEach(settings.items) { item in
                    HStack {
                        // **Links: Emoji + Wort in der System-Sprache**
                        HStack {
                            Text(item.emoji) // ✅ Emoji
                                .font(.system(size: 24))

                            // 🔍 **Das Wort in der System-Sprache finden**
                            Text(getSystemLanguageWord(for: item.word))
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // **Rechts: Übersetztes Wort + Speaker**
                        HStack {
                            Text(item.translation) // ✅ Übersetztes Wort
                                .font(.system(size: 18))
                                .foregroundColor(.primary)

                            Button(action: {
                                speak(item.translation) // ✅ Vorlesen
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 18))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped) // **Apple-Style**
            
            Spacer()

            // **Start Game Button**
            Button(action: {
                setupComplete = true
            }) {
                Text("Start Game")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            }
            .padding(.bottom, 15)
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .overlay(
            AddWordView(isPresented: $showAddWordOverlay, settings: settings)
        )
    }

    // **🔍 Hol das Wort in der System-Sprache**
    // **🔍 Hol das Wort in der System-Sprache**
    private func getSystemLanguageWord(for englishWord: String) -> String {
        guard let systemLangWords = settings.availableLanguages[settings.systemLanguage]?.words else {
            print("⚠️ System-Sprache nicht gefunden:", settings.systemLanguage)
            return "Unknown" // ❌ Falls die Sprache nicht existiert
        }

        // **Wort in der System-Sprache suchen**
        if let wordEntry = systemLangWords.first(where: { $0.word == englishWord }) {
            return wordEntry.translation
        } else {
            print("❌ Kein Eintrag gefunden für: \(englishWord)")
        }

        return "Unknown" // ❌ Falls kein Eintrag gefunden wurde
    }
    // **🔊 Text-to-Speech**
    private func speak(_ text: String) {
        speechSynthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: settings.selectedLanguage)
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }

    // **🗑 Löschen eines Elements**
    private func deleteItem(_ item: Item) {
        settings.items.removeAll { $0.id == item.id }
    }
}

// **Blur View für Navigation Bar**
struct VisualEffectBlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
