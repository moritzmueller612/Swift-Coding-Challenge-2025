import SpriteKit

class Bubble: SKShapeNode {
    private let radius: CGFloat
    private var recognizedText: String = ""
    private var isCorrect = false // Speichert, ob die Antwort richtig war
    private let correctItem: Item
    private weak var speechRecognizer: SpeechRecognizer?
    private var onCorrectAnswer: (() -> Void)?
    private let settings: Settings
    
    init(sceneSize: CGSize, radius: CGFloat, settings: Settings, speechRecognizer: SpeechRecognizer, onCorrectAnswer: (() -> Void)?) {
        guard let randomItem = settings.targetItems.randomElement() else {
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
        self.strokeColor = UIColor.blue
        self.lineWidth = 5.0
        self.fillColor = .white
        
        renderItem(randomItem: randomItem, radius: radius)
        moveUp(sceneSize: sceneSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func renderItem(randomItem: Item, radius: CGFloat) {
        let emojiNode = SKLabelNode(text: randomItem.emoji)
        emojiNode.fontSize = radius * 1.2
        emojiNode.verticalAlignmentMode = .center
        emojiNode.horizontalAlignmentMode = .center
        emojiNode.position = CGPoint(x: 0, y: 0)
        
        addChild(emojiNode)
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
        guard !isCorrect else { return } // Falls bereits korrekt, nichts ändern
        
        let correctAnswer = correctItem.translation
        recognizedText = newText
        displayRecognizedText() // 🔹 Zeigt das gesprochene Wort weiterhin an
        
        if newText.lowercased().contains(correctAnswer.lowercased()) {
            isCorrect = true // Bubble bleibt stehen
            onCorrectAnswer?() // Score erhöhen
            
            showCorrectAnswerFeedback() // ✅ Emoji + Korrektes Wort anzeigen
            
            // 🌟 Animation: Langsames Verblassen der gesamten Bubble
            let wait = SKAction.wait(forDuration: 1.0)
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let remove = SKAction.removeFromParent()
            self.run(SKAction.sequence([wait, fadeOut, remove])) // Bubble verschwindet langsam
        }
    }
    
    private func showCorrectAnswerFeedback() {
        // 🔹 Entferne den alten "recognizedText" Node, falls vorhanden
        childNode(withName: "recognizedText")?.removeFromParent()
        
        // 🔹 Erstelle einen neuen Text-Node mit der richtigen Schreibweise
        let correctWordNode = SKLabelNode(text: correctItem.translation)
        correctWordNode.fontSize = 20
        correctWordNode.fontColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0) // Dunkleres Grün
        correctWordNode.fontName = "SFProText-Bold"
        correctWordNode.position = CGPoint(x: 0, y: radius + 20) // 🔹 Weiter über der Bubble platzieren
        correctWordNode.name = "correctWord"
        
        addChild(correctWordNode)
        
        // 🔹 Füge das ✅ Emoji in die Mitte der Bubble hinzu
        let emojiNode = SKLabelNode(text: "✅")
        emojiNode.fontSize = radius * 1.2
        emojiNode.verticalAlignmentMode = .center
        emojiNode.horizontalAlignmentMode = .center
        emojiNode.position = CGPoint(x: 0, y: 0) // 🔹 Emoji leicht unter das Wort setzen
        
        addChild(emojiNode)
        
        // 🌟 Animation: Emoji kurz größer machen für visuelles Feedback
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        emojiNode.run(sequence)
    }
    
    private func startTimer() {
        let timerDuration: TimeInterval = 3.0
        
        let animation = SKAction.customAction(withDuration: timerDuration) { [weak self] _, elapsedTime in
            let percentage = CGFloat(1.0 - elapsedTime / CGFloat(timerDuration))
            self?.updatePath(forPercentage: percentage)
        }
        
        let checkResult = SKAction.run { [weak self] in
            guard let self = self else { return }
            if !self.isCorrect {
                self.showFeedback(correct: false)
                self.fallAndRemove()
            }
        }
        
        let sequence = SKAction.sequence([animation, checkResult])
        self.run(sequence)
    }
    
    private func fallAndRemove() {
        let fallDistance = abs(position.y) + radius
        let fallDuration: TimeInterval = 1.0
        let fallAction = SKAction.moveBy(x: 0, y: -fallDistance, duration: fallDuration)
        fallAction.timingMode = .easeIn
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let fallSequence = SKAction.sequence([fallAction, fadeOut, remove])
        run(fallSequence)
    }
    
    private func showFeedback(correct: Bool) {
        let feedbackEmoji = correct ? "✅" : "❌"
        
        let emojiNode = SKLabelNode(text: feedbackEmoji)
        emojiNode.fontSize = radius * 1.2
        emojiNode.verticalAlignmentMode = .center
        emojiNode.horizontalAlignmentMode = .center
        emojiNode.position = CGPoint(x: 0, y: 0)
        
        addChild(emojiNode)
    }
    
    private func updatePath(forPercentage percentage: CGFloat) {
        let startColor = UIColor.blue
        let midColor = UIColor.orange
        let endColor = UIColor.red
        let interpolatedColor: UIColor
        
        if percentage > 0.5 {
            let factor = (1 - percentage) * 2
            interpolatedColor = interpolateColor(from: startColor, to: midColor, factor: factor)
        } else {
            let factor = (1 - (percentage * 2))
            interpolatedColor = interpolateColor(from: midColor, to: endColor, factor: factor)
        }
        
        let borderRadius: CGFloat = radius + 6
        let progressPath = CGMutablePath()
        progressPath.addArc(center: CGPoint.zero, radius: borderRadius, startAngle: .pi / 2, endAngle: (.pi / 2) - (.pi * 2 * percentage), clockwise: true)
        
        if let existingBorder = childNode(withName: "progressBorder") as? SKShapeNode {
            existingBorder.path = progressPath
            existingBorder.strokeColor = interpolatedColor
        } else {
            let borderNode = SKShapeNode(path: progressPath)
            borderNode.strokeColor = interpolatedColor
            borderNode.lineWidth = 5.0
            borderNode.fillColor = .clear
            borderNode.name = "progressBorder"
            borderNode.zPosition = 1
            addChild(borderNode)
        }
    }
    private func interpolateColor(from start: UIColor, to end: UIColor, factor: CGFloat) -> UIColor {
        var sR: CGFloat = 0, sG: CGFloat = 0, sB: CGFloat = 0, sA: CGFloat = 0
        var eR: CGFloat = 0, eG: CGFloat = 0, eB: CGFloat = 0, eA: CGFloat = 0
        
        start.getRed(&sR, green: &sG, blue: &sB, alpha: &sA)
        end.getRed(&eR, green: &eG, blue: &eB, alpha: &eA)
        
        return UIColor(red: sR + (eR - sR) * factor, green: sG + (eG - sG) * factor, blue: sB + (eB - sB) * factor, alpha: sA + (eA - sA) * factor)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startTimer()
        guard !isCorrect else { return }
        
        self.removeAction(forKey: "moveUp")
        
        // 🔹 Den aktuellsten Stand der Spracherkennung zum Zeitpunkt des Klicks speichern
        var lastRecognizedText = speechRecognizer?.recognizedText ?? ""
        
        // 🔹 Setze den erkannten Text für diese Bubble zurück
        recognizedText = ""
        displayRecognizedText()
        
        speechRecognizer?.onResult = { [weak self] newText in
            guard let self = self else { return }
            
            // 🔹 Extrahiere nur den Teil des Textes, der nach dem Klick gesprochen wurde
            let newPart = self.extractNewText(oldText: lastRecognizedText, newText: newText)
            
            if !newPart.isEmpty {
                self.updateRecognizedText(newText: newPart)
            }
            
            // 🔹 Aktualisiere `lastRecognizedText`, damit wir immer den neuesten Stand haben
            lastRecognizedText = newText
        }
    }
    
    private func extractNewText(oldText: String, newText: String) -> String {
        guard newText.count > oldText.count else { return newText }
        let startIndex = newText.index(newText.startIndex, offsetBy: oldText.count)
        return String(newText[startIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
