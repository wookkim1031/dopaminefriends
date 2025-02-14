//
//  BettingDetailView.swift
//  DopamineFriends
//
//  Created by Minseon Kim on 14.02.25.
//

import Foundation
import SwiftUI

struct BettingDetailView: View {
    @State private var votes: [Double] = [100, 70, 30] // 투표 수 상태 저장

    var totalVotes: Double {
        return votes.reduce(0, +)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                // Header
                VStack(alignment: .center) {
                    Text("How many female informatikers will be there in RWTH 2024")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Feb 23, 2025 12:00")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Image("elon_musk") // Replace with actual image
                        .resizable()
                        .frame(width: 120, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
                
                // 반도넛 차트
                SemiDonutChartView(votes: $votes)
                    .frame(height: 300)
                    .padding()
                
                // Voting Buttons
                VStack(spacing: 8) {
                    ForEach(0..<votes.count, id: \.self) { index in
                        Button("Vote for option \(index + 1) (\(Int(votes[index])) votes)") {
                            votes[index] += 1 // 투표 증가
                        }
                        .buttonStyle(CustomButtonStyle(color: colors[index]))
                    }
                }
                .padding(.horizontal)
                
                // Previous Data Section
                SectionView(title: "Previous Data in 2023") {
                    previousDataView()
                }
                .padding()
                
                // Prediction Section
                SectionView(title: "Prediction") {
                    Text("Here Our Prediction will be displayed")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                .padding()
                
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Prediction Detail")
    }
}

import SwiftUI

struct SemiDonutChartView: View {
    @Binding var votes: [Double]

    var totalVotes: Double {
        return votes.reduce(0, +)
    }

    var percentages: [Double] {
        return votes.map { $0 / totalVotes }
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let radius: CGFloat = min(geometry.size.width, geometry.size.height) / 2
                let center: CGPoint = CGPoint(x: geometry.size.width / 2, y: geometry.size.height)

                let angles = calculateAngles()

                ForEach(0..<percentages.count, id: \.self) { index in
                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: angles[index].start,
                            endAngle: angles[index].end,
                            clockwise: false
                        )
                    }
                    .fill(colors[index])
                    .animation(.easeInOut(duration: 0.5), value: votes)
                }
            }
        }
        .frame(height: 150)
    }

    //GeometryReader
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

// Color for options
let colors: [Color] = [Color.purple, Color.orange, Color.green]

// Button Style
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
        BettingDetailView()
    }
}
