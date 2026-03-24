import Combine
import SwiftUI

enum AppState: Equatable {
    case login
    case home
}

enum Route: Hashable {
    case deckDetail(deckId: UUID)
    case pronunciation
}

final class AppCoordinator: ObservableObject {

    @Published var appState: AppState = .login
    @Published var homePath = NavigationPath()

    private let authService: AuthServiceProtocol

    var currentUserInfo: UserInfo? {
        authService.currentUserInfo
    }

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        if authService.isAuthenticated {
            appState = .home
        }
    }

    func login() {
        appState = .home
    }

    func logout() {
        try? authService.signOut()
        homePath = NavigationPath()
        appState = .login
    }

    func deleteAccount() async {
        try? await authService.deleteAccount()
        await MainActor.run {
            homePath = NavigationPath()
            appState = .login
        }
    }

    func push(_ route: Route) {
        homePath.append(route)
    }

    func pop() {
        guard !homePath.isEmpty else { return }
        homePath.removeLast()
    }

    func popToRoot() {
        homePath = NavigationPath()
    }
}
