import Foundation

// MARK: - Requests & Responses
struct RegisterRequest: Codable {
    let email: String
    let nickname: String
    let password: String
}

struct LoginRequest: Codable {
    let email_or_nick: String
    let password: String
}

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
}

struct UserResponse: Codable {
    let id: Int
    let email: String
    let nickname: String
    let verified: Bool

    enum CodingKeys: String, CodingKey {
        case id, email, nickname, verified
    }
}

struct APIError: Codable {
    let detail: String
}

enum AuthError: Error, LocalizedError {
    case networkError
    case serverError(String)
    case notAuthenticated
    case unknownError

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error"
        case .serverError(let message):
            return message
        case .notAuthenticated:
            return "Not authenticated"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

// MARK: - AuthService
class AuthService: ObservableObject {
    private let baseURL = APIConfig.baseURL

    // --- Добавлено ---
    var onRegistrationSuccess: (() -> Void)?
    var onLoginSuccess: (() -> Void)?
    // --- Конец добавления ---

    func register(nickname: String, email: String, password: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)/register")!

        let body = RegisterRequest(email: email, nickname: nickname, password: password)
        let jsonData = try JSONEncoder().encode(body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }

        if httpResponse.statusCode == 200 {
            // Успешная регистрация, но email не подтвержден
            // Вызываем замыкание для перехода (например, к экрану ввода кода)
            DispatchQueue.main.async {
                self.onRegistrationSuccess?()
            }
            return true
        } else if httpResponse.statusCode == 400 {
            let errorResponse = try? JSONDecoder().decode(APIError.self, from: data)
            throw AuthError.serverError(errorResponse?.detail ?? "Registration failed")
        } else {
            throw AuthError.unknownError
        }
    }

    func verifyEmail(token: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)/verify")!

        let body = ["token": token]
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }

        if httpResponse.statusCode == 200 {
            return true
        } else {
            let errorResponse = try? JSONDecoder().decode(APIError.self, from: data)
            throw AuthError.serverError(errorResponse?.detail ?? "Verification failed")
        }
    }

    func login(emailOrNick: String, password: String) async throws -> TokenResponse {
        let url = URL(string: "\(baseURL)/login")!

        let body = LoginRequest(email_or_nick: emailOrNick, password: password)
        let jsonData = try JSONEncoder().encode(body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }

        if httpResponse.statusCode == 200 {
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            // Сохранить токен в UserDefaults
            UserDefaults.standard.set(tokenResponse.access_token, forKey: "AccessToken")

            // Вызываем замыкание для перехода на главный экран
            DispatchQueue.main.async {
                self.onLoginSuccess?()
            }
            return tokenResponse
        } else if httpResponse.statusCode == 400 || httpResponse.statusCode == 403 {
            let errorResponse = try? JSONDecoder().decode(APIError.self, from: data)
            throw AuthError.serverError(errorResponse?.detail ?? "Login failed")
        } else {
            throw AuthError.unknownError
        }
    }

    func getCurrentUser() async throws -> UserResponse {
        let token = UserDefaults.standard.string(forKey: "AccessToken")
        guard let token = token else {
            throw AuthError.notAuthenticated
        }

        let url = URL(string: "\(baseURL)/me")!

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }

        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(UserResponse.self, from: data)
        } else {
            throw AuthError.notAuthenticated
        }
    }
}
