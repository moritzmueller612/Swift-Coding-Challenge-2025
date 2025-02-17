import SwiftUI

import SpriteKit
import SwiftUI

class SoloPlayer: SKScene {
    var settings: Settings?
    var speechRecognizer: SpeechRecognizer?
    var onCorrectAnswer: (() -> Void)?
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        if let image = UIImage(named: "IT 1") {
            let texture = SKTexture(image: image)
            let backgroundImage = SKSpriteNode(texture: texture)
            
            backgroundImage.zPosition = -10 // Ganz hinten
            backgroundImage.alpha = 0.5 // Transparenz setzen
            
            // **Größe berechnen für proportionale Skalierung**
            let screenAspect = size.width / size.height
            let imageAspect = texture.size().width / texture.size().height
            
            if screenAspect > imageAspect {
                // **Bild ist schmaler als der Bildschirm → an Breite anpassen**
                backgroundImage.size.width = size.width
                backgroundImage.size.height = size.width / imageAspect
            } else {
                // **Bild ist breiter als der Bildschirm → an Höhe anpassen**
                backgroundImage.size.height = size.height
                backgroundImage.size.width = size.height * imageAspect
            }
            
            backgroundImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
            
            addChild(backgroundImage)
        }
        
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
            let bubble = Bubble(sceneSize: self.size, radius: CGFloat.random(in: 30...50), settings: settings!, speechRecognizer: speechRecognizer, onCorrectAnswer: onCorrectAnswer)
            self.addChild(bubble)
        }
        
        let waitAction = SKAction.wait(forDuration: 2.0) // 2 Sekunden
        let spawnSequence = SKAction.sequence([spawnBubble, waitAction])
        let repeatSpawn = SKAction.repeatForever(spawnSequence)
        
        self.run(repeatSpawn, withKey: "spawnBubbles")
    }
}
