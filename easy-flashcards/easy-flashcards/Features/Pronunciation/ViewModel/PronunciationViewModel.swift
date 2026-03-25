import Combine
import Foundation

enum PronunciationResult {
    case none
    case correct
    case incorrect
}

final class PronunciationViewModel: ObservableObject {

    @Published private(set) var decks: [Deck] = []
    @Published var selectedDeckId: UUID?
    @Published private(set) var deckFlashcards: [Flashcard] = []
    @Published private(set) var trainingCards: [Flashcard] = []
    @Published private(set) var retryCards: [Flashcard] = []
    @Published var currentIndex = 0
    @Published var pronunciationResult: PronunciationResult = .none
    @Published var showResult = false
    @Published private(set) var isCompleted = false
    @Published private(set) var isHandsFreeRunning = false
    @Published private(set) var isProcessing = false

    let speechRecognizer: SpeechRecognizer
    private let coreDataService: CoreDataServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var isSessionActive = false

    private let evaluationDelay: TimeInterval = 0.06
    private let feedbackDelay: TimeInterval = 0.55
    private let maxRecordingTime: TimeInterval = 5.0
    private let nextRecordingDelay: TimeInterval = 0.18
    private var currentListenDeadline: Date?

    private var currentCard: Flashcard? {
        guard currentIndex >= 0, currentIndex < trainingCards.count else { return nil }
        return trainingCards[currentIndex]
    }

    var currentWord: String {
        currentCard?.question ?? ""
    }

    var isTraining: Bool { selectedDeckId != nil }
    var hasFlashcards: Bool { !trainingCards.isEmpty }
    var selectedDeckName: String {
        decks.first { $0.id == selectedDeckId }?.name ?? ""
    }
    var remainingCardsCount: Int {
        max(0, trainingCards.count - currentIndex)
    }
    var progressText: String {
        guard !trainingCards.isEmpty else { return "0 / 0" }
        return "\(min(currentIndex + 1, trainingCards.count)) / \(trainingCards.count)"
    }
    var stackCards: [Flashcard] {
        Array(trainingCards.dropFirst(currentIndex).prefix(3))
    }
    var completionMessage: String {
        "Excelente! Você concluiu todos os cartões."
    }

    init(
        coreDataService: CoreDataServiceProtocol = CoreDataService.shared,
        speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    ) {
        self.coreDataService = coreDataService
        self.speechRecognizer = speechRecognizer
        loadDecks()
        observeRecognition()
    }

    func loadDecks() {
        let entities = coreDataService.fetchDecks()
        decks = entities.map { Deck(entity: $0) }
    }

    func selectDeck(_ deckId: UUID) {
        selectedDeckId = deckId
        loadDeckFlashcards()
        startTrainingSession()
        speechRecognizer.requestAuthorization()
    }

    func createDeck(name: String, abbreviation: String) {
        let deck = coreDataService.createDeck(name: name, abbreviation: abbreviation)
        loadDecks()
        if let id = deck.id {
            selectDeck(id)
        }
    }

    func addFlashcard(question: String, answer: String) {
        guard let deckId = selectedDeckId,
              let deckEntity = coreDataService.fetchDecks().first(where: { $0.id == deckId })
        else { return }
        coreDataService.createFlashcard(question: question, answer: answer, deck: deckEntity)
        loadDeckFlashcards()
        if !isCompleted {
            startTrainingSession()
        }
    }

    func restartTraining() {
        startTrainingSession()
    }

    private func loadDeckFlashcards() {
        guard let deckId = selectedDeckId,
              let deckEntity = coreDataService.fetchDecks().first(where: { $0.id == deckId })
        else { return }
        let entities = coreDataService.fetchFlashcards(for: deckEntity)
        deckFlashcards = entities.map { Flashcard(entity: $0) }
    }

    func toggleHandsFreeMode() {
        guard hasFlashcards, !isCompleted else { return }
        isHandsFreeRunning ? stopHandsFreeMode() : startHandsFreeMode()
    }

    func resetResult() {
        pronunciationResult = .none
        showResult = false
        speechRecognizer.recognizedText = ""
    }

