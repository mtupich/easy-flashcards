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
    @Published private(set) var flashcards: [Flashcard] = []
    @Published var currentIndex = 0
    @Published var pronunciationResult: PronunciationResult = .none
    @Published var showResult = false

    let speechRecognizer = SpeechRecognizer()
    private let coreDataService: CoreDataService
    private var cancellables = Set<AnyCancellable>()

    var currentWord: String {
        guard !flashcards.isEmpty, currentIndex < flashcards.count else { return "" }
        return flashcards[currentIndex].question
    }

    var isTraining: Bool { selectedDeckId != nil }
    var hasFlashcards: Bool { !flashcards.isEmpty }
    var selectedDeckName: String {
        decks.first { $0.id == selectedDeckId }?.name ?? ""
    }

    init(coreDataService: CoreDataService = .shared) {
        self.coreDataService = coreDataService
        loadDecks()
        observeRecognition()
    }

    func loadDecks() {
        let entities = coreDataService.fetchDecks()
        decks = entities.map { Deck(entity: $0) }
    }

    func selectDeck(_ deckId: UUID) {
        selectedDeckId = deckId
        currentIndex = 0
        resetResult()
        loadFlashcards()
        speechRecognizer.requestAuthorization()
    }

    func goBackToSelection() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }
        selectedDeckId = nil
        flashcards = []
        currentIndex = 0
        resetResult()
    }

    func createDeck(name: String, abbreviation: String) {
        coreDataService.createDeck(name: name, abbreviation: abbreviation)
        loadDecks()
    }

    private func loadFlashcards() {
        guard let deckId = selectedDeckId,
              let deckEntity = coreDataService.fetchDecks().first(where: { $0.id == deckId })
        else { return }
        let entities = coreDataService.fetchFlashcards(for: deckEntity)
        flashcards = entities.map { Flashcard(entity: $0) }
    }

    func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            pronunciationResult = .none
            showResult = false
            do {
                try speechRecognizer.startRecording()

                DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                    guard let self = self, self.speechRecognizer.isRecording else { return }
                    self.speechRecognizer.stopRecording()
                }
            } catch {
                pronunciationResult = .incorrect
                showResult = true
            }
        }
    }

    func nextCard() {
        if currentIndex < flashcards.count - 1 {
            currentIndex += 1
            resetResult()
        }
    }

    func previousCard() {
        if currentIndex > 0 {
            currentIndex -= 1
            resetResult()
        }
    }

    func resetResult() {
        pronunciationResult = .none
        showResult = false
        speechRecognizer.recognizedText = ""
    }

    private func observeRecognition() {
        speechRecognizer.$isRecording
            .dropFirst()
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.evaluatePronunciation()
            }
            .store(in: &cancellables)
    }

    private func evaluatePronunciation() {
        let spoken = speechRecognizer.recognizedText
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let expected = currentWord
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !spoken.isEmpty else {
            pronunciationResult = .incorrect
            showResult = true
            return
        }

        if spoken.contains(expected) || expected.contains(spoken) {
            pronunciationResult = .correct
        } else {
            pronunciationResult = .incorrect
        }
        showResult = true
    }
}
