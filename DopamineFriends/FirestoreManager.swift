//
//  FirestoreManager.swift
//  DopamineFriends
//
//  Created by joki on 26.02.25.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    private let db = Firestore.firestore()
    
    func sendAmount(address: String, amountToAdd: UInt64, completion: @escaping (Error?) -> Void) {
        let docRef = db.collection("userWallet").document(address)
        
        docRef.getDocument{ (document, error) in
            if let error = error {
                print("❌ Error fetching document: \(error.localizedDescription)")
                completion(error)
            }
            if let document = document, document.exists {
                if let currentAmountInt = document.data()?["amount"] as? Int64 {
                    let currentAmount = UInt64(currentAmountInt)
                    let newAmount = currentAmount + amountToAdd
                    docRef.updateData([
                        "amount": Int64(newAmount)
                    ]) { error in
                        if let error = error {
                            print("❌ Error updating amount: \(error.localizedDescription)")
                            completion(error)
                        } else {
                            print("✅ Successfully updated amount to \(newAmount).")
                            completion(nil)
                        }
                    }
                } else {
                    print("❌ 'amount' field does not exist in the document")
                    completion(nil)
                }
            } else {
                // Document does not exist, create it with amountToAdd
                let newAmount = Int64(amountToAdd)
                docRef.setData(["amount": newAmount]) { error in
                    if let error = error {
                        print("❌ Error creating document: \(error.localizedDescription)")
                        completion(error)
                    } else {
                        print("✅ Document created with amount \(newAmount).")
                        completion(nil)
                    }
                }
            }
        }
    }
}
