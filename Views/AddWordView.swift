import SwiftUI

struct AddWordView: View {
    @Binding var isPresented: Bool
    @ObservedObject var settings: Settings
    
    @State private var newWord = ""
    @State private var translatedWord = ""
    @State private var emoji = "🌎"
    @State private var showEmojiPicker = false
    
    var body: some View {
        if isPresented {
            ZStack {
                VisualEffectBlurView(style: .systemThinMaterial)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black.opacity(0.3))
                    .onTapGesture { resetFields() }
                
                VStack {
                    Spacer()
                    
                    ZStack(alignment: .top) {
                        VStack {
                            HStack {
                                Text(settings.localizedText(for: "headline", in: "addNewWord"))
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(action: { resetFields() }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            HStack(spacing: 15) {
                                Button(action: {
                                    showEmojiPicker.toggle()
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 40))
                                        .frame(width: 60, height: 60)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                }
                                
                                VStack(spacing: 10) {
                                    HStack {
                                        TextField(settings.localizedText(for: "word", in: "addNewWord"), text: $newWord)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                        
                                        Text(settings.availableLanguages[settings.systemLanguage]?.flag ?? "🌍")
                                            .font(.system(size: 24))
                                    }
                                    
                                    HStack {
                                        TextField(settings.localizedText(for: "translation", in: "addNewWord"), text: $translatedWord)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                        
                                        Text(settings.availableLanguages[settings.selectedLanguage]?.flag ?? "🌍")
                                            .font(.system(size: 24))
                                    }
                                }
                            }
                            .padding()
                            
                            Button(action: addNewWord) {
                                Text(settings.localizedText(for: "button", in: "addNewWord"))
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(newWord.isEmpty || translatedWord.isEmpty ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                                    .opacity(newWord.isEmpty || translatedWord.isEmpty ? 0.6 : 1)
                            }
                            .disabled(newWord.isEmpty || translatedWord.isEmpty)
                        }
                        .padding()
                        .frame(maxWidth: 500)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 12)
                        .transition(.scale)
                        .padding()
                    }
                    Spacer()
                }
                
                if showEmojiPicker {
                    EmojiPicker(selectedEmoji: $emoji, isPresented: $showEmojiPicker, settings: settings)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: isPresented)
        }
    }
    
    private func addNewWord() {
        guard !newWord.isEmpty, !translatedWord.isEmpty else { return }
        
        let newTargetItem = Item(
            id: UUID(),
            word: newWord,
            translation: translatedWord,
            emoji: emoji
        )
        
        settings.targetItems.append(newTargetItem)
        settings.saveItems(for: settings.selectedLanguage, words: settings.targetItems)
        
        if !settings.sourceItems.contains(where: { $0.word == translatedWord }) {
            let newSourceItem = Item(
                id: UUID(),
                word: translatedWord,
                translation: newWord,
                emoji: emoji
            )
            settings.sourceItems.append(newSourceItem)
            settings.saveItems(for: settings.systemLanguage, words: settings.sourceItems)
        }
        
        resetFields()
    }
    
    private func resetFields() {
        newWord = ""
        translatedWord = ""
        emoji = "🌍"
        isPresented = false
    }
}
