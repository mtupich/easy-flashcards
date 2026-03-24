import AuthenticationServices
import SwiftUI

struct LoginView: View {

    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            logoSection
            authButtons
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
        .background(AppTheme.background.ignoresSafeArea())
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

    // MARK: - Auth Buttons

    private var authButtons: some View {
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
}

#Preview {
    LoginView()
        .environmentObject(AppCoordinator())
}
