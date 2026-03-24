import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let deck = DeckEntity(context: viewContext)
        deck.id = UUID()
        deck.name = "Inglês Básico"
        deck.abbreviation = "ABC"
        deck.createdAt = Date()

        let card = FlashcardEntity(context: viewContext)
        card.id = UUID()
        card.question = "Light"
        card.answer = "Luz"
        card.isMastered = false
        card.createdAt = Date()
        card.deck = deck

        do {
            try viewContext.save()
        } catch {
            print("Preview CoreData save error: \(error)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "easy_flashcards")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("CoreData load error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
