import SwiftUI

struct LoginView: View {

    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            logoSection
            fieldsSection
            loginButton
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
        .background(AppTheme.background.ignoresSafeArea())
    }

    // MARK: - Logo

    private var logoSection: some View {
        VStack(spacing: 16) {
            Image("easy_flashcards_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120)

            Text("Easy Flashcards")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }

    // MARK: - Fields

    private var fieldsSection: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            TextField("Usuário", text: $viewModel.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .darkFieldStyle()

            SecureField("Senha", text: $viewModel.password)
                .darkFieldStyle()
        }
    }

    // MARK: - Button

    private var loginButton: some View {
        Button {
            coordinator.login()
        } label: {
            Text("Entrar")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppCoordinator())
}
