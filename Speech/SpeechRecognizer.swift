import Speech

class SpeechRecognizer: ObservableObject {
    @Published var recognizedText: String = "Sag etwas..."
    @Published var isRecording: Bool = false
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var settings: Settings
    
    var onResult: ((String) -> Void)?
    
    init(settings: Settings) {
        self.settings = settings
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: settings.selectedLanguage))
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                return
            case .denied:
                print("Speech recognition authorization denied")
            case .restricted:
                print("Speech recognition restricted")
            case .notDetermined:
                print("Speech recognition not determined")
            @unknown default:
                print("Unknown speech recognition authorization status")
            }
        }
    }
    
    func startListening() {
        if audioEngine.isRunning {
            stopListening()
            return
        }
        
        // Vorherige Erkennung abbrechen, falls vorhanden
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Audio-Session konfigurieren
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            recognizedText = "Audio Session Fehler: \(error.localizedDescription)"
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Kann Anfrage nicht erstellen")
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // Spracherkennung starten
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                    self.onResult?(self.recognizedText)
                }
                if result.isFinal {
                    self.stopListening()
                }
            }
            
            if error != nil {
                self.stopListening()
            }
        }
        
        // Audio-Engine konfigurieren
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
            }
        } catch {
            recognizedText = "Audio Engine Fehler: \(error.localizedDescription)"
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
    
    func reset() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine = AVAudioEngine()
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [])
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            print("🔇 Audio session successfully reset.")
        } catch {
            print("❌ Error resetting audio session: \(error)")
        }
    }
    
    func resetRecognizedText() {
        self.recognizedText = ""
    }
}
