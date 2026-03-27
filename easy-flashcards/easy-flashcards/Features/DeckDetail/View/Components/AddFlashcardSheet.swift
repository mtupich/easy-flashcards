import SwiftUI

struct AddFlashcardSheet: View {

    private let maxCharacters = 120

    @Environment(\.dismiss) private var dismiss
    @State private var question = ""
    @State private var answer = ""

    let onAdd: (String, String) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacingLarge) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Pergunta (frente)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textDark)
                        Spacer()
                        Text("\(question.count)/\(maxCharacters)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(AppTheme.textDark.opacity(0.45))
                    }

                    TextField(
                        "",
                        text: $question,
                        prompt: Text("Ex: Light").foregroundStyle(Color(.lightGray))
                    )
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(AppTheme.textDark)
                        .tint(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
                        .onChange(of: question) { _, newValue in
                            question = String(newValue.prefix(maxCharacters))
                        }
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Resposta (verso)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textDark)
                        Spacer()
                        Text("\(answer.count)/\(maxCharacters)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(AppTheme.textDark.opacity(0.45))
                    }

                    TextField(
                        "",
                        text: $answer,
                        prompt: Text("Ex: Luz").foregroundStyle(Color(.lightGray))
                    )
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(AppTheme.textDark)
                        .tint(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
                        .onChange(of: answer) { _, newValue in
                            answer = String(newValue.prefix(maxCharacters))
                        }
                }

                Spacer()
            }
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Novo Flashcard")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") {
                        onAdd(question, answer)
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.accent)
                    .disabled(question.isEmpty || answer.isEmpty)
                }
            }
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
        .presentationDetents([.medium])
        .presentationBackground(AppTheme.sheetBackground)
        .presentationCornerRadius(24)
    }
}
