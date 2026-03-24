import Combine
import Foundation

final class HomeViewModel: ObservableObject {

    @Published private(set) var decks: [Deck] = []

    private let coreDataService: CoreDataServiceProtocol

    var totalDecks: Int { decks.count }
    var totalCards: Int { decks.reduce(0) { $0 + $1.cardCount } }
    var totalMastered: Int { decks.reduce(0) { $0 + $1.masteredCount } }

    init(coreDataService: CoreDataServiceProtocol = CoreDataService.shared) {
        self.coreDataService = coreDataService
        loadDecks()
    }

    func loadDecks() {
        let entities = coreDataService.fetchDecks()
        decks = entities.map { Deck(entity: $0) }
    }

    @discardableResult
    func createDeck(name: String, abbreviation: String) -> UUID? {
        let entity = coreDataService.createDeck(name: name, abbreviation: abbreviation)
        loadDecks()
        return entity.id
    }

    func deleteDeck(id: UUID) {
        let entities = coreDataService.fetchDecks()
        guard let entity = entities.first(where: { $0.id == id }) else { return }
        coreDataService.deleteDeck(entity)
        loadDecks()
    }
}
