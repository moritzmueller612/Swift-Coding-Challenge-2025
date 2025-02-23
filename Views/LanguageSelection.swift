import SwiftUI

struct LanguageSelection: View {
    @Binding var selectLanguage: Bool
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 12) {
                Text(settings.localizedText(for: "headline", in: "languageSelection"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(settings.localizedText(for: "info", in: "languageSelection"))
                    .multilineTextAlignment(.center)
            }
            .padding()
            
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
                        
                        ZStack() {
                            Button(action: {
                                settings.selectedLanguage = languageCode
                            }) {
                                VStack(spacing: 6) {
                                    Spacer()
                                    Text(language.flag)
                                        .font(.system(size: 60))
                                    
                                    Text(language.name)
                                        .font(.subheadline)
                                        .foregroundColor(settings.selectedLanguage == languageCode ? .white : .primary)
                                    
                                    Spacer(minLength: 5)
                                    
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
        .rotationEffect(.degrees(UIDevice.current.orientation.isLandscape ? 90 : 0))
    }
}
