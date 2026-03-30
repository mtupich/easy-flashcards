import AuthenticationServices
import SwiftUI

struct LoginView: View {

    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                logoSection
                emailAuthSection
                divider
                socialAuthButtons
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .onChange(of: viewModel.password) { oldValue, newValue in
            viewModel.applyStrongPasswordConfirmSyncIfNeeded(oldPassword: oldValue, newPassword: newValue)
        }
        .alert("Erro", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.3)
                    }
            }
        }
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

            Text("Aprenda com flashcards de forma simples")
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    // MARK: - Email and Password

    private var emailAuthSection: some View {
        VStack(spacing: 12) {
            Text(modeTitle)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.isRegisterMode {
                nameField
            }

            emailField

            if !viewModel.isResetPasswordMode {
                passwordField

                if viewModel.isRegisterMode {
                    confirmPasswordField
                }
            }

            primaryButton
            secondaryButton

            if !viewModel.isRegisterMode && !viewModel.isResetPasswordMode {
                forgotPasswordButton
            }
        }
    }

    private var nameField: some View {
        TextField("Nome do usuário", text: $viewModel.displayName)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .textContentType(.nickname)
            .submitLabel(.next)
            .foregroundStyle(AppTheme.textPrimary)
            .authInputStyle()
    }

    private var emailField: some View {
        TextField("E-mail", text: $viewModel.email)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .textContentType(.emailAddress)
            .submitLabel(.next)
            .foregroundStyle(AppTheme.textPrimary)
            .authInputStyle()
    }

    private var passwordField: some View {
        Group {
            if viewModel.isRegisterMode {
                SecureTextField(placeholder: "Senha", text: $viewModel.password, allowsNewPasswordContentType: true)
                    .frame(height: 22)
            } else {
                SecureField("Senha", text: $viewModel.password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textContentType(.password)
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .authInputStyle()
    }

    private var confirmPasswordField: some View {
        SecureTextField(placeholder: "Confirmar senha", text: $viewModel.confirmPassword)
            .frame(height: 22)
            .authInputStyle()
    }

    private var primaryButton: some View {
        Button {
            viewModel.submitEmailAuth { coordinator.login() }
        } label: {
            Text(primaryActionTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
        }
        .disabled(viewModel.isLoading)
    }

    private var secondaryButton: some View {
        Button(toggleActionTitle) {
            if viewModel.isResetPasswordMode {
                viewModel.exitResetPasswordMode()
            } else {
                viewModel.toggleMode()
            }
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(AppTheme.textSecondary)
        .disabled(viewModel.isLoading)
    }

    private var forgotPasswordButton: some View {
        Button("Esqueci minha senha") {
            viewModel.enterResetPasswordMode()
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(AppTheme.accent)
        .disabled(viewModel.isLoading)
    }

    // MARK: - Social Auth Buttons

    private var divider: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(AppTheme.textSecondary.opacity(0.25))
                .frame(height: 1)
            Text("ou")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
            Rectangle()
                .fill(AppTheme.textSecondary.opacity(0.25))
                .frame(height: 1)
        }
    }

    private var socialAuthButtons: some View {
        VStack(spacing: 14) {
            googleButton
            appleButton
        }
    }

    private var googleButton: some View {
        Button {
            viewModel.signInWithGoogle { coordinator.login() }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "g.circle.fill")
                    .font(.system(size: 22))

                Text("Continuar com Google")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(AppTheme.textSecondary.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(viewModel.isLoading)
    }

    private var appleButton: some View {
        SignInWithAppleButton(.signIn) { request in
            let hashedNonce = viewModel.prepareAppleNonce()
            request.requestedScopes = [.fullName, .email]
            request.nonce = hashedNonce
        } onCompletion: { result in
            viewModel.handleAppleSignIn(result) { coordinator.login() }
        }
        .signInWithAppleButtonStyle(.white)
        .frame(height: 54)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
        .disabled(viewModel.isLoading)
    }

    private var modeTitle: String {
        if viewModel.isResetPasswordMode {
            return "Recuperar senha"
        }
        return viewModel.isRegisterMode ? "Criar nova conta" : "Entrar"
    }

    private var primaryActionTitle: String {
        if viewModel.isResetPasswordMode {
            return "Enviar link de recuperação"
        }
        return viewModel.isRegisterMode ? "Cadastrar-se" : "Entrar com e-mail"
    }

    private var toggleActionTitle: String {
        if viewModel.isResetPasswordMode {
            return "Voltar para entrar"
        }
        return viewModel.isRegisterMode
            ? "Já tem conta? Entrar"
            : "Não tem conta? Cadastrar-se"
    }
}

private extension View {
    func authInputStyle() -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(AppTheme.textSecondary.opacity(0.25), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
        .environmentObject(AppCoordinator())
}
