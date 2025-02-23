import SwiftUI

struct LanguageSelection: View {
    @Binding var selectLanguage: Bool
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Title and description for language selection
            VStack(spacing: 12) {
                Text(settings.localizedText(for: "headline", in: "languageSelection"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(settings.localizedText(for: "info", in: "languageSelection"))
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            // Grid layout for displaying available languages
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(settings.availableLanguages.keys.sorted(), id: \.self) { languageCode in
                    if let language = settings.availableLanguages[languageCode],
                       !languageCode.contains(settings.systemLanguage) {
                        
                        ZStack {
                            // Language selection button
                            Button(action: {
                                settings.selectedLanguage = languageCode
                            }) {
                                VStack(spacing: 6) {
                                    Spacer()
                                    
                                    // Display language flag
                                    Text(language.flag)
                                        .font(.system(size: 60))
                                    
                                    // Display language name
                                    Text(language.name)
                                        .font(.subheadline)
                                        .foregroundColor(settings.selectedLanguage == languageCode ? .white : .primary)
                                    
                                    Spacer(minLength: 5)
                                    
                                    // Show highscore if available
                                    if settings.getHighscore(for: languageCode) > 0 {
                                        HighscoreBadge(
                                            score: settings.getHighscore(for: languageCode),
                                            text: settings.localizedText(for: "highscore", in: "languageSelection")
                                        )
                                    }
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: 132)
                                .padding()
                                .background(settings.selectedLanguage == languageCode ? Color.blue : Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    Group {
                                        // Show word count badge if words exist in the language
                                        if settings.getWordCount(for: languageCode) > 0 {
                                            WordCountBadge(count: settings.getWordCount(for: languageCode))
                                                .offset(x: -8, y: 8)
                                        }
                                    },
                                    alignment: .topTrailing
                                )
                                .animation(.easeInOut, value: settings.selectedLanguage)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Confirm button appears after a language is selected
            if !settings.selectedLanguage.isEmpty {
                Button(action: {
                    selectLanguage = false
                }) {
                    Text(settings.localizedText(for: "button", in: "languageSelection"))
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .transition(.opacity.combined(with: .scale))
                .animation(.easeInOut(duration: 0.3), value: settings.selectedLanguage)
            }
        }
        .frame(maxHeight: .infinity)
        .padding()
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}
