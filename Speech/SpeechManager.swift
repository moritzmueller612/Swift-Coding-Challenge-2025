import AVFoundation

class SpeechManager: ObservableObject {
    private let speechSynthesizer = AVSpeechSynthesizer()

    func speak(_ text: String, in language: String) {
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }
}
