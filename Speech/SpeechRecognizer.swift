import Speech

class SpeechRecognizer: ObservableObject {
    @Published var recognizedText: String = "Say something..."
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
    
    /// Requests permission for speech recognition
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                return
            case .denied:
                print("Speech recognition authorization was denied.")
            case .restricted:
                print("Speech recognition is restricted on this device.")
            case .notDetermined:
                print("Speech recognition authorization status is not determined.")
            @unknown default:
                print("Unknown speech recognition authorization status.")
            }
        }
    }
    
    /// Starts speech recognition and begins listening
    func startListening() {
        // Stop listening if already running
        if audioEngine.isRunning {
            stopListening()
            return
        }
        
        // Cancel any ongoing recognition task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            recognizedText = error.localizedDescription
            return
        }
        
        // Create a new recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create speech recognition request.")
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition task
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
        
        // Configure the audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
            }
        } catch {
            recognizedText = error.localizedDescription
        }
    }
    
    /// Stops the speech recognition process
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
    
    /// Resets the speech recognition system
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
        } catch {
            print("Error resetting audio session: \(error)")
        }
    }
    
    /// Clears the recognized text
    func resetRecognizedText() {
        self.recognizedText = ""
    }
}
