import SwiftUI
import PrivySDK
import FirebaseFirestore

struct CreateBettingView: View {
    @State private var title = ""
    @State private var detail = ""
    @State private var newOption: String = ""
    @State private var selectedDate = Date()
    @State private var options: [String] = []
    @StateObject var privyManager: PrivyManager
    let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Enter the title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .padding()
                TextField("Enter the Detail", text: $detail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .padding()
                DatePicker("Select a Date", selection: $selectedDate, displayedComponents: [.date])
                                .datePickerStyle(.automatic)
                                .padding()
                Text("Options: ")
                List {
                    ForEach(options, id: \.self) { option in
                        HStack {
                            Text(option)
                            Spacer()
                            Button(action: { removeOption(option) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                HStack {
                    TextField("Add Option", text: $newOption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: addOption) {
                        Image(systemName: "plus.circle.fill").foregroundColor(.green).font(.title)
                    }
                }
                .padding(.horizontal)
                
                Button("Upload") {
                    guard let walletAddress = privyManager.selectedWallet?.address, !title.isEmpty else { return }
                    upload(title: title, address: walletAddress, detail: detail)
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Create Bet")
        }
    }
    
    func addOption() {
        guard !newOption.isEmpty else { return }
        options.append(newOption)
        newOption = ""
    }
    
    func removeOption(_ option: String) {
        options.removeAll {$0 == option}
    }
    
    func upload(title: String, address: String, detail: String) {
        db.collection("betting").document(address).setData([
            "address": address,
            "title": title,
            "options": options,
            "detail": detail
        ]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
