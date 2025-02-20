import SwiftUI

struct LanguageSelection: View {
    @Binding var selectLanguage: Bool
    @EnvironmentObject var settings: Settings // Zugriff auf globale Einstellungen

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
                spacing: 12
            ) {
                ForEach(settings.availableLanguages.keys.sorted(), id: \.self) { languageCode in
                    if let language = settings.availableLanguages[languageCode] {
                        Button(action: {
                            settings.selectedLanguage = languageCode
                        }) {
                            VStack {
                                Text(language.flag)
                                    .font(.system(size: 60))

                                Text(language.name)
                                    .font(.subheadline)
                                    .foregroundColor(settings.selectedLanguage == languageCode ? .white : .primary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .background(settings.selectedLanguage == languageCode ? Color.blue : Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .animation(.easeInOut, value: settings.selectedLanguage)
                        }
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
        .frame(maxHeight: .infinity)
        .padding()
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}
