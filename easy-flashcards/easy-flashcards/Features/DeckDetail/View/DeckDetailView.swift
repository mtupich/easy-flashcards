import SwiftUI

struct DeckDetailView: View {

    @StateObject private var viewModel: DeckDetailViewModel
    @State private var showAddFlashcard = false

    init(deckId: UUID) {
        _viewModel = StateObject(wrappedValue: DeckDetailViewModel(deckId: deckId))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isEmpty {
                emptyState
            } else {
                cardCarousel
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(viewModel.deckName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !viewModel.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddFlashcard = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddFlashcard) {
            AddFlashcardSheet { question, answer in
                viewModel.addFlashcard(question: question, answer: answer)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundStyle(AppTheme.textSecondary)

            Text("Nenhum flashcard")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Adicione flashcards tocando no botão abaixo")
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)

            Button {
                showAddFlashcard = true
            } label: {
                Text("Adicionar Flashcard")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
            }
            .padding(.top, 8)
        }
    }

    private var cardCarousel: some View {
        VStack(spacing: AppTheme.spacingLarge) {
            Spacer()

            FlashcardView(flashcard: viewModel.flashcards[viewModel.currentIndex])
                .padding(.horizontal, 20)

            cardCounter

            navigationButtons

            Spacer()
        }
    }

    private var cardCounter: some View {
        Text("\(viewModel.currentIndex + 1) / \(viewModel.flashcards.count)")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(AppTheme.textSecondary)
    }

    private var navigationButtons: some View {
        HStack(spacing: 40) {
            Button {
                withAnimation(.spring(response: 0.4)) {
                    viewModel.previousCard()
                }
            } label: {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        viewModel.currentIndex > 0
                            ? AppTheme.accent
                            : AppTheme.textSecondary.opacity(0.3)
                    )
            }
            .disabled(viewModel.currentIndex == 0)

            Button {
                viewModel.toggleMastered(at: viewModel.currentIndex)
            } label: {
                let card = viewModel.flashcards[viewModel.currentIndex]
                Image(systemName: card.isMastered ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.system(size: 44))
                    .foregroundStyle(card.isMastered ? Color.green : AppTheme.textSecondary)
            }

            Button {
                withAnimation(.spring(response: 0.4)) {
                    viewModel.nextCard()
                }
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        viewModel.currentIndex < viewModel.flashcards.count - 1
                            ? AppTheme.accent
                            : AppTheme.textSecondary.opacity(0.3)
                    )
            }
            .disabled(viewModel.currentIndex >= viewModel.flashcards.count - 1)
        }
    }
}
