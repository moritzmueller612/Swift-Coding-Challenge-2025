import SwiftUI

import SpriteKit
import SwiftUI

class SoloPlayer: SKScene {
    var settings: Settings?
    var speechRecognizer: SpeechRecognizer?
    var onCorrectAnswer: (() -> Void)?
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        
        guard let speechRecognizer = speechRecognizer else {
            print("Speech Recognition not available")
            return
        }
        
        guard let settings = settings else {
            print("Settings not available")
            return
        }
        
        // Starten des Bubble-Spawns
        startBubbleSpawning(speechRecognizer: speechRecognizer, onCorrectAnswer: onCorrectAnswer)
    }
    
    private func startBubbleSpawning(speechRecognizer: SpeechRecognizer, onCorrectAnswer: (() -> Void)?) {
        let spawnBubble = SKAction.run { [weak self] in
            guard let self = self else { return }
            let bubble = Bubble(sceneSize: self.size, radius: CGFloat.random(in: 24...36), settings: settings!, speechRecognizer: speechRecognizer, onCorrectAnswer: onCorrectAnswer)
            self.addChild(bubble)
        }
        
        let waitAction = SKAction.wait(forDuration: 2.0) // 2 Sekunden
        let spawnSequence = SKAction.sequence([spawnBubble, waitAction])
        let repeatSpawn = SKAction.repeatForever(spawnSequence)
        
        self.run(repeatSpawn, withKey: "spawnBubbles")
    }
}
