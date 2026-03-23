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

    func login() {
        appState = .home
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
