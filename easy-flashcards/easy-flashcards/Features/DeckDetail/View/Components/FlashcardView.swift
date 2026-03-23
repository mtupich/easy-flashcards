import SwiftUI

struct FlashcardView: View {

    let flashcard: Flashcard
    @State private var isFlipped = false
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            cardFront
                .opacity(rotation.truncatingRemainder(dividingBy: 360) < 90 ||
                         rotation.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)

            cardBack
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(rotation.truncatingRemainder(dividingBy: 360) >= 90 &&
                         rotation.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
        }
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                rotation += 180
                isFlipped.toggle()
            }
        }
        .onChange(of: flashcard.id) { _, _ in
            rotation = 0
            isFlipped = false
        }
    }

    private var cardFront: some View {
        VStack(spacing: 16) {
            Text("PERGUNTA")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.accent)
                .tracking(2)

            Spacer()

            Text(flashcard.question)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)

            Spacer()

            Text("Toque para virar")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary.opacity(0.6))
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: AppTheme.accent.opacity(0.15), radius: 12, y: 6)
    }

    private var cardBack: some View {
        VStack(spacing: 16) {
            Text("RESPOSTA")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.green)
                .tracking(2)

            Spacer()

            Text(flashcard.answer)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)

            Spacer()

            Text("Toque para virar")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary.opacity(0.6))
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .background(
            LinearGradient(
                colors: [AppTheme.cardBackground, Color(hex: "1a2a4a")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.green.opacity(0.1), radius: 12, y: 6)
    }
}
