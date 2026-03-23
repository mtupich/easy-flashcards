import AVFoundation
import Combine
import Speech

final class SpeechRecognizer: ObservableObject {

    @Published var recognizedText = ""
    @Published var isRecording = false
    @Published var isAuthorized = false
    @Published var permissionError: String?

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?

    init(locale: Locale = Locale(identifier: "en-US")) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
    }

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .authorized:
                    self.checkMicrophonePermission()
                case .denied, .restricted:
                    self.isAuthorized = false
                    self.permissionError = "Permissão de reconhecimento de voz negada. Ative em Ajustes."
                case .notDetermined:
                    self.isAuthorized = false
                @unknown default:
                    self.isAuthorized = false
                }
            }
        }
    }

    private func checkMicrophonePermission() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            isAuthorized = true
        case .denied:
            isAuthorized = false
            permissionError = "Permissão de microfone negada. Ative em Ajustes."
        case .undetermined:
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if !granted {
                        self?.permissionError = "Permissão de microfone necessária para treinar pronúncia."
                    }
                }
            }
        @unknown default:
            isAuthorized = false
        }
    }

    func startRecording() throws {
        stopRecording()
        recognizedText = ""

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let engine = AVAudioEngine()
        self.audioEngine = engine

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = engine.inputNode

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                }
                if result.isFinal {
                    DispatchQueue.main.async {
                        self.finishRecording()
                    }
                }
            }

            if error != nil {
                DispatchQueue.main.async {
                    self.finishRecording()
                }
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        engine.prepare()
        try engine.start()
        isRecording = true
    }

    func stopRecording() {
        guard let engine = audioEngine, engine.isRunning else {
            cleanupRecording()
            return
        }
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        cleanupRecording()
    }

    private func finishRecording() {
        if let engine = audioEngine, engine.isRunning {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        cleanupRecording()
    }

    private func cleanupRecording() {
        recognitionRequest = nil
        recognitionTask = nil
        audioEngine = nil
        isRecording = false
    }
}
