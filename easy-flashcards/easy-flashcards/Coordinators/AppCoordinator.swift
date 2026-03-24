import Combine
import FirebaseAuth
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

    init() {
        if Auth.auth().currentUser != nil {
            appState = .home
        }
    }

    func login() {
        appState = .home
    }

    func logout() {
        try? Auth.auth().signOut()
        homePath = NavigationPath()
        appState = .login
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
