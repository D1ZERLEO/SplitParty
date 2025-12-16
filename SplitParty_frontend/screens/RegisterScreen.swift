import SwiftUI

struct RegisterScreen: View {
    @ObservedObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    
    @State private var nickname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordHidden: Bool = true
    @State private var isAgreementChecked: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showVerificationAlert: Bool = false

    // MARK: - Проверка пароля
    private func hasDigit(_ text: String) -> Bool { text.rangeOfCharacter(from: .decimalDigits) != nil }
    private func hasLatinLetters(_ text: String) -> Bool { text.range(of: "[a-zA-Z]", options: .regularExpression) != nil }
    private func hasValidLength(_ text: String) -> Bool { (8...16).contains(text.count) }
    private func hasSpecialSymbol(_ text: String) -> Bool { text.range(of: "[!*.?]", options: .regularExpression) != nil }

    var isPasswordValid: Bool {
        hasDigit(password) && hasLatinLetters(password) && hasValidLength(password) && hasSpecialSymbol(password)
    }

    private func registerUser() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let success = try await authService.register(nickname: nickname, email: email, password: password)
                if success {
                    await MainActor.run {
                        showVerificationAlert = true
                    }
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Заголовок
                        Text("Создайте аккаунт")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 32)

                        // Поля
                        VStack(spacing: 16) {
                            // Ник
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Ник (уникальное имя пользователя)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                TextField("Введите ник", text: $nickname)
                                    .padding()
                                    .background(Color.white)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.3), lineWidth: 1))
                            }

                            // Email
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                TextField("Введите email", text: $email)
                                    .padding()
                                    .background(Color.white)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.3), lineWidth: 1))
                            }

                            // Пароль
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

                                    Button(action: { isPasswordHidden.toggle() }) {
                                        Image(systemName: isPasswordHidden ? "eye.slash" : "eye")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.3), lineWidth: 1))

                                // Правила пароля
                                VStack(alignment: .leading, spacing: 4) {
                                    passwordRuleRow("Минимум одну цифру", isValid: hasDigit(password))
                                    passwordRuleRow("Только латинские буквы", isValid: hasLatinLetters(password))
                                    passwordRuleRow("Длина от 8 до 16 символов", isValid: hasValidLength(password))
                                    passwordRuleRow("Минимум один спец символ (!, *, ?)", isValid: hasSpecialSymbol(password))
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal, 32)

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 32)
                        }

                        Spacer().frame(height: 40)
                    }
                }

                // MARK: - Нижняя панель
                VStack(spacing: 12) {
                    // Пользовательское соглашение
                    HStack(alignment: .center, spacing: 8) {
                        Button(action: { isAgreementChecked.toggle() }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                if isAgreementChecked {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                        }

                        Text("Я согласен с ")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)

                        Button(action: {
                            if let url = URL(string: "https://example.com/terms") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("пользовательским соглашением")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                                .underline()
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 32)

                    // Кнопка Зарегистрироваться
                    Button(action: registerUser) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        } else {
                            Text("Зарегистрироваться")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isAgreementChecked && isPasswordValid ? Color.black : Color.gray.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 32)
                    .disabled(!(isAgreementChecked && isPasswordValid) || isLoading)

                    // Ссылка "Уже есть аккаунт?"
                    HStack(spacing: 0) {
                        Text("Уже есть аккаунт? ")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        NavigationLink(value: AppRoute.login) {
                            Text("Войдите в него")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                }
                .background(Color.white)
            }
            .disabled(isLoading)
            .edgesIgnoringSafeArea(.bottom)
            .alert("Проверьте вашу почту", isPresented: $showVerificationAlert) {
                Button("OK", role: .cancel) {
                    // После регистрации возвращаемся на экран входа
                    dismiss()
                }
            } message: {
                Text("На вашу почту \(email) отправлена ссылка для верификации. Пожалуйста, проверьте вашу электронную почту и подтвердите аккаунт перед входом.")
            }
        }
    }

    // MARK: - Вспомогательная функция для строки правила пароля
    @ViewBuilder
    private func passwordRuleRow(_ text: String, isValid: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
}
