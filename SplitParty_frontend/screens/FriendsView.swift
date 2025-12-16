import SwiftUI

struct FriendsView: View {
    // Модель пользователя
    struct User: Identifiable {
        let id = UUID()
        let nickname: String  // Ник через @
        let avatarName: String // Имя изображения аватарки
    }

    // Состояния
    @State private var searchText = ""
    @State private var friends: [User] = [] // Подписки
    @State private var allUsers: [User] = [
        User(nickname: "@annushka", avatarName: "avatar1"),
        User(nickname: "@ivans", avatarName: "avatar2"),
        User(nickname: "@mary_k", avatarName: "avatar3"),
        User(nickname: "@lexa", avatarName: "avatar4"),
        User(nickname: "@katya", avatarName: "avatar5"),
        User(nickname: "@dima", avatarName: "avatar6"),
        User(nickname: "@olya", avatarName: "avatar7")
    ]

    var body: some View {
        NavigationView {
            VStack {
                // Поисковая строка
                SearchBar(text: $searchText, placeholder: "Поиск по нику")
                    .padding(.horizontal)

                // Список друзей
                ScrollView {
                    VStack(spacing: 12) {
                        // Заголовок "Друзья"
                        HStack {
                            Text("Друзья (\(friends.count))")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal)

                        // Список друзей
                        ForEach(friends.filter { searchText.isEmpty || $0.nickname.localizedCaseInsensitiveContains(searchText) }) { friend in
                            HStack(spacing: 12) {
                                // Аватарка
                                Image(friend.avatarName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                    )

                                // Ник
                                Text(friend.nickname)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                    .background(Color.white)
                            )
                        }

                        // Заголовок "Найти пользователей"
                        HStack {
                            Text("Найти пользователей")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal)

                        // Список всех пользователей, не являющихся друзьями
                        ForEach(allUsers.filter { user in
                            !friends.contains(where: { $0.id == user.id }) && (
                                searchText.isEmpty || user.nickname.localizedCaseInsensitiveContains(searchText)
                            )
                        }) { user in
                            HStack(spacing: 12) {
                                // Аватарка
                                Image(user.avatarName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                    )

                                // Ник
                                Text(user.nickname)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Spacer()

                                // Кнопка "Подписаться"
                                Button("Подписаться") {
                                    subscribe(to: user)
                                }
                                .buttonStyle(.bordered)
                                .tint(.black)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                    .background(Color.white)
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Друзья")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }

    // Функция подписки
    private func subscribe(to user: User) {
        if !friends.contains(where: { $0.id == user.id }) {
            friends.append(user)
        }
    }
}

// Поисковая строка
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
        .padding(.vertical, 4)
    }
}
