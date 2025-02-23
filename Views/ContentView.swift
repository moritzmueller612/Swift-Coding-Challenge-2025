import SwiftUI

struct ContentView: View {
    // Controls whether the language selection screen is shown
    @State private var selectLanguage: Bool = true
    
    // Tracks if the setup process is complete
    @State private var setupComplete: Bool = false
    
    // Manages the app's settings and language-related data
    @StateObject var settings = Settings()
    
    var body: some View {
        ZStack {
            // Show the language selection screen if not yet selected
            if selectLanguage {
                LanguageSelection(selectLanguage: $selectLanguage)
                    .environmentObject(settings)
                    .transition(.opacity)
            } else {
                // If setup is complete, launch the game
                if setupComplete {
                    GameView(settings: settings, setupComplete: $setupComplete)
                        .environmentObject(settings)
                        .transition(.opacity)
                } 
                // Otherwise, show the setup screen
                else {
                    SetupView(setupComplete: $setupComplete, selectLanguage: $selectLanguage)
                        .environmentObject(settings)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: selectLanguage)
        .animation(.easeInOut(duration: 0.5), value: setupComplete)
    }
}
