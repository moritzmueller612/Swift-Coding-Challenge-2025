import SwiftUI

struct Gameplay: View {
    @EnvironmentObject var settings: Settings
    @StateObject private var speechRecognizer: SpeechRecognizer
    
    init(settings: Settings) {
        _speechRecognizer = StateObject(wrappedValue: SpeechRecognizer(settings: settings))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            Text(speechRecognizer.recognizedText)
                .padding()
            
            Button(action: {
                if speechRecognizer.isRecording {
                    speechRecognizer.stopListening()
                } else {
                    speechRecognizer.startListening()
                }
            }) {
                Text(speechRecognizer.isRecording ? "Stop" : "Start")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        /*.onAppear {
            // Beim Erscheinen der View wird die Sprache aus den globalen Einstellungen übernommen
            speechRecognizer.updateLanguage(language: settings.selectedLanguage)
        }
        .onChange(of: settings.selectedLanguage) { oldLanguage, newLanguage in
            speechRecognizer.updateLanguage(language: newLanguage)
        }*/
    }
}
