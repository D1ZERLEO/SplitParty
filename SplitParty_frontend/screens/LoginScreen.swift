import SwiftUI

struct LoginScreen: View {
    @ObservedObject var authService: AuthService
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordHidden: Bool = true
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    private func loginUser() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let tokenResponse = try await authService.login(emailOrNick: email, password: password)
                print("Login successful, token: \(tokenResponse.access_token)")
                // Навигация будет выполнена через замыкание в authService
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                // Заголовок
                Text("Войти в аккаунт")
                    .font(.system(size: min(30, geo.size.width * 0.075), weight: .bold))
                    .foregroundColor(Color.black)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer().frame(height: geo.size.height * 0.04)

                // Поле Email
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email или ник")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    TextField("Введите email или ник", text: $email)
                        .padding()
                        .background(Color.white)
                        .autocapitalization(.none)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal, geo.size.width * 0.08)

                Spacer().frame(height: 18)

                // Поле Пароль
                VStack(alignment: .leading, spacing: 6) {
                    Text("Пароль")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    HStack {
                        if isPasswordHidden {
                            SecureField("Введите пароль", text: $password)
                        } else {
                            TextField("Введите пароль", text: $password)
                        }

                        Button(action: {
                            isPasswordHidden.toggle()
                        }) {
                            Image(systemName: isPasswordHidden ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, geo.size.width * 0.08)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, geo.size.width * 0.08)
                }

                // Забыли пароль?
                NavigationLink(value: AppRoute.forgotPassword) {
                    Text("Забыли пароль?")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
                .padding(.horizontal, geo.size.width * 0.08)

                Spacer()

                // Кнопка "Войти в аккаунт"
                Button(action: loginUser) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    } else {
                        Text("Войти в аккаунт")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, geo.size.width * 0.08)
                .disabled(isLoading)

                // Текст снизу
                HStack {
                    Text("Нет аккаунта?")
                        .foregroundColor(.black)
                    NavigationLink(value: AppRoute.register) {
                        Text("Создайте его")
                            .foregroundColor(.blue)
                            .underline()
                    }
                }
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, geo.size.height * 0.04)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .disabled(isLoading)
        }
    }
}
