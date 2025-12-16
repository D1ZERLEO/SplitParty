import SwiftUI

struct MusicAccountView: View {
    @State private var token = ""
    @State private var isTokenSaved = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Инструкция
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Как получить токен Яндекс.Музыки")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("1. Откройте приложение Яндекс.Музыка на своём устройстве.")
                            .font(.body)
                            .foregroundColor(.primary)

                        Text("2. Войдите в свой аккаунт.")
                            .font(.body)
                            .foregroundColor(.primary)

                        Text("3. Откройте инструменты разработчика (DevTools) в браузере или используйте мобильное ПО, чтобы получить токен.")
                            .font(.body)
                            .foregroundColor(.primary)

                        Text("4. Вставьте токен в поле ниже.")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding()

                    // Поле ввода токена
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Введите токен:")
                            .font(.headline)
                            .foregroundColor(.primary)

                        TextField("Токен", text: $token)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal)

                    // Кнопка сохранения
                    Button("Сохранить токен") {
                        saveToken()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .padding()

                    // Статус сохранения
                    if isTokenSaved {
                        Text("✅ Токен успешно сохранён!")
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(.horizontal)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Яндекс.Музыка")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }

    private func saveToken() {
        // Сохраняем токен в UserDefaults
        UserDefaults.standard.set(token, forKey: "YandexMusicToken")
        isTokenSaved = true

        // Опционально: сбросить через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isTokenSaved = false
        }
    }
}
