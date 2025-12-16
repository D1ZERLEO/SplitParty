import SwiftUI

struct PlaylistView: View {
    @State private var savedPlaylistExists = false
    @State private var playlistName = ""
    @State private var playlistType: PlaylistType = .random
    @State private var trackLinks: [String] = []
    @State private var newTrackLink = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 1. Кнопка открытия сохранённого плейлиста
                Button(action: openSavedPlaylist) {
                    Text("Открыть сохранённый плейлист")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(savedPlaylistExists ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!savedPlaylistExists)

                // 2. Поле ввода названия плейлиста
                TextField("Название плейлиста", text: $playlistName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)

                // Переключатель типа плейлиста
                Picker("Тип плейлиста", selection: $playlistType) {
                    Text("Рандомный").tag(PlaylistType.random)
                    Text("Дополняемый").tag(PlaylistType.appendable)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: .infinity)

                // === РАНДОМНЫЙ ПЛЕЙЛИСТ ===
                if playlistType == .random {
                    Text("Не забудьте авторизоваться через Яндекс.Музыку")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: createRandomPlaylist) {
                        Text("Создать плейлист")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                // === ДОПОЛНЯЕМЫЙ ПЛЕЙЛИСТ ===
                if playlistType == .appendable {
                    HStack {
                        TextField("Ссылка на трек", text: $newTrackLink)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: addTrack) {
                            Text("Добавить")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .frame(height: 34)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Список добавленных треков
                    ForEach(trackLinks.indices, id: \.self) { index in
                        HStack {
                            Text(trackLinks[index])
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button(action: { deleteTrack(at: index) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.top, 10)

                    Text("Не забудьте авторизоваться через Яндекс.Музыку")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button("Сохранить плейлист") {
                        saveAppendablePlaylist()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .navigationTitle("Плейлист")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Скрываем стандартную кнопку назад
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Уведомление"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .animation(.easeInOut, value: playlistType)
    }

    // MARK: - Actions

    private func openSavedPlaylist() {
        alertMessage = "Плейлист открыт"
        showAlert = true
    }

    private func createRandomPlaylist() {
        guard !playlistName.isEmpty else {
            alertMessage = "Введите название плейлиста"
            showAlert = true
            return
        }
        savedPlaylistExists = true
        alertMessage = "Плейлист успешно создан!"
        showAlert = true
    }

    private func addTrack() {
        guard !newTrackLink.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        trackLinks.append(newTrackLink.trimmingCharacters(in: .whitespaces))
        newTrackLink = ""
        alertMessage = "Композиция добавлена"
        showAlert = true
    }

    private func deleteTrack(at index: Int) {
        trackLinks.remove(at: index)
        alertMessage = "Удалено"
        showAlert = true
    }

    private func saveAppendablePlaylist() {
        guard !playlistName.isEmpty else {
            alertMessage = "Введите название плейлиста"
            showAlert = true
            return
        }
        guard !trackLinks.isEmpty else {
            alertMessage = "Добавьте хотя бы один трек"
            showAlert = true
            return
        }
        savedPlaylistExists = true
        alertMessage = "Плейлист сохранён"
        showAlert = true
    }
}

enum PlaylistType: String, CaseIterable {
    case random
    case appendable
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlaylistView()
        }
    }
}
