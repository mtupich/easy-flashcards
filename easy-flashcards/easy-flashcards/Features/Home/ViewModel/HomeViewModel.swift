import Combine
import Foundation

final class HomeViewModel: ObservableObject {

    @Published private(set) var decks: [Deck] = []

    var totalDecks: Int { decks.count }
    var totalCards: Int { decks.reduce(0) { $0 + $1.cardCount } }
    var totalMastered: Int { decks.reduce(0) { $0 + $1.masteredCount } }

    init() {
        loadDecks()
    }

    private func loadDecks() {
        decks = [
            Deck(name: "Inglês Básico", abbreviation: "ABC", cardCount: 15),
            Deck(name: "Negócios", abbreviation: "BIZ", cardCount: 15),
            Deck(name: "Viagem", abbreviation: "VIA", cardCount: 15)
        ]
    }
}
