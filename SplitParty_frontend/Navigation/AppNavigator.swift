import SwiftUI

struct AppNavigator: View {
    @State private var path = NavigationPath()
    @StateObject private var authService = AuthService() // Создаем один экземпляр

    var body: some View {
        NavigationStack(path: $path) {
            HomeScreen()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .login:
                        LoginScreen(authService: authService) // Передаем authService
                    case .register:
                        RegisterScreen(authService: authService) // Передаем authService
                    case .forgotPassword:
                        ForgotPasswordView()
                    case .enterCode(let isRegistration):
                        // Если нужно, можно передать параметр в EnterCodeView
                        EnterCodeView()
                    case .resetPassword:
                        ResetPasswordView()
                    case .passwordChanged:
                        PasswordChangedView()
                    case .home:
                        MyPartiesView()
                    }
                }
        }
        .onAppear {
            // Устанавливаем замыкания для навигации
            authService.onRegistrationSuccess = { }
            authService.onLoginSuccess = {
                path.append(AppRoute.home)
            }
        }
    }
}

#Preview {
    AppNavigator()
}
