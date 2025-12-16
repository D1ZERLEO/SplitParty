import SwiftUI
// MARK: - Models
struct Participant: Identifiable, Hashable {
    let id: UUID
    var name: String
    var avatarLetter: String
    var isAdmin: Bool
}
struct Party: Identifiable {
    let id: UUID
    var title: String
    var dateRange: String
    var participants: [Participant]
}
// Sample data
extension Participant {
    static let alice = Participant(id: .init(), name: "@kiselik", avatarLetter: "K", isAdmin: true)
    static let bob = Participant(id: .init(), name: "@honer", avatarLetter: "H", isAdmin: false)
    static let cat = Participant(id: .init(), name: "@govnukov", avatarLetter: "G", isAdmin: false)
    static let dima = Participant(id: .init(), name: "@aristov", avatarLetter: "A", isAdmin: false)
}
extension Party {
    static let sample = Party(id: .init(), title: "Afterwork в центре", dateRange: "18.09-27.10", participants: [Participant.alice, Participant.bob, Participant.cat, Participant.dima])
    static let sample2 = Party(id: .init(), title: "Киноночь", dateRange: "01.11-05.11", participants: [Participant.bob, Participant.cat])
}
// MARK: - MyPartiesView
struct MyPartiesView: View {
    @State private var parties: [Party] = [Party.sample, Party.sample2]
    @State private var searchText: String = ""
    @State private var selectedParty: Party? = nil
    @State private var showDetail: Bool = false
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)
                HStack {
                    Text("Мои тусовки")
                        .font(.system(size: 30, weight: .bold))
                    Spacer()
                    NavigationLink(destination: AccountView()) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal, 20)
                TextField("Поиск тусовок", text: $searchText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                Button(action: {
                    let new = Party(id: UUID(), title: "Новая тусовка", dateRange: "01.01-01.02", participants: [Participant.alice])
                    parties.insert(new, at: 0)
                }) {
                    Text("+ Добавить тусовку")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(filteredParties, id: \.id) { party in
                            PartyRowView(party: party)
                                .onTapGesture {
                                    selectedParty = party
                                    showDetail = true
                                }
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 10)
                }
                Spacer()
            }
            .sheet(isPresented: $showDetail) {
                if let party = selectedParty {
                    PartyDetailSheetView(
                        party: party,
                        onSaveParty: { updatedParty in
                            if let idx = parties.firstIndex(where: { $0.id == updatedParty.id }) {
                                parties[idx] = updatedParty
                            }
                        }
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    private var filteredParties: [Party] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return parties
        } else {
            return parties.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.dateRange.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
// MARK: - PartyDetailSheetView
struct PartyDetailSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    var party: Party
    var onSaveParty: ((Party) -> Void)?
    @State private var partyState: Party
    @State private var showEditTitle: Bool = false
    @State private var editedTitle: String = ""
    @State private var editedDate: String = ""
    @State private var showEditParticipants: Bool = false
    init(party: Party, onSaveParty: ((Party) -> Void)? = nil) {
        self.party = party
        self.onSaveParty = onSaveParty
        self._partyState = State(initialValue: party)
    }
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                headerView
                Divider()
                contentView
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditParticipants) {
                EditParticipantsView(
                    party: $partyState,
                    allUsers: allUsersSample(),
                    onSave: { updated in
                        self.partyState = updated
                        onSaveParty?(updated)
                        showEditParticipants = false
                    }
                )
            }
        }
    }
    // MARK: - Subviews
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if showEditTitle {
                    TextField("Название тусовки", text: $editedTitle)
                        .textFieldStyle(.roundedBorder)
                    TextField("Дата тусовки", text: $editedDate)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(partyState.title)
                        .font(.title2)
                        .foregroundColor(.black)
                    Text(partyState.dateRange)
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Button(action: toggleEditTitle) {
                Image(systemName: showEditTitle ? "checkmark.circle.fill" : "gearshape")
                    .font(.title2)
                    .foregroundColor(showEditTitle ? .green : .black)
            }
        }
        .padding(.horizontal)
        .padding(.top, 18)
    }
    private var contentView: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 12) {
                        playlistButton
                        sharedBillButton
                        participantsSection
                    }
                    .padding(.horizontal)
                }
                .frame(height: geometry.size.height - 100)
                bottomButtons
            }
        }
    }
    private var playlistButton: some View {
        NavigationLink(destination: PlaylistView()) {
            HStack {
                Text("Совместный плейлист")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    private var sharedBillButton: some View {
        NavigationLink(destination: SharedBillView(party: partyState)) {
            HStack {
                Text("Общий счет")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Участники (\(partyState.participants.count))")
                .font(.title3)
                .foregroundColor(.gray)
            ForEach(partyState.participants) { participant in
                participantRow(participant)
            }
        }
        .padding(.top, 8)
    }
    private func participantRow(_ participant: Participant) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 44, height: 44)
                .overlay(Text(participant.avatarLetter).font(.headline))
            VStack(alignment: .leading) {
                Text(participant.name)
                    .font(.title3)
                if participant.isAdmin {
                    Text("(Админ)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding(6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    private var bottomButtons: some View {
        VStack(spacing: 12) {
            Button(action: { showEditParticipants = true }) {
                Text("Изменить участников")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Закрыть")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .cornerRadius(12)
            }
        }
        .padding(.top, -20)
        .padding(.bottom, 10)
    }
    // MARK: - Helper Methods
    private func toggleEditTitle() {
        if showEditTitle {
            if !editedTitle.isEmpty { partyState.title = editedTitle }
            if !editedDate.isEmpty { partyState.dateRange = editedDate }
            onSaveParty?(partyState)
            showEditTitle = false
        } else {
            showEditTitle = true
            editedTitle = partyState.title
            editedDate = partyState.dateRange
        }
    }
    private func allUsersSample() -> [Participant] {
        [
            Participant.alice,
            Participant.bob,
            Participant.cat,
            Participant.dima,
            Participant(id: .init(), name: "Евгения", avatarLetter: "Е", isAdmin: false),
            Participant(id: .init(), name: "Игорь", avatarLetter: "И", isAdmin: false)
        ]
    }
}
// MARK: - PartyRowView
struct PartyRowView: View {
    let party: Party
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text(party.title)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(party.dateRange)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("\(party.participants.count) участ.")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .padding(20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .frame(minHeight: 80)
    }
}
// MARK: - EditParticipantsView
struct EditParticipantsView: View {
    @Binding var party: Party
    let allUsers: [Participant]
    var onSave: ((Party) -> Void)? = nil
    @State private var searchQuery: String = ""
    @State private var localSelection: Set<UUID> = []
    @State private var showDeleteAlert: Bool = false
    @State private var participantToDelete: Participant? = nil
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Поиск участников", text: $searchQuery)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                List {
                    ForEach(filteredUsers, id: \.id) { user in
                        HStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 40, height: 40)
                                .overlay(Text(user.avatarLetter))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.name)
                                if let existing = party.participants.first(where: { $0.id == user.id }), existing.isAdmin {
                                    Text("(Админ)").font(.caption2).foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            if localSelection.contains(user.id) {
                                Button(action: {
                                    participantToDelete = user
                                    showDeleteAlert = true
                                }) {
                                    Image(systemName: "checkmark.circle.fill").font(.title2)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button(action: { localSelection.insert(user.id) }) {
                                    Image(systemName: "circle").font(.title2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                Spacer()
                Button("Сохранить изменения") {
                    saveChanges()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Изменить участников", displayMode: .inline)
            .navigationBarItems(leading: Button("Отмена") { presentationMode.wrappedValue.dismiss() })
            .onAppear { localSelection = Set(party.participants.map { $0.id }) }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Удалить участника?"),
                    message: Text("Вы уверены, что хотите удалить \(participantToDelete?.name ?? "пользователя")?"),
                    primaryButton: .destructive(Text("Удалить"), action: {
                        if let p = participantToDelete { localSelection.remove(p.id) }
                        participantToDelete = nil
                    }),
                    secondaryButton: .cancel({ participantToDelete = nil })
                )
            }
        }
    }
    private var filteredUsers: [Participant] {
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return allUsers
        } else {
            return allUsers.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    private func saveChanges() {
        var newParticipants: [Participant] = []
        for user in allUsers {
            if localSelection.contains(user.id) {
                if let existing = party.participants.first(where: { $0.id == user.id }) {
                    newParticipants.append(existing)
                } else {
                    newParticipants.append(Participant(id: user.id, name: user.name, avatarLetter: user.avatarLetter, isAdmin: false))
                }
            }
        }
        if !newParticipants.contains(where: { $0.isAdmin }) && !newParticipants.isEmpty {
            newParticipants[0].isAdmin = true
        }
        party.participants = newParticipants
        onSave?(party)
        presentationMode.wrappedValue.dismiss()
    }
}
// MARK: - Preview
struct MyPartiesView_Previews: PreviewProvider {
    static var previews: some View {
        MyPartiesView()
    }
}
