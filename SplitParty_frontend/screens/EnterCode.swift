import SwiftUI

struct EnterCodeView: View {
    @EnvironmentObject var authService: AuthService // Получаем AuthService из environment
    // @Environment(\.navigationPath) private var path // Убедитесь, что это определено в AppNavigator или родительском View, передающем authService

    @State private var code: String = ""
    @State private var timeRemaining: Int = 60
    @State private var timerActive: Bool = true
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    // Таймер отдельной публикации
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private func submitCode() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let success = try await authService.verifyEmail(token: code)
                if success {
                    print("Email verified successfully")
                    // Пример перехода: path.append(AppRoute.login) // Или на экран входа, или сразу на главный
                    // Замените на вашу логику навигации, например:
                    // path.append(AppRoute.home) // Если сразу после верификации хотите на главный экран
                    // path.append(AppRoute.login) // Если хотите вернуться к логину
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func resendCode() {
        // Логика повторной отправки кода
        // В бэкенде у вас есть только эндпоинт для повторной регистрации
        // Возможно, нужно добавить отдельный эндпоинт для повторной отправки
        print("Code resent")
        code = ""
        timeRemaining = 60
        timerActive = true
    }

    var body: some View {
        VStack(spacing: 30) {
            HeaderView()

            CodeTextField(code: $code)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            TimerView(timeRemaining: $timeRemaining, timerActive: $timerActive, resendAction: resendCode)

            Spacer()

            Button(action: submitCode) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Продолжить")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(code.count >= 4 ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .disabled(code.count < 4 || isLoading)
        }
        .padding()
        .disabled(isLoading)
        .onReceive(timer) { _ in
            if timerActive && timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timerActive = false
            }
        }
    }
}

// MARK: - Header
struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Введите код")
                .font(.system(size: 28, weight: .bold))

            Text("Мы отправили код на вашу почту. Введите его ниже")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Code TextField с AutoFill и серой рамкой
struct CodeTextField: View {
    @Binding var code: String

    var body: some View {
        TextField("Введите код", text: $code)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode) // Автозаполнение из SMS
            .multilineTextAlignment(.center)
            .font(.system(size: 24, weight: .medium))
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .frame(maxWidth: 250)
    }
}

// MARK: - Timer View
struct TimerView: View {
    @Binding var timeRemaining: Int
    @Binding var timerActive: Bool
    var resendAction: () -> Void

    var body: some View {
        if timerActive {
            Text("Повторная отправка через \(timeRemaining) сек")
                .foregroundColor(.secondary)
                .font(.system(size: 14))
        } else {
            Button(action: resendAction) {
                Text("Отправить код повторно")
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))
            }
        }
    }
}

// #Preview {
//     EnterCodeView() // Для Preview потребуется @StateObject или .environmentObject
// }    
