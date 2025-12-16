import SwiftUI

struct ResetPasswordView: View {

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showNewPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @FocusState private var focusedField: Field?

    enum Field {
        case newPassword, confirmPassword
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            Text("Смена пароля")
                .font(.largeTitle.bold())
                .padding(.top, 20)
            
            // Поле для нового пароля с глазиком
            ZStack(alignment: .trailing) {
                Group {
                    if showNewPassword {
                        TextField("Новый пароль", text: $newPassword)
                            .autocapitalization(.none)
                    } else {
                        SecureField("Новый пароль", text: $newPassword)
                    }
                }
                .focused($focusedField, equals: .newPassword)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                
                Button(action: {
                    showNewPassword.toggle()
                }) {
                    Image(systemName: showNewPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing, 12)
                }
            }
            
            // Поле для подтверждения пароля с глазиком
            ZStack(alignment: .trailing) {
                Group {
                    if showConfirmPassword {
                        TextField("Подтверждение пароля", text: $confirmPassword)
                            .autocapitalization(.none)
                    } else {
                        SecureField("Подтверждение пароля", text: $confirmPassword)
                    }
                }
                .focused($focusedField, equals: .confirmPassword)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                
                Button(action: {
                    showConfirmPassword.toggle()
                }) {
                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing, 12)
                }
            }
            
            // Кнопка Сбросить пароль
            Button(action: resetPassword) {
                Text("Сбросить пароль")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canReset ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!canReset)
            
            // Внизу текст и кнопка для входа
            HStack {
                Text("Вспомнили пароль?")
                    .foregroundColor(.gray)
                NavigationLink(value: AppRoute.login) {
                    Text("Войти в аккаунт")
                        .foregroundColor(.blue)
                        .bold()
                }
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .newPassword
            }
        }
    }
    
    // Проверка, можно ли включить кнопку
    private var canReset: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }
    
    // Действие кнопки Сбросить пароль
    private func resetPassword() {
        print("Новый пароль: \(newPassword), Подтверждение: \(confirmPassword)")
        // Тут можно добавить вызов API для сброса пароля
        // После успешного сброса можно перейти на другой экран, например:
        // path.append(AppRoute.passwordChanged)
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