    private func startTrainingSession() {
        trainingCards = deckFlashcards
        retryCards = []
        currentIndex = 0
        isCompleted = false
        isProcessing = false
        isHandsFreeRunning = false
        isSessionActive = false
        currentListenDeadline = nil
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }
        resetResult()
    }

    private func startHandsFreeMode() {
        guard hasFlashcards, !isCompleted else { return }
        isHandsFreeRunning = true
        startRecordingForCurrentCard()
    }

    private func stopHandsFreeMode() {
        isHandsFreeRunning = false
        isSessionActive = false
        isProcessing = false
        currentListenDeadline = nil
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }
    }

    private func startRecordingForCurrentCard(reuseDeadline: Bool = false) {
        guard isHandsFreeRunning, hasFlashcards, !isCompleted else { return }
        if !reuseDeadline {
            resetResult()
            currentListenDeadline = Date().addingTimeInterval(maxRecordingTime)
        } else {
            speechRecognizer.recognizedText = ""
            isProcessing = false
        }

        let remainingListenTime = max(0, currentListenDeadline?.timeIntervalSinceNow ?? maxRecordingTime)
        guard remainingListenTime > 0 else {
            handleListenTimeout()
            return
        }
        do {
            try speechRecognizer.startRecording()
            isSessionActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + remainingListenTime) { [weak self] in
                guard let self = self,
                      self.speechRecognizer.isRecording,
                      self.isSessionActive
                else { return }
                self.speechRecognizer.stopRecording()
            }
        } catch {
            isSessionActive = false
            isHandsFreeRunning = false
        }
    }

    private func observeRecognition() {
        speechRecognizer.$recognizedText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recognizedText in
                guard let self = self,
                      self.speechRecognizer.isRecording,
                      self.isSessionActive,
                      self.isLikelyCorrect(recognizedText, expected: self.currentWord)
                else { return }
                self.speechRecognizer.stopRecording()
            }
            .store(in: &cancellables)

        speechRecognizer.$isRecording
            .dropFirst()
            .filter { !$0 }
            .sink { [weak self] _ in
                guard let self = self, self.isSessionActive else { return }
                self.isSessionActive = false
                self.isProcessing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + self.evaluationDelay) { [weak self] in
                    self?.evaluatePronunciation()
                }
            }
            .store(in: &cancellables)
    }

    private func evaluatePronunciation() {
        guard let card = currentCard else { return }

        let spoken = speechRecognizer.recognizedText
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let expected = card.question
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !spoken.isEmpty else {
            // Se não houve fala reconhecida, continua escutando no mesmo card
            // até completar a janela total de ~5s.
            let hasTimeLeft = (currentListenDeadline?.timeIntervalSinceNow ?? 0) > 0
            if isHandsFreeRunning && hasTimeLeft {
                isProcessing = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
                    self?.startRecordingForCurrentCard(reuseDeadline: true)
                }
                return
            }
            handleListenTimeout()
            return
        }

        currentListenDeadline = nil
        isProcessing = false
        if isLikelyCorrect(spoken, expected: expected) {
            pronunciationResult = .correct
        } else {
            pronunciationResult = .incorrect
            retryCards.append(card)
        }
        showResult = true
        moveToNextCard()
    }

    private func handleListenTimeout() {
        guard let card = currentCard else { return }
        currentListenDeadline = nil
        isProcessing = false
        pronunciationResult = .incorrect
        showResult = true
        retryCards.append(card)
        moveToNextCard()
    }

    private func moveToNextCard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + feedbackDelay) { [weak self] in
            guard let self = self else { return }

            if self.currentIndex < self.trainingCards.count - 1 {
                self.currentIndex += 1
                self.resetResult()
                self.scheduleNextRecordingIfNeeded()
                return
            }

            if !self.retryCards.isEmpty {
                self.trainingCards = self.retryCards
                self.retryCards = []
                self.currentIndex = 0
                self.resetResult()
                self.scheduleNextRecordingIfNeeded()
                return
            }

            self.isCompleted = true
            self.isHandsFreeRunning = false
            self.isProcessing = false
            self.pronunciationResult = .none
            self.showResult = false
            self.speechRecognizer.recognizedText = ""
        }
    }

    private func scheduleNextRecordingIfNeeded() {
        guard isHandsFreeRunning else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + nextRecordingDelay) { [weak self] in
            self?.startRecordingForCurrentCard()
        }
    }

    private func isLikelyCorrect(_ spoken: String, expected: String) -> Bool {
        let normalizedSpoken = spoken
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedExpected = expected
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedSpoken.isEmpty, !normalizedExpected.isEmpty else { return false }
        return normalizedSpoken.contains(normalizedExpected) || normalizedExpected.contains(normalizedSpoken)
    }
}
