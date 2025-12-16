import SwiftUI

struct ForgotPasswordView: View {

    @State private var email: String = ""
    @FocusState private var emailFieldIsFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Заголовок сверху
            Text("Забыли пароль?")
                .font(.largeTitle.bold())
                .padding(.top, 5)

            // Серый текст под заголовком
            Text("Ну что, пароль тоже решил отдохнуть? Оставь свой email и мы вернем доступ к аккаунту")
                .foregroundColor(.gray)
                .font(.body)

            // Поле для ввода email с серой рамкой
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($emailFieldIsFocused)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(.vertical, 10)

            // Кнопка Отправить код
            // ✅ Изменяем на AppRoute.resetPassword
            NavigationLink(value: AppRoute.resetPassword) {
                Button(action: {
                }) {
                    Text("Отправить код")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(email.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(email.isEmpty)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            // Автоматически активируем клавиатуру
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                emailFieldIsFocused = true
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
