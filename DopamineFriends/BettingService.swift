//
//  BettingService.swift
//  DopamineFriends
//
//  Created by Minseon Kim on 27.02.25.
//

import Firebase
import FirebaseFirestore

class BettingService {
    static let shared = BettingService()
    private let db = Firestore.firestore()
    
    func placeBet(itemId: String, option: String, completion: @escaping (Bool) -> Void) {
        let ref = db.collection("bettingEvents").document(itemId)
        
        ref.getDocument { document, error in
            guard let document = document, document.exists, var data = document.data() else {
                completion(false)
                return
            }
            
            var options = data["options"] as? [String: Int] ?? [:]
            var prices = data["prices"] as? [String: Double] ?? [:]
            
            options[option, default: 0] += 1 // 투표 증가
            prices = self.updatePrices(options: options, currentPrices: prices) // 가격 조정
            
            ref.updateData(["options": options, "prices": prices]) { error in
                completion(error == nil)
            }
        }
    }
    
    private func updatePrices(options: [String: Int], currentPrices: [String: Double]) -> [String: Double] {
        let totalVotes = options.values.reduce(0, +)
        var newPrices = currentPrices
        
        for (option, count) in options {
            let popularity = Double(count) / Double(totalVotes)
            let newPrice = max(1.0, popularity * 10)
            newPrices[option] = newPrice
        }
        
        return newPrices
    }
}
