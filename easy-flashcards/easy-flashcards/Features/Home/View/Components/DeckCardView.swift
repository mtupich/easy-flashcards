import SwiftUI

struct DeckCardView: View {

    let deck: Deck

    var body: some View {
        HStack(spacing: AppTheme.spacingMedium) {
            deckBadge
            deckInfo
            Spacer()
        }
        .padding(AppTheme.spacingMedium)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
    }

    private var deckBadge: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                .fill(AppTheme.accent.opacity(0.25))
                .frame(width: 52, height: 52)

            RoundedRectangle(cornerRadius: 6)
                .fill(AppTheme.accent)
                .frame(width: 44, height: 36)
                .overlay(
                    Text(deck.abbreviation)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                )
                .offset(x: -2, y: -4)
        }
    }

    private var deckInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(deck.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            Text("\(deck.cardCount) cartões")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}

#Preview {
    DeckCardView(deck: Deck(name: "Inglês Básico", abbreviation: "ABC", cardCount: 15))
        .padding()
        .background(AppTheme.background)
}
