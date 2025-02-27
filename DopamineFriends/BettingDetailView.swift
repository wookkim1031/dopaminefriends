//
//  BettingDetailView.swift
//  DopamineFriends
//
//  Created by Minseon Kim on 19.02.25.
//
import SwiftUI
import Firebase
import Charts

struct BettingDetailView: View {
    let itemId: String
    @State private var title: String = ""
    @State private var dateUntil: String = ""
    @State private var options: [String] = []
    @State private var votes: [Double] = []
    @State private var prices: [Double] = [] // Add this line to store prices
    @State private var historicalData: [(year: Int, value: Int)] = []
    
    @State private var showAlert: Bool = false
    @State private var selectedIndex: Int? = nil

    var totalVotes: Double {
        return votes.reduce(0, +)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .center) {
                    Text(title)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text(dateUntil)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                
                if totalVotes == 0 {
                    Text("You will be the first bettor!")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding()
                } else {
                    SemiDonutChartView(votes: $votes)
                        .frame(height: 150)
                        .padding()
                }
                
                VStack(spacing: 8) {
                    ForEach(0..<options.count, id: \.self) { index in
                        Button("Vote for \(options[index]) (\(Int(votes[safe: index] ?? 0)) votes) - \(Int(prices[safe: index] ?? 0))P") {
                            selectedIndex = index
                            showAlert = true
                        }
                        .buttonStyle(CustomButtonStyle(color: colors[index % colors.count]))
                    }
                }
                .padding(.horizontal)
                
                if !historicalData.isEmpty {
                                    LineGraphView(data: historicalData)
                                        .frame(height: 250)
                                        .padding()
                                }
            }
            .padding(.bottom, 20)
            .onAppear {
                fetchBettingData()
            }
        }
        .navigationTitle("Betting Detail")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirm Vote"),
                message: Text("Are you sure you want to vote for '\(options[safe: selectedIndex ?? 0] ?? "Unknown")'?"),
                primaryButton: .default(Text("Yes")) {
                    if let index = selectedIndex {
                        updateVote(for: index)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func fetchBettingData() {
        let db = Firestore.firestore()
        db.collection("bettingEvents").document(itemId).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    title = data["title"] as? String ?? "Unknown Title"
                    dateUntil = data["dateUntil"] as? String ?? "Unknown Date"
                    
                    if let optionsData = data["options"] as? [String: Int] {
                        options = Array(optionsData.keys)
                        votes = Array(optionsData.values.map { Double($0) })
                    }
                    
                    if let pricesData = data["prices"] as? [String: Double] {
                        prices = options.map { pricesData[$0] ?? 1 } // 옵션 순서에 맞춰 가격 매칭
                    }
                    
                    if let historicalDataDict = data["historicalData"] as? [String: Int] {
                                           historicalData = historicalDataDict.compactMap { key, value in
                                               if let year = Int(key) {
                                                   return (year: year, value: value)
                                               }
                                               return nil
                                           }.sorted { $0.year < $1.year } // 정렬
                                       }
                }
            }
        }
    }

    
    func updateVote(for index: Int) {
        let db = Firestore.firestore()
        let ref = db.collection("bettingEvents").document(itemId)
        
        ref.getDocument { document, error in
            if let document = document, document.exists {
                if var optionsData = document.data()?["options"] as? [String: Int],
                   var pricesData = document.data()?["prices"] as? [String: Double] {
                    
                    let key = options[index]
                    optionsData[key, default: 0] += 1
                    let newVoteCount = optionsData[key, default: 0]
                    
                    // 가격 업데이트 (votes + 1)
                    pricesData[key] = Double(newVoteCount + 1)
                    
                    // Firebase 업데이트
                    ref.updateData(["options": optionsData, "prices": pricesData]) { _ in
                        votes[index] = Double(newVoteCount)
                        prices[index] = Double(newVoteCount + 1) // 로컬 상태 업데이트
                    }
                }
            }
        }
    }
}

// Safe indexing extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Color palette
let colors: [Color] = [
    Color(hex: "#7E82AE"),
    Color(hex: "#FFCA65"),
    Color(hex: "#67AEA5")
]

// Custom Button Style
struct CustomButtonStyle: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
// Swift Charts 기반의 Line Graph
@available(iOS 16.0, *)
struct LineGraphView: View {
    let data: [(year: Int, value: Int)] // 데이터 타입 변경

    var body: some View {
        Chart {
            ForEach(data, id: \.year) { item in
                LineMark(
                    x: .value("Year", item.year),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3))

                PointMark(
                    x: .value("Year", item.year),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(.red)
                .annotation {
                    Text("\(item.value)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: data.map { $0.year }) { value in
                AxisValueLabel()
                    .font(.caption)
                    .offset(y: 10)
            }
        }
        .chartXScale(domain: data.map { $0.year }.min()!...data.map { $0.year }.max()!)
    }
}


// 색상 배열 (각 옵션별 색상 설정)
struct SemiDonutChartView: View {
    @Binding var votes: [Double]

    var totalVotes: Double {
        return votes.reduce(0, +)
    }

    var percentages: [Double] {
        return votes.map { $0 / totalVotes }
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let outerRadius: CGFloat = width / 2
            let innerRadius: CGFloat = outerRadius * 0.6

            ZStack {
                let angles = calculateAngles()

                ForEach(0..<percentages.count, id: \..self) { index in
                    Path { path in
                        let center = CGPoint(x: width / 2, y: geometry.size.height)
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: outerRadius,
                            startAngle: angles[index].start,
                            endAngle: angles[index].end,
                            clockwise: false
                        )
                        path.addLine(to: center)
                    }
                    .fill(colors[index % colors.count])
                    .animation(.easeInOut(duration: 0.5), value: votes)
                }

                Path { path in
                    let center = CGPoint(x: width / 2, y: geometry.size.height)
                    path.addArc(
                        center: center,
                        radius: innerRadius,
                        startAngle: .degrees(180),
                        endAngle: .degrees(0),
                        clockwise: false
                    )
                }
                .fill(Color.white)
            }
            .frame(width: width, height: 150)
        }
        .frame(height: 150)
    }

    func calculateAngles() -> [(start: Angle, end: Angle)] {
        var startAngle = Angle.degrees(180)
        var angleData: [(start: Angle, end: Angle)] = []

        for percentage in percentages {
            let endAngle = startAngle + .degrees(percentage * 180)
            angleData.append((start: startAngle, end: endAngle))
            startAngle = endAngle
        }
        return angleData
    }
}



// SectionView for Data Display
struct SectionView<Content: View>: View {
    var title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .bold()
            
            content()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}

// Previous Data
func previousDataView() -> some View {
    VStack(alignment: .leading, spacing: 6) {
        DataRow(label: "Bachelor Total", value: "2769")
        DataRow(label: "Bachelor Women", value: "454")
        DataRow(label: "Master Total", value: "1557")
        DataRow(label: "Master Women", value: "295")
        DataRow(label: "Lehramt Women", value: "15")
        DataRow(label: "Promotion Women", value: "29")
        DataRow(label: "Total Women (Sum)", value: "815")
        
        Divider()
        
        DataRow(label: "2022", value: "858")
        DataRow(label: "2021", value: "...")
        DataRow(label: "2020", value: "...")
    }
}

// Data in row
struct DataRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .bold()
        }
    }
}


struct BettingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BettingDetailView(itemId: "1")
    }
}

