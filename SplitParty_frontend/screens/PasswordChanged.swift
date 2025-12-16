import SwiftUI

struct PasswordChangedView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Заголовок
            Text("Пароль изменён")
                .font(.title.bold())
                .multilineTextAlignment(.center)
            
            // Подзаголовок
            Text("Ваш пароль был успешно изменён")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Кнопка Войти в аккаунт
            Button(action: {
                // Возврат на экран входа
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Войти в аккаунт")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
    }
}

struct PasswordChangedView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordChangedView()
    }
}
