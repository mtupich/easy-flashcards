import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacingLarge) {
                headerSection
                statsSection
                decksSection
            }
            .padding(.horizontal, 20)
            .padding(.top, AppTheme.spacingLarge)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bem-vindo de volta")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.textSecondary)

            Text("Seus Flashcards")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        StatsBarView(
            deckCount: viewModel.totalDecks,
            cardCount: viewModel.totalCards,
            masteredCount: viewModel.totalMastered
        )
    }

    // MARK: - Decks List

    private var decksSection: some View {
        VStack(spacing: AppTheme.spacingSmall + 4) {
            ForEach(viewModel.decks) { deck in
                DeckCardView(deck: deck)
                    .onTapGesture {
                        coordinator.push(.deckDetail(deckId: deck.id))
                    }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppCoordinator())
}
