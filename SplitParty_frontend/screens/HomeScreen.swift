import SwiftUI

struct HomeScreen: View {
    
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                
                // Верхний контент (текст + картинка)
                VStack {
                    // Немного пространства сверху (чтобы текст не прилипал)
                    Spacer(minLength: geo.size.height * 0.05)
                    
                    // Текст
                    VStack(spacing: 8) {
                        Text("Добро пожаловать!")
                            .font(.system(size: min(34, geo.size.width * 0.08), weight: .bold))
                            .foregroundColor(Color(hex: "#000000"))
                        
                        Text("Присоединяйся к нашему проекту и забудь\nпро неловкие разговоры о деньгах!")
                            .multilineTextAlignment(.center)
                            .font(.system(size: min(15, geo.size.width * 0.045)))
                            .foregroundColor(Color(hex: "#808080"))
                    }
                    .padding(.horizontal, geo.size.width * 0.08)
                    
                    // Картинка по центру экрана
                    Spacer()
                    
                    Image("my_logo")
                        .resizable() // Делаем изображение масштабируемым
                        .aspectRatio(contentMode: .fit) // Сохраняем пропорции
                        .frame(
                            maxWidth: min(420, geo.size.width * 0.9),
                            maxHeight: geo.size.height * 0.35
                        )
                        .clipped()
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Кнопки СНИЗУ
                VStack(spacing: 14) {
                    NavigationLink(value: AppRoute.login) {
                        Text("Войти в аккаунт")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#000000"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(value: AppRoute.register) {
                        Text("Зарегистрироваться")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, geo.size.width * 0.08)
                .padding(.bottom, max(30, geo.size.height * 0.06))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#FFFFFF").edgesIgnoringSafeArea(.all))
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeScreen()
        }
    }
}
