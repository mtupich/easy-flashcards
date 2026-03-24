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
            if !viewModel.hasFlashcards {
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

            cardNavigation

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var pronunciationCard: some View {
        VStack(spacing: 20) {
            Text("PRONUNCIE")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.accent)
                .tracking(2)

            Text(viewModel.currentWord)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(wordColor)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.3), value: viewModel.pronunciationResult)

            if viewModel.showResult {
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
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: shadowColor, radius: 12, y: 6)
        .animation(.easeInOut(duration: 0.3), value: viewModel.pronunciationResult)
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
        case .correct: return Color.green.opacity(0.1)
        case .incorrect: return Color.red.opacity(0.1)
        }
    }

    private var shadowColor: Color {
        switch viewModel.pronunciationResult {
        case .none: return AppTheme.accent.opacity(0.15)
        case .correct: return Color.green.opacity(0.2)
        case .incorrect: return Color.red.opacity(0.2)
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

    // MARK: - Microphone

    private var microphoneButton: some View {
        Button {
            viewModel.toggleRecording()
        } label: {
            ZStack {
                Circle()
                    .fill(viewModel.speechRecognizer.isRecording ? Color.red : AppTheme.accent)
                    .frame(width: 72, height: 72)
                    .shadow(
                        color: (viewModel.speechRecognizer.isRecording
                                ? Color.red : AppTheme.accent).opacity(0.4),
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

                Image(systemName: viewModel.speechRecognizer.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Navigation

    private var cardNavigation: some View {
        HStack(spacing: 30) {
            Button {
                withAnimation(.spring(response: 0.4)) {
                    viewModel.previousCard()
                }
            } label: {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        viewModel.currentIndex > 0
                            ? AppTheme.accent
                            : AppTheme.textSecondary.opacity(0.3)
                    )
            }
            .disabled(viewModel.currentIndex == 0)

            Text("\(viewModel.currentIndex + 1) / \(viewModel.flashcards.count)")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)

            Button {
                withAnimation(.spring(response: 0.4)) {
                    viewModel.nextCard()
                }
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 36))
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
