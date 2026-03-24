import AuthenticationServices
import Combine
import Foundation

final class LoginViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false

    let authService = AuthService()

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
}
