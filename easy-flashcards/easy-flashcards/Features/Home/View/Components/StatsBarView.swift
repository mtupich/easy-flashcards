import SwiftUI

struct StatsBarView: View {

    let deckCount: Int
    let cardCount: Int
    let masteredCount: Int

    var body: some View {
        HStack {
            statItem(value: deckCount, label: "Baralhos")
            Spacer()
            statItem(value: cardCount, label: "Cartões")
            Spacer()
            statItem(value: masteredCount, label: "Dominados")
        }
        .padding(.horizontal, AppTheme.spacingLarge)
        .padding(.vertical, 20)
        .background(AppTheme.accentGradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
    }

    private func statItem(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary.opacity(0.85))
        }
    }
}

#Preview {
    StatsBarView(deckCount: 3, cardCount: 45, masteredCount: 0)
        .padding()
        .background(AppTheme.background)
}
