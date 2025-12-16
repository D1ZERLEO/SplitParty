import SwiftUI

struct AccountView: View {
    @State private var isEditing = false
    @State private var showingAvatarPicker = false
    
    // Основные данные
    @State private var nickname = "@Bobik"
    @State private var phoneNumber = "+7 (999) 123-45-67"
    @State private var bank = "ВТБ"
    @State private var totalSpent = "45 500 ₽"
    @State private var selectedAvatar = "avatar1"

    // Временные переменные для редактирования
    @State private var tempNickname = ""
    @State private var tempBank = ""
    @State private var tempAvatar = ""

    let avatarOptions = [
        "avatar8", "avatar1", "avatar2", "avatar3",
        "avatar4", "avatar5", "avatar6", "avatar7"
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Блок аватарки + инфо — РАСТЯНУТ ПО ВСЕЙ ШИРИНЕ
                HStack(spacing: 16) {
                    // Аватарка — фиксированная ширина, но прижата к левому краю
                    Button(action: {
                        if isEditing {
                            showingAvatarPicker = true
                        }
                    }) {
                        ZStack(alignment: .bottomTrailing) {
                            Image(selectedAvatar)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 2)
                                )
                            
                            if isEditing {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Circle().fill(Color.black))
                                    .offset(x: 4, y: 4)
                            }
                        }
                    }
                    
                    // Информация — занимает всё оставшееся пространство
                    VStack(alignment: .leading, spacing: 4) {
                        if isEditing {
                            TextField("Введите ник", text: $tempNickname)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.headline)
                        } else {
                            Text(nickname)
                                .font(.headline)
                                .bold()
                        }
                        
                        // Номер телефона - всегда только для чтения
                        Text(phoneNumber)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if isEditing {
                            TextField("Банк", text: $tempBank)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.caption)
                        } else {
                            Text(bank)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Кнопка "Изменить" — только если не в режиме редактирования
                    if !isEditing {
                        Button(action: {
                            enterEditingMode()
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.black)
                                .font(.system(size: 16))
                        }
                        .padding(.trailing, 8)
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                
                // Кнопка "Сохранить изменения" — по всей ширине
                if isEditing {
                    Button("Сохранить изменения") {
                        saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .padding(.horizontal)
                }
                
                // Блок "Общая сумма трат" + "Аккаунт Яндекс.музыки"
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "doc.text")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Text("Общая сумма трат")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Text(totalSpent)
                            .font(.title2)
                            .bold()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            .background(Color.white)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    NavigationLink(destination: MusicAccountView()) {
                        VStack {
                            Image(systemName: "music.note")
                                .foregroundColor(.black)
                            Text("Аккаунт Яндекс.музыки")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                .background(Color.white)
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // Кнопки навигации — теперь белые с серой обводкой
                VStack(spacing: 12) {
                    NavigationLink(destination: FriendsView()) {
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(.black)
                            Text("Друзья")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                .background(Color.white)
                        )
                    }
                    
                    Button(action: {
                        print("Выход из аккаунта")
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                            Text("Выйти из аккаунта")
                                .font(.body)
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                .background(Color.white)
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true) // Добавь эту строку
            .sheet(isPresented: $showingAvatarPicker) {
                AvatarPickerView(
                    selectedAvatar: $tempAvatar,
                    avatarOptions: avatarOptions,
                    isPresented: $showingAvatarPicker
                )
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // Функция входа в режим редактирования
    private func enterEditingMode() {
        isEditing = true
        tempNickname = nickname
        tempBank = bank
        tempAvatar = selectedAvatar
    }
    
    // Функция сохранения изменений
    private func saveChanges() {
        nickname = tempNickname
        bank = tempBank
        selectedAvatar = tempAvatar
        isEditing = false
    }
    
    // Функция отмены изменений (при нажатии "Назад")
    private func cancelEditing() {
        tempNickname = nickname
        tempBank = bank
        tempAvatar = selectedAvatar
        isEditing = false
    }
}

// Новый View для выбора аватарки
struct AvatarPickerView: View {
    @Binding var selectedAvatar: String
    let avatarOptions: [String]
    @Binding var isPresented: Bool
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(avatarOptions, id: \.self) { avatarName in
                        Button(action: {
                            selectedAvatar = avatarName
                            isPresented = false
                        }) {
                            Image(avatarName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(selectedAvatar == avatarName ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Выберите аватарку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        isPresented = false
                    }
                }
            }
        }
    }
}


// Предварительный просмотр
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
