import SwiftUI

struct SetupView: View {
    @Binding var setupComplete: Bool
    @Binding var selectLanguage: Bool
    @EnvironmentObject var settings: Settings
    
    @State private var showAddWordOverlay = false
    @State private var selectedItemID: UUID? = nil
    
    var body: some View {
        VStack {
            // Top navigation bar with language selection and add word button
            HStack {
                // Button to go back to language selection
                Button(action: {
                    selectLanguage = true
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(12)
                
                Spacer()
                
                // Display selected language flag and name
                Text("\(settings.selectedFlag) \(settings.availableLanguages[settings.selectedLanguage]?.name ?? "")")
                    .font(.system(size: 18, weight: .medium))
                
                Spacer()
                
                // Button to open add word overlay
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
                    .allowsHitTesting(false)
            )
            
            // Info text about the setup process
            Text(settings.localizedText(for: "info", in: "setupView"))
                .padding()
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 0)
            
            // List of saved vocabulary words
            List {
                ForEach(settings.targetItems) { item in
                    HStack {
                        HStack {
                            // Display emoji and translated word in system language
                            Text(item.emoji)
                                .font(.system(size: 24))
                            
                            Text(getSystemLanguageWord(for: item.word))
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            // Display translated word and speaker button
                            Text(item.translation)
                                .font(.system(size: 18))
                                .foregroundColor(.primary)
                            
                            // Button to play pronunciation
                            Button(action: {
                                settings.speechManager.speak(item.translation, in: settings.selectedLanguage)
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 18))
                            }
                            
                            // Delete button appears when an item is selected
                            if selectedItemID == item.id {
                                Button(action: {
                                    deleteItem(item)
                                    selectedItemID = nil
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .font(.system(size: 18))
                                }
                                .transition(.opacity)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    
                    // Swipe-to-delete functionality
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    
                    // Long-press context menu for deletion
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            Spacer()
            
            // Button to complete setup and start the game
            Button(action: {
                setupComplete = true
            }) {
                Text(settings.localizedText(for: "button", in: "setupView"))
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
        
        // Overlay to add new words
        .overlay(
            AddWordView(isPresented: $showAddWordOverlay, settings: settings)
        )
    }
    
    // Retrieves the system language translation for a given word
    private func getSystemLanguageWord(for sourceWord: String) -> String {
        if let wordEntry = settings.sourceItems.first(where: { $0.translation == sourceWord }) {
            return wordEntry.translation
        }
        
        if let systemLangWords = settings.availableLanguages[settings.systemLanguage]?.words,
           let wordEntry = systemLangWords.first(where: { $0.word == sourceWord }) {
            return wordEntry.translation
        }
        
        return "Unknown"
    }
    
    // Deletes an item from the vocabulary list
    private func deleteItem(_ item: Item) {
        settings.targetItems.removeAll { $0.id == item.id }
    }
}

// Custom blur effect for the background
struct VisualEffectBlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
