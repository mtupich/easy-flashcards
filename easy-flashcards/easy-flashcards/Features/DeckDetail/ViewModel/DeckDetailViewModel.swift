import Combine
import Foundation

final class DeckDetailViewModel: ObservableObject {

    @Published private(set) var flashcards: [Flashcard] = []
    @Published var currentIndex = 0

    let deckId: UUID
    private let coreDataService: CoreDataServiceProtocol

    var deckName: String {
        deckEntity?.name ?? ""
    }

    var isEmpty: Bool { flashcards.isEmpty }

    private var deckEntity: DeckEntity? {
        coreDataService.fetchDecks().first { $0.id == deckId }
    }

    init(deckId: UUID, coreDataService: CoreDataServiceProtocol = CoreDataService.shared) {
        self.deckId = deckId
        self.coreDataService = coreDataService
        loadFlashcards()
    }

    func loadFlashcards() {
        guard let deck = deckEntity else { return }
        let entities = coreDataService.fetchFlashcards(for: deck)
        flashcards = entities.map { Flashcard(entity: $0) }

        if currentIndex >= flashcards.count {
            currentIndex = max(0, flashcards.count - 1)
        }
    }

    func addFlashcard(question: String, answer: String) {
        guard let deck = deckEntity else { return }
        coreDataService.createFlashcard(question: question, answer: answer, deck: deck)
        loadFlashcards()
    }

    func deleteFlashcard(at index: Int) {
        guard let deck = deckEntity else { return }
        let entities = coreDataService.fetchFlashcards(for: deck)
        if index < entities.count {
            coreDataService.deleteFlashcard(entities[index])
            loadFlashcards()
        }
    }

    func toggleMastered(at index: Int) {
        guard let deck = deckEntity else { return }
        let entities = coreDataService.fetchFlashcards(for: deck)
        if index < entities.count {
            coreDataService.toggleMastered(entities[index])
            loadFlashcards()
        }
    }

    func nextCard() {
        if currentIndex < flashcards.count - 1 {
            currentIndex += 1
        }
    }

    func previousCard() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
}
