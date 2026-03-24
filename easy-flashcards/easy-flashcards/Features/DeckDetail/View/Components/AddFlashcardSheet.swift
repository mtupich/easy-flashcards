import SwiftUI

struct AddFlashcardSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var question = ""
    @State private var answer = ""

    let onAdd: (String, String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            sheetIndicator
            sheetHeader
            sheetContent
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "252550"))
        )
        .padding(.horizontal, 8)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
    }

    private var sheetIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AppTheme.textSecondary.opacity(0.4))
            .frame(width: 36, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 16)
    }

    private var sheetHeader: some View {
        HStack {
            Button("Cancelar") { dismiss() }
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.textSecondary)

            Spacer()

            Text("Novo Flashcard")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            Button("Adicionar") {
                onAdd(question, answer)
                dismiss()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(
                (question.isEmpty || answer.isEmpty)
                    ? AppTheme.accent.opacity(0.3)
                    : AppTheme.accent
            )
            .disabled(question.isEmpty || answer.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    private var sheetContent: some View {
        VStack(spacing: AppTheme.spacingLarge) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Pergunta (frente)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)

                TextField("Ex: Light", text: $question)
                    .darkFieldStyle()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Resposta (verso)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)

                TextField("Ex: Luz", text: $answer)
                    .darkFieldStyle()
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
