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
                    .transition(.opacity)// Sanfter Slide-In-Effekt
            } else {
                if setupComplete {
                    GameView(settings: settings, setupComplete: $setupComplete)
                        .environmentObject(settings)
                        .transition(.opacity) // Weicher Überblendeffekt
                } else {
                    SetupView(setupComplete: $setupComplete, selectLanguage: $selectLanguage)
                        .environmentObject(settings)
                        .transition(.opacity) // Sanfter Slide-In von rechts
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: selectLanguage) // Dauer 0.5 Sek.
        .animation(.easeInOut(duration: 0.5), value: setupComplete)
    }
}
