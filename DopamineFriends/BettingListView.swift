
//
//  BettingListView.swift
//  DopamineFriends
//
//  Created by Minseon Kim on 19.02.25.
//
import SwiftUI
import FirebaseFirestore

struct BettingItem: Identifiable {
    let id: UUID = UUID()
    let itemId: String
    let title: String
    let options: [String]
    let dateUntil: String
}

struct BettingListView: View {
    @State private var bettingList: [BettingItem] = []
    let items: [BettingItem] = [
        BettingItem(itemId: "1", title: "How many tweets will Elon Musk post in February?", options: ["100-200", "200-300", "300-400"], dateUntil: "29.02.2025 12:00"),
        BettingItem(itemId: "2", title: "Will Johan pass the malo exam?", options: ["Yes", "No"], dateUntil: "29.02.2025 12:00")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(destination: BettingDetailView(itemId: item.itemId)) {
                            BettingRowView(item: item)
                        }
                        .buttonStyle(PlainButtonStyle()) // 기본 버튼 스타일 제거
                    }
                }
                .padding()
            }
        }
    }
}

struct BettingRowView: View {
    let item: BettingItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) { // ✅ 모든 요소 왼쪽 정렬 & 균일한 간격 유지
            Text(item.title)
                .font(.headline)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 8) { 
                ForEach(item.options, id: \.self) { option in
                    Text(option)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12) // ✅ 버튼 안의 패딩 균일하게
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }
            }
            
            Text("Ends at: \(item.dateUntil)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(16) // ✅ 박스 내부 패딩 통일
        .frame(maxWidth: .infinity, alignment: .leading) // ✅ 모든 박스가 같은 너비를 가지면서 왼쪽 정렬
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
