import CoreData

final class CoreDataService {

    static let shared = CoreDataService()

    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }

    // MARK: - Deck Operations

    func fetchDecks() -> [DeckEntity] {
        let request: NSFetchRequest<DeckEntity> = DeckEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DeckEntity.createdAt, ascending: false)]
        do {
            return try viewContext.fetch(request)
        } catch {
            return []
        }
    }

    @discardableResult
    func createDeck(name: String, abbreviation: String) -> DeckEntity {
        let deck = DeckEntity(context: viewContext)
        deck.id = UUID()
        deck.name = name
        deck.abbreviation = abbreviation
        deck.createdAt = Date()
        save()
        return deck
    }

    func deleteDeck(_ deck: DeckEntity) {
        viewContext.delete(deck)
        save()
    }

    // MARK: - Flashcard Operations

    func fetchFlashcards(for deck: DeckEntity) -> [FlashcardEntity] {
        let request: NSFetchRequest<FlashcardEntity> = FlashcardEntity.fetchRequest()
        request.predicate = NSPredicate(format: "deck == %@", deck)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FlashcardEntity.createdAt, ascending: true)]
        do {
            return try viewContext.fetch(request)
        } catch {
            return []
        }
    }

    func fetchAllFlashcards() -> [FlashcardEntity] {
        let request: NSFetchRequest<FlashcardEntity> = FlashcardEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FlashcardEntity.createdAt, ascending: true)]
        do {
            return try viewContext.fetch(request)
        } catch {
            return []
        }
    }

    @discardableResult
    func createFlashcard(question: String, answer: String, deck: DeckEntity) -> FlashcardEntity {
        let card = FlashcardEntity(context: viewContext)
        card.id = UUID()
        card.question = question
        card.answer = answer
        card.isMastered = false
        card.createdAt = Date()
        card.deck = deck
        save()
        return card
    }

    func toggleMastered(_ card: FlashcardEntity) {
        card.isMastered.toggle()
        save()
    }

    func deleteFlashcard(_ card: FlashcardEntity) {
        viewContext.delete(card)
        save()
    }

    // MARK: - Save

    func save() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            print("CoreData save error: \(error)")
        }
    }
}
