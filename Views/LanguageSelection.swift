import SwiftUI

struct LanguageSelection: View {
    @Binding var selectLanguage: Bool
    @EnvironmentObject var settings: Settings // Zugriff auf globale Einstellungen

    let languages: [(code: String, name: String, flag: String)] = [
        ("es-ES", "Spanish", "🇪🇸"),
        ("it-IT", "Italian", "🇮🇹"),
        ("de-DE", "German", "🇩🇪"),
        ("fr-FR", "French", "🇫🇷"),
        ("sv-SE", "Swedish", "🇸🇪"),
        ("zh-CN", "Chinese", "🇨🇳")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Select Language")
                .font(.title2)
                .fontWeight(.semibold)
                .padding()

            // **Flaggen & Sprachen als Buttons**
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12 // Vertikaler Abstand zwischen Reihen
            ) {
                ForEach(languages, id: \.code) { language in
                    Button(action: {
                        settings.selectedLanguage = language.code
                    }) {
                        VStack {
                            Text(language.flag)
                                .font(.system(size: 60))

                            Text(language.name)
                                .font(.subheadline)
                                .foregroundColor(settings.selectedLanguage == language.code ? .white : .primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 120) // Volle Spaltenbreite nutzen
                        .background(settings.selectedLanguage == language.code ? Color.blue : Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .animation(.easeInOut, value: settings.selectedLanguage) // Sanfte Animation
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            // **Start-Button**
            Button(action: {
                selectLanguage = false
            }) {
                Text("Continue")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .frame(maxHeight: .infinity) // **Immer die gesamte Bildschirmhöhe nutzen**
        .padding()
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }

    private func languageDisplayName(language: String) -> String {
        languages.first { $0.code == language }?.name ?? "Unknown"
    }
}
