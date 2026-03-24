import AuthenticationServices
import Combine
import CryptoKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

struct UserInfo {
    let displayName: String?
    let email: String?
    let photoURL: URL?

    var firstName: String {
        let name = displayName ?? ""
        return name.split(separator: " ").first.map(String.init) ?? "Usuário"
    }

    var initials: String {
        let name = displayName ?? ""
        let parts = name.split(separator: " ")
        let first = parts.first.map { String($0.prefix(1)) } ?? ""
        let last = parts.count > 1 ? String(parts.last!.prefix(1)) : ""
        let result = (first + last).uppercased()
        return result.isEmpty ? "?" : result
    }
}

protocol AuthServiceProtocol: AnyObject {
    var isAuthenticated: Bool { get }
    var currentUserInfo: UserInfo? { get }
    @MainActor func signInWithGoogle() async throws
    func prepareAppleNonce() -> String
    func handleAppleSignIn(_ authorization: ASAuthorization) async throws
    func signOut() throws
    func deleteAccount() async throws
}

final class AuthService: ObservableObject, AuthServiceProtocol {

    @Published var isAuthenticated = false

    private var currentNonce: String?

    var currentUserInfo: UserInfo? {
        guard let user = Auth.auth().currentUser else { return nil }
        return UserInfo(
            displayName: user.displayName,
            email: user.email,
            photoURL: user.photoURL
        )
    }

    init() {
        isAuthenticated = Auth.auth().currentUser != nil
    }

    // MARK: - Google Sign-In

    @MainActor
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingToken
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else { throw AuthError.noRootViewController }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        try await Auth.auth().signIn(with: credential)
        isAuthenticated = true
    }

    // MARK: - Apple Sign-In

    func prepareAppleNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }

    func handleAppleSignIn(_ authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else { throw AuthError.missingToken }

        let nonce = currentNonce ?? ""
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        try await Auth.auth().signIn(with: credential)
        isAuthenticated = true
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        isAuthenticated = false
    }

    // MARK: - Delete Account

    func deleteAccount() async throws {
        try await Auth.auth().currentUser?.delete()
        await MainActor.run {
            isAuthenticated = false
        }
    }

    // MARK: - Nonce Helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        guard errorCode == errSecSuccess else {
            return UUID().uuidString
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

enum AuthError: Error, LocalizedError {
    case noRootViewController
    case missingToken

    var errorDescription: String? {
        switch self {
        case .noRootViewController: return "Não foi possível encontrar a janela principal"
        case .missingToken: return "Token de autenticação não encontrado"
        }
    }
}
