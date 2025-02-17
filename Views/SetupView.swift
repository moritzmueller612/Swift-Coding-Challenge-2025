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
                .padding(.leading, 16)

                Spacer()

                Text("Vocabulary")
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
                .padding(.trailing, 16)
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            .background(
                VisualEffectBlurView(style: .systemMaterial) // **Modernes UI mit Blur-Effekt**
                    .edgesIgnoringSafeArea(.top)
            )

            // **Word List**
            ScrollView {
                VStack(spacing: 8) { // Weniger Abstand zwischen den Zeilen
                    ForEach(settings.items) { item in
                        Button(action: {
                            let translation = item.translations[String(settings.selectedLanguage.split(separator: "-").first ?? "en")] ?? "No translation"
                            speak(translation) // 🔊 Text-to-Speech
                        }) {
                            HStack {
                                Text(item.image)
                                    .font(.system(size: 16)) // Kleinere Schriftgröße
                                    .padding(.leading, 10)

                                Spacer()

                                Text(item.translations[String(settings.selectedLanguage.split(separator: "-").first ?? "en")] ?? "No translation")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)

                                Image(systemName: "speaker.wave.2.fill") // 🔊 Lautsprecher-Icon
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                            }
                            .frame(height: 50) // Kleinere Zeilenhöhe
                            .background(Color(.systemGray5)) // **Mehr Kontrast im Light Mode**
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 5)
            }
            
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
    
    // **🔊 Text-to-Speech**
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: settings.selectedLanguage)
        utterance.rate = 0.5
        
        speechSynthesizer.speak(utterance)
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
