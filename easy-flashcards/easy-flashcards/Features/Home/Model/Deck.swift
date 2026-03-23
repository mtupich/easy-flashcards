import Foundation

struct Deck: Identifiable, Hashable {

    let id: UUID
    let name: String
    let abbreviation: String
    let cardCount: Int
    let masteredCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        abbreviation: String,
        cardCount: Int,
        masteredCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.cardCount = cardCount
        self.masteredCount = masteredCount
    }

    init(entity: DeckEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.abbreviation = entity.abbreviation ?? ""
        let cards = entity.flashcards as? Set<FlashcardEntity> ?? []
        self.cardCount = cards.count
        self.masteredCount = cards.filter { $0.isMastered }.count
    }
}
