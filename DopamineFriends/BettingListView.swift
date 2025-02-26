
//
//  BettingListView.swift
//  DopamineFriends
//
//  Created by Minseon Kim on 19.02.25.
//
import SwiftUI
import FirebaseFirestore

struct BettingItem: Identifiable {
    let id: String 
    let title: String
    let options: [String]
    let dateUntil: String
}

struct BettingListView: View {
    @State private var bettingList: [BettingItem] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(bettingList) { item in
                        NavigationLink(destination: BettingDetailView(itemId: item.id)) {
                            BettingRowView(item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .onAppear {
                fetchBettingData()
            }
        }
    }
    
    private func fetchBettingData() {
        let db = Firestore.firestore()
        db.collection("bettingEvents").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching betting events: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents {
                self.bettingList = documents.compactMap { doc in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let optionsDict = data["options"] as? [String: Int],
                          let dateUntil = data["dateUntil"] as? String else { return nil }
                    
                    let options = Array(optionsDict.keys) // 키 값만 리스트뷰에서 사용
                    
                    return BettingItem(id: doc.documentID, title: title, options: options, dateUntil: dateUntil)
                }
            }
        }
    }
}

struct BettingRowView: View {
    let item: BettingItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.title)
                .font(.headline)
                .multilineTextAlignment(.leading)
            
            VStack(spacing: 8) {
                ForEach(item.options, id: \..self) { option in
                    Text(option)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }
            }
            
            Text("Ends at: \(item.dateUntil)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct BettingListView_Previews: PreviewProvider {
    static var previews: some View {
        BettingListView()
    }
}
