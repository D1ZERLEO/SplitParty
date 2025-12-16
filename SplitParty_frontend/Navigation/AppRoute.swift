import SwiftUI

// Все экраны приложения
enum AppRoute: Hashable {
    case home
    case login
    case register
    case forgotPassword
    case enterCode(isFromRegister: Bool)
    case resetPassword
    case passwordChanged
}

// Центральный объект навигации
class AppRouter: ObservableObject {
    @Published var path: [AppRoute] = []

    func go(to route: AppRoute) {
        path.append(route)
    }

    func goBack() {
        _ = path.popLast()
    }

    func reset(to route: AppRoute) {
        path = [route]
    }
}
