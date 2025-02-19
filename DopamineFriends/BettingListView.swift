
//
//  BettingListView.swift
//  DopamineFriends
//
//  Created by Minseon Kim on 19.02.25.
//

import SwiftUI

struct BettingItem: Identifiable {
    let id: UUID = UUID()
    let itemId: String
    let title: String
    let options: [String]
    let dateUntil: String
}

struct BettingListView: View {
    let items: [BettingItem] = [
        BettingItem(itemId: "1", title: "How many tweets will Elon Musk post in February?", options: ["100-200", "200-300", "300-400"], dateUntil: "31.02.2025 12:00"),
        BettingItem(itemId: "2", title: "Will Johan pass the malo exam?", options: ["Yes", "No"], dateUntil: "31.02.2025 12:00")
    ]
    
    var body: some View {
        NavigationView {
            List(items) { item in
                NavigationLink(destination: BettingDetailView(itemId: item.itemId)) {
                    BettingRowView(item: item)
                }
            }
            .navigationTitle("Betting List")
        }
    }
}

struct BettingRowView: View {
    let item: BettingItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.headline)
                .multilineTextAlignment(.leading)
            
            HStack {
                ForEach(item.options, id: \..self) { option in
                    Text(option)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            Text("Ends at: \(item.dateUntil)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}


struct BettingListView_Previews: PreviewProvider {
    static var previews: some View {
        BettingListView()
    }
}
