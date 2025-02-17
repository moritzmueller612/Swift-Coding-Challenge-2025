import SwiftUI

struct ContentView: View {
    @State private var selectLanguage: Bool = true
    @State private var setupComplete: Bool = false
    @StateObject var settings = Settings()
    
    @ViewBuilder
    var body: some View {
        if selectLanguage {
            LanguageSelection(selectLanguage: $selectLanguage)
                .environmentObject(settings)
        } else {
            if setupComplete {
                GameView(settings: settings, setupComplete: $setupComplete)
                    .environmentObject(settings)
            } else {
                SetupView(setupComplete: $setupComplete, selectLanguage: $selectLanguage)
                    .environmentObject(settings)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
