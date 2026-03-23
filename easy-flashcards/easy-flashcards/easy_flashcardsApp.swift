import SwiftUI

@main
struct EasyFlashcardsApp: App {

    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            Group {
                switch coordinator.appState {
                case .login:
                    LoginView()
                        .transition(.opacity)

                case .home:
                    NavigationStack(path: $coordinator.homePath) {
                        HomeView()
                            .navigationDestination(for: Route.self) { route in
                                switch route {
                                case .deckDetail:
                                    Text("Detalhe do Baralho")
                                }
                            }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: coordinator.appState)
            .environmentObject(coordinator)
            .preferredColorScheme(.dark)
        }
    }
}
