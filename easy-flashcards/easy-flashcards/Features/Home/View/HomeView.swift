import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showCreateDeck = false
    @State private var deckToDelete: Deck?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacingLarge) {
                headerSection
                statsSection
                pronunciationSection
                decksSection
            }
            .padding(.horizontal, 20)
            .padding(.top, AppTheme.spacingLarge)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .sheet(isPresented: $showCreateDeck) {
            CreateDeckSheet { name, abbreviation in
                viewModel.createDeck(name: name, abbreviation: abbreviation)
            }
        }
        .alert("Tem certeza que deseja apagar esse deck?", isPresented: showDeleteAlert) {
            Button("Não", role: .cancel) {
                deckToDelete = nil
            }
            Button("Sim", role: .destructive) {
                if let deck = deckToDelete {
                    viewModel.deleteDeck(id: deck.id)
                    deckToDelete = nil
                }
            }
        }
        .onAppear {
            viewModel.loadDecks()
        }
    }

    private var showDeleteAlert: Binding<Bool> {
        Binding(
            get: { deckToDelete != nil },
            set: { if !$0 { deckToDelete = nil } }
        )
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

    // MARK: - Pronunciation Training

    private var pronunciationSection: some View {
        Button {
            coordinator.push(.pronunciation)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.2))
                        .frame(width: 48, height: 48)

                    Image(systemName: "mic.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Treinar Pronúncia")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Pratique a pronúncia dos seus flashcards")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(AppTheme.spacingMedium)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
        }
    }

    // MARK: - Decks List

    private var decksSection: some View {
        VStack(spacing: AppTheme.spacingSmall + 4) {
            HStack {
                Text("Meus Baralhos")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Button {
                    showCreateDeck = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.accent)
                }
            }

            if viewModel.decks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text("Nenhum baralho criado")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text("Toque no + para criar seu primeiro baralho")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(viewModel.decks) { deck in
                    DeckCardView(deck: deck) {
                        deckToDelete = deck
                    }
                    .onTapGesture {
                        coordinator.push(.deckDetail(deckId: deck.id))
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppCoordinator())
}
