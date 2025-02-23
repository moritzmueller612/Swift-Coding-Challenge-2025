import SwiftUI

struct ContentView: View {
    @State private var selectLanguage: Bool = true
    @State private var setupComplete: Bool = false
    @StateObject var settings = Settings()
    
    var body: some View {
        ZStack {
            if selectLanguage {
                LanguageSelection(selectLanguage: $selectLanguage)
                    .environmentObject(settings)
                    .transition(.opacity)
            } else {
                if setupComplete {
                    GameView(settings: settings, setupComplete: $setupComplete)
                        .environmentObject(settings)
                        .transition(.opacity)
                } else {
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
