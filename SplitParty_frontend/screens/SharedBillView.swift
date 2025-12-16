import SwiftUI
struct SharedBillView: View {
    let party: Party
    @State private var bills: [Bill] = [
        Bill(id: UUID(), title: "Продукты для завтрака", creator: "@pollle4kaa", date: "15.09", isCompleted: false),
        Bill(id: UUID(), title: "Продукты для завтрака", creator: "@pollle4kaa", date: "15.09", isCompleted: true),
        Bill(id: UUID(), title: "Продукты для завтрака", creator: "@pollle4kaa", date: "15.09", isCompleted: true)
    ]
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Text("События")
                        .font(.headline)
                        .bold()
                    Spacer()
                    Button(action: {
                        let newBill = Bill(
                            id: UUID(),
                            title: "Новый чек",
                            creator: "@current_user",
                            date: Date().formatted(date: .abbreviated, time: .omitted),
                            isCompleted: false
                        )
                        bills.append(newBill)
                        saveBills()
                    }) {
                        Text("+ Добавить")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(bills) { bill in
                            NavigationLink(destination:
                                BillDetailView(bill: bill, onSave: {
                                    self.loadBills()
                                })
                            ) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(bill.isCompleted ? Color.green : Color.red)
                                        .frame(width: 12, height: 12)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(bill.title)
                                            .font(.body)
                                            .bold()
                                            .foregroundColor(.primary)
                                        Text("Создал: \(bill.creator) • \(bill.date)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                        .background(Color.white)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                Spacer()
            }
            .navigationTitle("Общий счет")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
    private func saveBills() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(bills)
            UserDefaults.standard.set(data, forKey: "Party_\(party.id)_bills")
        } catch {
            print("Ошибка сохранения чеков: \(error)")
        }
    }
    private func loadBills() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "Party_\(party.id)_bills") {
            do {
                let loadedBills = try decoder.decode([Bill].self, from: data)
                self.bills = loadedBills
            } catch {
                print("Ошибка загрузки чеков: \(error)")
            }
        }
        // Обновляем статусы чеков из UserDefaults
        var updatedBills = self.bills
        for i in 0..<updatedBills.count {
            let key = "Bill_\(updatedBills[i].id)_isCompleted"
            if let isCompleted = UserDefaults.standard.value(forKey: key) as? Bool {
                updatedBills[i].isCompleted = isCompleted
            }
        }
        self.bills = updatedBills
    }
    private func refreshBillStatus() {
        loadBills()
    }
}
// Модель чека
struct Bill: Identifiable, Codable {
    let id: UUID
    var title: String
    var creator: String
    var date: String
    var isCompleted: Bool
    init(id: UUID = UUID(), title: String, creator: String, date: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.creator = creator
        self.date = date
        self.isCompleted = isCompleted
    }
}
