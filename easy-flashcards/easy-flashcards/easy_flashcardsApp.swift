import FirebaseCore
import GoogleSignIn
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct EasyFlashcardsApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
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
                                case .deckDetail(let deckId):
                                    DeckDetailView(deckId: deckId)
                                case .pronunciation:
                                    PronunciationView()
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
