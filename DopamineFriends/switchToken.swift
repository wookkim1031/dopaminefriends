import Foundation
import SwiftUI
import FirebaseFirestore
import PrivySDK

struct WalletAmount: Identifiable {
    let id = UUID() // Added a unique identifier for SwiftUI's List
    let tokenAmount: String
}

struct SwitchToken: View {
    @State private var sol: String = ""
    @State private var walletAmount: WalletAmount?
    @StateObject var privyManager: PrivyManager
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    if let walletAmount = walletAmount {
                        Text("DopamineFriends token balance: \(walletAmount.tokenAmount)")
                            .padding()
                    }
                }
                HStack {
                    TextField("Switch to native DopamineFriendToken:", text: $sol)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                        .padding()
                }
                HStack {
                    if let solAmount = UInt64(sol), let address = privyManager.selectedWallet?.address {
                        Button {
                            Task {
                                do {
                                    try await privyManager.sendTransaction(address: address, amount: solAmount)
                                    fetchTokenAmount()

                                } catch {
                                    print("Failed to send transaction: \(error)")
                                }
                            }
                        } label: {
                            Text("Send Transaction")
                        }
                    } else {
                        Text("Type in the SOL amount to transfer to Token")
                            .foregroundColor(.gray)
                    }
                }
            }
            .onAppear {
                fetchTokenAmount()
            }
        }
    }
    
    private func fetchTokenAmount() {
        guard let address = privyManager.selectedWallet?.address else {
            print("No wallet address found")
            return
        }
        
        print(address)
        
        let db = Firestore.firestore()
        db.collection("userWallet").document(address).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching wallet amount: \(error.localizedDescription)")
                return
            }
            if let data = snapshot?.data() {
                print("Firestore document data: \(data)")

                if let tokenAmount = data["amount"] {
                    DispatchQueue.main.async {
                        self.walletAmount = WalletAmount(tokenAmount: "\(tokenAmount)")
                    }
                } else {
                    print("'amount' field is missing")
                }
            } else {
                print(" Wallet document does not exist")
            }
        }
    }
}
