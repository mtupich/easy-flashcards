import Foundation

protocol LoginRepositoryProtocol {
    func login(credentials: LoginCredentials) async throws -> Bool
}

final class LoginRepository: LoginRepositoryProtocol {
    func login(credentials: LoginCredentials) async throws -> Bool {
        return true
    }
}
