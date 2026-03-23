import Combine
import Foundation

final class LoginViewModel: ObservableObject {

    @Published var username = ""
    @Published var password = ""

    private let repository: LoginRepositoryProtocol

    init(repository: LoginRepositoryProtocol = LoginRepository()) {
        self.repository = repository
    }
}
