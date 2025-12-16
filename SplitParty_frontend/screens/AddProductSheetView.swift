import SwiftUI
struct AddProductSheetView: View {
    let onAdd: (Product) -> Void
    @State private var name = ""
    @State private var pricePerUnit = ""
    @State private var totalQuantity = ""
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Добавить продукт")
                    .font(.headline)
                    .bold()
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            Divider()
            VStack(alignment: .leading, spacing: 12) {
                Text("Название")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Например: Чипсы", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Цена за штуку (₽)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("50", text: $pricePerUnit)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                Text("Общее количество")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("3", text: $totalQuantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal, 20)
            Spacer()
            HStack(spacing: 12) {
                Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.black)
                .padding(.horizontal, 20)
                Button("Добавить") {
                    guard let price = Int(pricePerUnit), let quantity = Int(totalQuantity) else {
                        return
                    }
                    let newProduct = Product(name: name, pricePerUnit: price, totalQuantity: quantity, userQuantity: 0)
                    onAdd(newProduct)
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .padding(20)
    }
}
