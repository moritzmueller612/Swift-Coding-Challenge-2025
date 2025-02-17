import SpriteKit

class Bubble: SKShapeNode {
    private let radius: CGFloat
    private var recognizedText: String = ""
    private var isCorrect = false // Neu: Speichert, ob die Antwort richtig war
    private let correctItem: Item
    private weak var speechRecognizer: SpeechRecognizer?
    private var onCorrectAnswer: (() -> Void)?
    private let settings: Settings
    
    init(sceneSize: CGSize, radius: CGFloat, settings: Settings, speechRecognizer: SpeechRecognizer, onCorrectAnswer: (() -> Void)?) {
        guard let randomItem = settings.items.randomElement() else {
            fatalError("No visible items available in settings")
        }
        
        self.radius = radius
        self.correctItem = randomItem
        self.speechRecognizer = speechRecognizer
        self.onCorrectAnswer = onCorrectAnswer
        self.settings = settings
        super.init()
        
        self.isUserInteractionEnabled = true
        
        updatePath(forPercentage: 1.0)
        self.position = CGPoint(x: CGFloat.random(in: radius...(sceneSize.width - radius * 2)), y: -radius)
        self.strokeColor = .blue
        self.lineWidth = 5.0
        self.fillColor = .white
        
        renderItem(randomItem: randomItem, radius: radius)
        moveUp(sceneSize: sceneSize)
        displayRecognizedText()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func renderItem(randomItem: Item, radius: CGFloat) {
        let itemImage = SKSpriteNode(imageNamed: randomItem.image)
        itemImage.size = CGSize(width: radius * 1.5, height: radius * 1.5)
        itemImage.position = CGPoint(x: 0, y: 0)
        addChild(itemImage)
    }
    
    private func moveUp(sceneSize: CGSize) {
        let totalDuration: TimeInterval = 8.0
        let numberOfWaves = Int.random(in: 4...6)
        let waveDuration = totalDuration / Double(numberOfWaves)
        
        var actions: [SKAction] = []
        for _ in 0..<numberOfWaves {
            let verticalMove = SKAction.moveBy(x: 0, y: sceneSize.height / CGFloat(numberOfWaves), duration: waveDuration)
            let horizontalOffset = CGFloat.random(in: -50...50)
            let horizontalMove = SKAction.moveBy(x: horizontalOffset, y: 0, duration: waveDuration)
            let waveMove = SKAction.group([verticalMove, horizontalMove])
            actions.append(waveMove)
        }
        
        let removeAction = SKAction.removeFromParent()
        actions.append(removeAction)
        
        let sequence = SKAction.sequence(actions)
        self.run(sequence, withKey: "moveUp")
    }
    
    private func displayRecognizedText() {
        if let existingTextNode = childNode(withName: "recognizedText") as? SKLabelNode {
            existingTextNode.removeFromParent()
        }
        
        let textNode = SKLabelNode(text: recognizedText)
        textNode.fontSize = 18
        textNode.fontColor = .black
        textNode.fontName = "SFProText-Bold"
        textNode.position = CGPoint(x: 0, y: radius + 10)
        textNode.name = "recognizedText"
        addChild(textNode)
    }
    
    func updateRecognizedText(newText: String) {
        let correctAnswer = correctItem.translations[String(settings.selectedLanguage.split(separator: "-").first ?? "en")] ?? "Keine Sprache eingestellt"
        print("Correct Word: \(correctAnswer)")
        
        recognizedText = newText
        displayRecognizedText()
        
        if newText.lowercased().contains(correctAnswer.lowercased()) {
            onCorrectAnswer?()
            print("✅ Correct answer!")
            
            isCorrect = true // Bubble bleibt stehen
            
            if let existingItemImage = childNode(withName: "itemImage") as? SKSpriteNode {
                existingItemImage.removeFromParent()
            }
            
            let checkmark = SKSpriteNode(imageNamed: "right")
            checkmark.size = CGSize(width: radius * 1.5, height: radius * 1.5)
            checkmark.position = CGPoint(x: 0, y: 0)
            checkmark.name = "checkmark"
            addChild(checkmark)
            
            let wait = SKAction.wait(forDuration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            
            self.run(SKAction.sequence([wait, fadeOut, remove])) // Bubble verschwindet
        }
    }
    
    private func updatePath(forPercentage percentage: CGFloat) {
        let startAngle: CGFloat = CGFloat.pi / 2 // Start bei 12 Uhr
        let endAngle: CGFloat = startAngle - (CGFloat.pi * 2 * percentage) // Gegen den Uhrzeigersinn
        
        let backgroundPath = CGMutablePath()
        backgroundPath.addArc(
            center: CGPoint.zero,
            radius: radius, // Innenkreis bleibt gleich
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        
        let borderRadius: CGFloat = radius + 6 // Border etwas größer machen
        let progressPath = CGMutablePath()
        progressPath.addArc(
            center: CGPoint.zero,
            radius: borderRadius, // Äußerer Kreis
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        // **Hintergrund-Bubble (weiß) → bleibt konstant**
        if childNode(withName: "backgroundBubble") == nil {
            let backgroundBubble = SKShapeNode(path: backgroundPath)
            backgroundBubble.fillColor = .white
            backgroundBubble.strokeColor = .clear // Kein Rand
            backgroundBubble.zPosition = -1 // Hintergrund
            backgroundBubble.name = "backgroundBubble"
            addChild(backgroundBubble)
        }
        
        // **Dynamischer Farbwechsel von Blau → Orange → Rot**
        let startColor = UIColor.blue
        let midColor = UIColor.orange
        let endColor = UIColor.red
        let interpolatedColor: UIColor
        
        if percentage > 0.5 {
            // Erste Hälfte: Blau → Orange
            let factor = (1 - percentage) * 2 // Wertebereich von 0 bis 1
            interpolatedColor = interpolateColor(from: startColor, to: midColor, factor: factor)
        } else {
            // Zweite Hälfte: Orange → Rot
            let factor = (1 - (percentage * 2)) // Wertebereich von 0 bis 1
            interpolatedColor = interpolateColor(from: midColor, to: endColor, factor: factor)
        }
        
        // **Progress Border**
        if let existingBorder = childNode(withName: "progressBorder") as? SKShapeNode {
            existingBorder.path = progressPath
            existingBorder.strokeColor = interpolatedColor // Dynamischer Farbverlauf
            existingBorder.lineWidth = 5.0 // Feste Breite
        } else {
            let borderNode = SKShapeNode(path: progressPath)
            borderNode.strokeColor = interpolatedColor
            borderNode.lineWidth = 5.0
            borderNode.fillColor = .clear
            borderNode.name = "progressBorder"
            borderNode.zPosition = 1 // Oberhalb der Bubble
            addChild(borderNode)
        }
    }
    
    private func interpolateColor(from start: UIColor, to end: UIColor, factor: CGFloat) -> UIColor {
        var sR: CGFloat = 0, sG: CGFloat = 0, sB: CGFloat = 0, sA: CGFloat = 0
        var eR: CGFloat = 0, eG: CGFloat = 0, eB: CGFloat = 0, eA: CGFloat = 0
        
        start.getRed(&sR, green: &sG, blue: &sB, alpha: &sA)
        end.getRed(&eR, green: &eG, blue: &eB, alpha: &eA)
        
        let newR = sR + (eR - sR) * factor
        let newG = sG + (eG - sG) * factor
        let newB = sB + (eB - sB) * factor
        let newA = sA + (eA - sA) * factor
        
        return UIColor(red: newR, green: newG, blue: newB, alpha: newA)
    }
    
    private func startTimer() {
        let timerDuration: TimeInterval = 3.0
        
        // Timer-Animation (läuft für 3 Sekunden)
        let animation = SKAction.customAction(withDuration: timerDuration) { [weak self] _, elapsedTime in
            let percentage = CGFloat(1.0 - elapsedTime / CGFloat(timerDuration))
            self?.updatePath(forPercentage: percentage)
        }
        
        // Direkt nach der Animation prüfen, ob das Wort richtig war
        let checkResult = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            // Falls die Antwort richtig war → Bubble bleibt stehen
            if self.isCorrect {
                return
            }
            
            // ❌ Falls die Antwort falsch war → Zeige sofort das Kreuz
            self.showFeedback(correct: false)
            
            // ⏳ Warte 1 Sekunde, bevor die Bubble fällt
            let wait = SKAction.wait(forDuration: 1.0)
            
            // Bubble fallen lassen nach 1 Sekunde
            let fallDistance = abs(self.position.y) + self.radius
            let fallDuration: TimeInterval = 1.0
            let fallAction = SKAction.moveBy(x: 0, y: -fallDistance, duration: fallDuration)
            fallAction.timingMode = .easeIn
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            
            let fallSequence = SKAction.sequence([wait, fallAction, fadeOut, remove])
            self.run(fallSequence)
        }
        
        // **Richtiger Ablauf:**
        // 1️⃣ Path-Animation läuft für 3 Sekunden
        // 2️⃣ Direkt danach → Falls falsch, zeige das rote Kreuz
        // 3️⃣ ⏳ Warte 1 Sekunde
        // 4️⃣ Bubble fällt nach unten
        let sequence = SKAction.sequence([animation, checkResult])
        self.run(sequence)
    }
    
    private func showFeedback(correct: Bool) {
        let feedbackImage = correct ? "right" : "wrong"
        print(correct ? "✅ Correct answer!" : "❌ Wrong answer!")
        
        if let existingItemImage = childNode(withName: "itemImage") as? SKSpriteNode {
            existingItemImage.removeFromParent()
        }
        if let existingFeedback = childNode(withName: "feedback") as? SKSpriteNode {
            existingFeedback.removeFromParent()
        }
        
        let feedbackNode = SKSpriteNode(imageNamed: feedbackImage)
        feedbackNode.size = CGSize(width: radius * 1.5, height: radius * 1.5)
        feedbackNode.position = CGPoint(x: 0, y: 0)
        feedbackNode.name = "feedback"
        addChild(feedbackNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeAction(forKey: "moveUp")
        startTimer()
        
        let oldText = speechRecognizer?.recognizedText ?? ""
        
        speechRecognizer?.onResult = { [weak self] newText in
            guard let self = self else { return }
            
            let newPart = self.extractNewText(oldText: oldText, newText: newText)
            
            if !newPart.isEmpty {
                self.recognizedText = newPart
                self.updateRecognizedText(newText: self.recognizedText)
                self.displayRecognizedText()
            }
        }
        
        if speechRecognizer?.isRecording == false {
            speechRecognizer?.startListening()
        }
    }
    
    private func extractNewText(oldText: String, newText: String) -> String {
        guard newText.count > oldText.count else { return newText }
        
        let startIndex = newText.index(newText.startIndex, offsetBy: oldText.count)
        let newPart = String(newText[startIndex...])
        return newPart.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
