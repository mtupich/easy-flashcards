import Foundation

struct Flashcard: Identifiable, Hashable {

    let id: UUID
    let question: String
    let answer: String
    var isMastered: Bool

    init(
        id: UUID = UUID(),
        question: String,
        answer: String,
        isMastered: Bool = false
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.isMastered = isMastered
    }

    init(entity: FlashcardEntity) {
        self.id = entity.id ?? UUID()
        self.question = entity.question ?? ""
        self.answer = entity.answer ?? ""
        self.isMastered = entity.isMastered
    }
}
