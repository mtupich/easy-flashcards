import AuthenticationServices
import Combine
import Foundation

final class LoginViewModel: ObservableObject {

    @Published var displayName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isRegisterMode = false
    @Published var isResetPasswordMode = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    /// Só replica para "Confirmar senha" quando muitos caracteres entram de uma vez (ex.: senha forte da Apple), não ao digitar manualmente.
    func applyStrongPasswordConfirmSyncIfNeeded(oldPassword: String, newPassword: String) {
        guard isRegisterMode else { return }
        guard newPassword.count > oldPassword.count else { return }
        let inserted = newPassword.count - oldPassword.count
        guard inserted >= 12 else { return }
        confirmPassword = newPassword
    }

    func submitEmailAuth(onSuccess: @escaping () -> Void) {
        if isResetPasswordMode {
            resetPassword()
            return
        }

        isRegisterMode
            ? registerWithEmail(onSuccess: onSuccess)
            : signInWithEmail(onSuccess: onSuccess)
    }

    func toggleMode() {
        isRegisterMode.toggle()
        isResetPasswordMode = false
        displayName = ""
        password = ""
        confirmPassword = ""
    }

    func enterResetPasswordMode() {
        isResetPasswordMode = true
        isRegisterMode = false
        password = ""
        confirmPassword = ""
    }

    func exitResetPasswordMode() {
        isResetPasswordMode = false
        password = ""
        confirmPassword = ""
    }

    func resetPassword() {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedEmail.isEmpty else {
            showInlineError("Informe seu e-mail para recuperar a senha.")
            return
        }

        guard isValidEmail(normalizedEmail) else {
            showInlineError("Informe um e-mail válido.")
            return
        }

        isLoading = true
        Task {
            do {
                try await authService.sendPasswordReset(email: normalizedEmail)
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Enviamos um link para redefinir sua senha."
                    showError = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    func signInWithGoogle(onSuccess: @escaping () -> Void) {
        isLoading = true
        Task {
            do {
                try await authService.signInWithGoogle()
                await MainActor.run {
                    isLoading = false
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    func prepareAppleNonce() -> String {
        authService.prepareAppleNonce()
    }

    func handleAppleSignIn(
        _ result: Result<ASAuthorization, any Error>,
        onSuccess: @escaping () -> Void
    ) {
        switch result {
        case .success(let authorization):
            isLoading = true
            Task {
                do {
                    try await authService.handleAppleSignIn(authorization)
                    await MainActor.run {
                        isLoading = false
                        onSuccess()
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func signInWithEmail(onSuccess: @escaping () -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedEmail.isEmpty, !password.isEmpty else {
            showInlineError("Preencha e-mail e senha para continuar.")
            return
        }

        isLoading = true
        Task {
            do {
                try await authService.signInWithEmail(email: normalizedEmail, password: password)
                await MainActor.run {
                    isLoading = false
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func registerWithEmail(onSuccess: @escaping () -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !normalizedEmail.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            showInlineError("Preencha todos os campos para criar sua conta.")
            return
        }

        guard isValidEmail(normalizedEmail) else {
            showInlineError("Informe um e-mail válido.")
            return
        }

        guard password == confirmPassword else {
            showInlineError("As senhas não conferem.")
            return
        }

        guard validatePasswordRules(password) else {
            showInlineError("A senha deve ter 8+ caracteres, com maiúscula, minúscula, número e símbolo.")
            return
        }

        isLoading = true
        Task {
            do {
                try await authService.registerWithEmail(
                    email: normalizedEmail,
                    password: password,
                    displayName: trimmedName
                )
                await MainActor.run {
                    isLoading = false
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func showInlineError(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    private func validatePasswordRules(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        let upper = CharacterSet.uppercaseLetters
        let lower = CharacterSet.lowercaseLetters
        let digits = CharacterSet.decimalDigits
        let symbols = CharacterSet.punctuationCharacters.union(.symbols)
        let scalars = password.unicodeScalars

        let hasUpper = scalars.contains { upper.contains($0) }
        let hasLower = scalars.contains { lower.contains($0) }
        let hasDigit = scalars.contains { digits.contains($0) }
        let hasSymbol = scalars.contains { symbols.contains($0) }

        return hasUpper && hasLower && hasDigit && hasSymbol
    }
}
