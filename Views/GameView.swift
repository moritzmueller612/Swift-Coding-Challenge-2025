import SwiftUI
import AVFAudio
import SpriteKit

struct GameView: View {
    @State private var score: Int = 0
    @Binding var setupComplete: Bool
    @EnvironmentObject var settings: Settings
    @StateObject private var speechRecognizer: SpeechRecognizer
    
    init(settings: Settings, setupComplete: Binding<Bool>) {
        _setupComplete = setupComplete
        _speechRecognizer = StateObject(wrappedValue: SpeechRecognizer(settings: settings))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Transparent background
                Color.clear.ignoresSafeArea()
                
                SpriteView(scene: makeScene(size: CGSize(width: geometry.size.width, height: geometry.size.height)))
                    .ignoresSafeArea()
                    .background(Color.clear)
                    .onAppear {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            if let skView = windowScene.windows.first?.rootViewController?.view.subviews.first(where: { $0 is SKView }) as? SKView {
                                skView.allowsTransparency = true
                                skView.backgroundColor = .clear
                            }
                        }
                    }
                    .onDisappear {
                        speechRecognizer.stopListening()
                        speechRecognizer.reset()
                    }
                
                // **OBERE LEISTE (Score & Schließen-Button)**
                VStack {
                    HStack {
                        Text("Score: \(score)")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: {
                            setupComplete = false // Zurück zur SetupView
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // **INFO TEXT UNTEN MITTE**
                    Text("Tap the Bubbles and say the words")
                        .foregroundColor(.black)
                        .font(.subheadline)
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            configureAudioSession()
            speechRecognizer.startListening()
        }
        .onDisappear {
            speechRecognizer.stopListening()
        }
    }
    
    private func makeScene(size: CGSize) -> SKScene {
        let scene = SoloPlayer(size: size)
        scene.settings = settings
        scene.speechRecognizer = speechRecognizer
        scene.scaleMode = .resizeFill
        
        scene.onCorrectAnswer = {
            self.increaseScore()
        }
        return scene
    }
    
    private func increaseScore() {
        score += 1
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print(error)
        }
    }
}
