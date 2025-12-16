import SwiftUI
struct BillDetailView: View {
    @State var bill: Bill
    var onSave: (() -> Void)? = nil
    @State private var products: [Product] = []
    @State private var didParticipate = false
    @State private var showAddProduct = false
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedDate = Date()
    @Environment(\.presentationMode) var presentationMode
    private var isCreator: Bool {
        return true // временная заглушка
    }
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок + кнопка добавления продукта
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if isEditing && isCreator {
                        TextField("Название чека", text: $editedTitle)
                            .font(.title2)
                            .bold()
                        DatePicker(
                            "",
                            selection: $editedDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                    } else {
                        Text(bill.title)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                        Text(bill.date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if isCreator {
                    Button(action: {
                        if isEditing {
                            // Сохраняем изменения
                            bill.title = editedTitle
                            bill.date = DateFormatter.ddMM.string(from: editedDate)
                            saveBillData()
                            isEditing = false
                        } else {
                            // Включаем режим редактирования
                            editedTitle = bill.title
                            // Правильно парсим дату из строки
                            if let date = parseDateFromString(bill.date) {
                                editedDate = date
                            } else {
                                // Если не удалось распарсить, используем текущую дату
                                editedDate = Date()
                            }
                            isEditing = true
                        }
                    }) {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(isEditing ? .green : .black)
                    }
                }
                Button(action: { showAddProduct = true }) {
                    Image(systemName: "plus.square.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            // Кнопка "Не участвовал/а"
            Button(action: { didParticipate.toggle() }) {
                HStack {
                    Circle()
                        .fill(didParticipate ? Color.black : Color.clear)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .overlay(
                            ZStack {
                                if didParticipate {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 12))
                                }
                            }
                            .clipShape(Circle())
                        )
                        .padding(.leading, 12)
                    Text("Не участвовал/а")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        .background(Color.white)
                )
                .padding(.horizontal, 20)
            }
            .padding(.top, 12)
            // Список продуктов
            ScrollView {
                VStack(spacing: 12) {
                    ForEach($products) { $product in
                        ProductRowView(product: $product, didParticipate: didParticipate)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 10)
            }
            // Итого
            HStack {
                Text("Итого:")
                    .font(.title)
                    .bold()
                Text("\(calculateTotal()) ₽")
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            // Кнопка "Сохранить"
            Button("Сохранить") {
                saveBillData()
                onSave?()
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.black)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showAddProduct) {
            AddProductSheetView(onAdd: { newProduct in
                products.append(newProduct)
                showAddProduct = false
            })
        }
        .onAppear {
            loadBillData()
        }
    }
    private func calculateTotal() -> Int {
        return products.reduce(0) { $0 + ($1.userQuantity * $1.pricePerUnit) }
    }
    private func parseDateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        formatter.locale = Locale(identifier: "ru_RU")
        // Парсим дату без года
        if let date = formatter.date(from: dateString) {
            // Устанавливаем текущий год для корректного отображения
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            var components = calendar.dateComponents([.day, .month], from: date)
            components.year = currentYear
            return calendar.date(from: components)
        }
        return nil
    }
    private func saveBillData() {
        do {
            // Сохраняем продукты
            let encoder = JSONEncoder()
            let productsData = try encoder.encode(products)
            UserDefaults.standard.set(productsData, forKey: "Bill_\(bill.id)_products")
            // Сохраняем участие
            UserDefaults.standard.set(didParticipate, forKey: "Bill_\(bill.id)_participation")
            // Сохраняем название и дату, если редактировали
            if isCreator {
                UserDefaults.standard.set(bill.title, forKey: "Bill_\(bill.id)_title")
                UserDefaults.standard.set(bill.date, forKey: "Bill_\(bill.id)_date")
            }
            // Помечаем чек как завершенный
            UserDefaults.standard.set(true, forKey: "Bill_\(bill.id)_isCompleted")
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
    private func loadBillData() {
        let decoder = JSONDecoder()
        // Загружаем продукты
        if let data = UserDefaults.standard.data(forKey: "Bill_\(bill.id)_products") {
            do {
                let loadedProducts = try decoder.decode([Product].self, from: data)
                products = loadedProducts
            } catch {
                print("Ошибка загрузки продуктов: \(error)")
            }
        }
        // Загружаем участие
        didParticipate = UserDefaults.standard.bool(forKey: "Bill_\(bill.id)_participation")
        // Загружаем сохраненные название и дату
        if let savedTitle = UserDefaults.standard.string(forKey: "Bill_\(bill.id)_title") {
            bill.title = savedTitle
        }
        if let savedDate = UserDefaults.standard.string(forKey: "Bill_\(bill.id)_date") {
            bill.date = savedDate
        }
    }
}
// Модель продукта
struct Product: Identifiable, Codable {
    var id = UUID()
    var name: String
    var pricePerUnit: Int
    var totalQuantity: Int
    var userQuantity: Int
}
// Строка продукта
struct ProductRowView: View {
    @Binding var product: Product
    let didParticipate: Bool
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.body)
                    .bold()
                Text("Всего: \(product.totalQuantity) шт.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(product.pricePerUnit) ₽/шт")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 8) {
                Button(action: {
                    if product.userQuantity > 0 {
                        product.userQuantity -= 1
                    }
                }) {
                    Image(systemName: "minus.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                Text("\(product.userQuantity)")
                    .font(.body)
                    .fontWeight(.medium)
                Button(action: {
                    if product.userQuantity < product.totalQuantity {
                        product.userQuantity += 1
                    }
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                .background(Color.white)
        )
        .disabled(!didParticipate)
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("\(product.userQuantity) × \(product.pricePerUnit) = \(product.userQuantity * product.pricePerUnit) ₽")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 8)
                        .padding(.bottom, 8)
                }
            }
        )
    }
}
extension DateFormatter {
    static let ddMM: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM"
        return df
    }()
}
