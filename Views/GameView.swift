import SwiftUI
import AVFAudio
import SpriteKit

struct GameView: View {
    @State private var score: Int = 0
    @State private var animateScore = false
    @State private var showInfoText = true
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
                
                VStack {
                    HStack {
                        Text(settings.availableLanguages[settings.selectedLanguage]?.flag ?? "🌍")
                            .font(.system(size: 32))
                        
                        Spacer()
                        
                        Text("\(settings.localizedText(for: "score", in: "gameView")) \(score)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(animateScore ? .yellow : .white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(animateScore ? 1.0 : 0.8))
                                    .shadow(color: .blue.opacity(0.5), radius: animateScore ? 10 : 4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .scaleEffect(animateScore ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: animateScore)
                        
                        Spacer()
                        
                        Button(action: {
                            setupComplete = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)
                                .padding(.vertical)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    if showInfoText {
                        Text(settings.localizedText(for: "info", in: "gameView"))
                            .foregroundColor(Color.secondary)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 2.5), value: showInfoText)
                            .padding()
                    }
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
        animateScore = true
        
        if score == 1 {
            withAnimation {
                showInfoText = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animateScore = false
        }
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
