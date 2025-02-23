//
//  CreateBettingView.swift
//  DopamineFriends
//
//  Created by joki on 23.02.25.
//

import Foundation
import SwiftUI
import PrivySDK
import FirebaseFirestore

struct CreateBettingView: View {
    @State private var title = ""
    @StateObject var privyManager : PrivyManager
    let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            TextField("Enter the title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
            
            Button("Upload") {
                guard let walletAddress = privyManager.selectedWallet?.address, !title.isEmpty else { return }
                upload(title: title, address: walletAddress)
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        
    }
    
    func upload(title: String, address: String) {
        db.collection("betting").document(address).setData([
            "title" : title
        ]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
