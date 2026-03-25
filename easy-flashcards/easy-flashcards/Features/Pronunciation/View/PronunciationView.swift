import SwiftUI

struct PronunciationView: View {

    @StateObject private var viewModel = PronunciationViewModel()
    @State private var showCreateDeck = false
    @State private var showAddFlashcard = false

    var body: some View {
        Group {
            if viewModel.isTraining {
                trainingContent
            } else {
                deckSelectionContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(viewModel.isTraining ? viewModel.selectedDeckName : "Treinar Pronúncia")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isTraining {
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
        .sheet(isPresented: $showCreateDeck) {
            CreateDeckSheet { name, abbreviation in
                viewModel.createDeck(name: name, abbreviation: abbreviation)
            }
        }
        .sheet(isPresented: $showAddFlashcard) {
            AddFlashcardSheet { question, answer in
                viewModel.addFlashcard(question: question, answer: answer)
            }
        }
    }

    // MARK: - Deck Selection

    private var deckSelectionContent: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingMedium) {
                VStack(spacing: 8) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(AppTheme.accent)

                    Text("Escolha um baralho")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Selecione o baralho com as palavras que deseja praticar")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, AppTheme.spacingLarge)

                Button {
                    showCreateDeck = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                        Text("Criar novo baralho")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                    .foregroundStyle(AppTheme.accent)
                    .padding(AppTheme.spacingMedium)
                    .background(AppTheme.accent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
                }

                if viewModel.decks.isEmpty {
                    VStack(spacing: 12) {
                        Text("Nenhum baralho disponível")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)

                        Text("Crie um baralho e adicione palavras para praticar")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary.opacity(0.7))
                    }
                    .padding(.vertical, 30)
                } else {
                    ForEach(viewModel.decks) { deck in
                        Button {
                            viewModel.selectDeck(deck.id)
                        } label: {
                            HStack(spacing: AppTheme.spacingMedium) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(AppTheme.accent.opacity(0.25))
                                        .frame(width: 44, height: 44)

                                    Text(deck.abbreviation.isEmpty
                                         ? String(deck.name.prefix(2)).uppercased()
                                         : deck.abbreviation)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(AppTheme.accent)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(deck.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(AppTheme.textPrimary)

                                    Text("\(deck.cardCount) cartões")
                                        .font(.system(size: 13))
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
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Training Content

    private var trainingContent: some View {
        Group {
            if viewModel.isCompleted {
                completionState
            } else if !viewModel.hasFlashcards {
                emptyDeckState
            } else {
                pronunciationTraining
            }
        }
    }

    private var emptyDeckState: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 50))
                .foregroundStyle(AppTheme.textSecondary)

            Text("Baralho vazio")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Adicione palavras para praticar a pronúncia")
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                showAddFlashcard = true
            } label: {
                Text("Adicionar Palavra")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
            }
            .padding(.top, 8)
        }
        .padding(40)
    }

    // MARK: - Pronunciation Training

    private var pronunciationTraining: some View {
        VStack(spacing: AppTheme.spacingLarge) {
            Spacer()

            trainingProgress
            pronunciationCard

            if viewModel.showResult {
                resultFeedback
            }

            if let error = viewModel.speechRecognizer.permissionError {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            microphoneButton

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var trainingProgress: some View {
        VStack(spacing: 6) {
            Text(viewModel.progressText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)

            if !viewModel.retryCards.isEmpty {
                Text("Erros pendentes: \(viewModel.retryCards.count)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.orange.opacity(0.95))
            }
        }
    }

    private var pronunciationCard: some View {
        ZStack {
            ForEach(Array(visibleStackCards.enumerated().reversed()), id: \.element.id) { index, card in
                cardView(for: card, isCurrent: index == 0)
                    .scaleEffect(index == 0 ? 1 : 0.95 - CGFloat(index) * 0.03)
                    .offset(y: CGFloat(index) * 14)
                    .opacity(index == 0 ? 1 : 0.82)
            }
        }
        .frame(height: 270)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: viewModel.currentIndex)
    }

    private var visibleStackCards: [Flashcard] {
        // Durante o feedback (verde/vermelho), exibimos só o card atual
        // para evitar o "vazamento" visual do próximo card no fundo.
        viewModel.showResult ? Array(viewModel.stackCards.prefix(1)) : viewModel.stackCards
    }

    private var wordColor: Color {
        switch viewModel.pronunciationResult {
        case .none: return AppTheme.textPrimary
        case .correct: return .green
        case .incorrect: return .red
        }
    }

    private var cardBackgroundColor: Color {
        switch viewModel.pronunciationResult {
        case .none: return AppTheme.cardBackground
        case .correct: return Color(hex: "183E24")
        case .incorrect: return Color(hex: "4A1F26")
        }
    }

    private var shadowColor: Color {
        switch viewModel.pronunciationResult {
        case .none: return AppTheme.accent.opacity(0.15)
        case .correct: return Color.green.opacity(0.35)
        case .incorrect: return Color.red.opacity(0.35)
        }
    }

    // MARK: - Result Feedback

    private var resultFeedback: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.pronunciationResult == .correct
                  ? "checkmark.circle.fill"
                  : "xmark.circle.fill")
                .font(.system(size: 20))

            Text(viewModel.pronunciationResult == .correct
                 ? "Pronúncia correta!"
                 : "Tente novamente")
                .font(.system(size: 16, weight: .semibold))
        }
        .foregroundStyle(viewModel.pronunciationResult == .correct ? .green : .red)
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.4), value: viewModel.showResult)
    }

    private var completionState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 52))
                .foregroundStyle(.green)

            Text("Treino finalizado")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text(viewModel.completionMessage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                viewModel.restartTraining()
            } label: {
                Text("Treinar novamente")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
            }
            .padding(.top, 8)
        }
        .padding(32)
    }

    // MARK: - Microphone

    private var microphoneButton: some View {
        VStack(spacing: 10) {
            Button {
                viewModel.toggleHandsFreeMode()
            } label: {
                ZStack {
                    Circle()
                        .fill(microphoneColor)
                        .frame(width: 72, height: 72)
                        .shadow(
                            color: microphoneColor.opacity(0.4),
                            radius: 12
                        )

                    if viewModel.speechRecognizer.isRecording {
                        Circle()
                            .stroke(Color.red.opacity(0.3), lineWidth: 3)
                            .frame(width: 88, height: 88)
                            .scaleEffect(1.2)
                            .opacity(0)
                            .animation(
                                .easeOut(duration: 1).repeatForever(autoreverses: false),
                                value: viewModel.speechRecognizer.isRecording
                            )
                    }

                    Image(systemName: microphoneIcon)
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
            }
            .disabled(viewModel.isProcessing)
            .padding(.top, 8)

            Text(microphoneHint)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var microphoneColor: Color {
        if viewModel.isProcessing { return AppTheme.textSecondary.opacity(0.45) }
        if viewModel.speechRecognizer.isRecording { return .red }
        if viewModel.isHandsFreeRunning { return .orange }
        return AppTheme.accent
    }

    private var microphoneIcon: String {
        if viewModel.isProcessing { return "ellipsis" }
        return viewModel.speechRecognizer.isRecording ? "stop.fill" : "mic.fill"
    }

    private var microphoneHint: String {
        if viewModel.isProcessing { return "Processando..." }
        if viewModel.speechRecognizer.isRecording { return "Ouvindo..." }
        if viewModel.isHandsFreeRunning { return "Aguardando próxima palavra..." }
        return "Toque uma vez para iniciar o treino contínuo"
    }

    private func cardView(for card: Flashcard, isCurrent: Bool) -> some View {
        VStack(spacing: 20) {
            Text("PRONUNCIE")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.accent)
                .tracking(2)

            Text(card.question)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(isCurrent ? wordColor : AppTheme.textPrimary.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(3)

            if isCurrent && viewModel.showResult {
                Text(
                    viewModel.speechRecognizer.recognizedText.isEmpty
                        ? "Não detectado"
                        : "\"\(viewModel.speechRecognizer.recognizedText)\""
                )
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .background(isCurrent ? cardBackgroundColor : AppTheme.cardBackground.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(cardBorderColor(isCurrent: isCurrent), lineWidth: 2)
        )
        .shadow(color: isCurrent ? shadowColor : .clear, radius: 12, y: 6)
        .animation(.easeInOut(duration: 0.2), value: viewModel.pronunciationResult)
    }

    private func cardBorderColor(isCurrent: Bool) -> Color {
        guard isCurrent else { return AppTheme.textSecondary.opacity(0.35) }
        switch viewModel.pronunciationResult {
        case .none:
            return AppTheme.accent.opacity(0.5)
        case .correct:
            return Color.green.opacity(0.95)
        case .incorrect:
            return Color.red.opacity(0.95)
        }
    }
}
