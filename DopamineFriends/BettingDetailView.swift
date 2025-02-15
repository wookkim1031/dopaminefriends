//
//  BettingDetailView.swift
//  DopamineFriends
//
//  Created by Minseon Kim on 14.02.25.
//

import Foundation
import SwiftUI
import Charts //   Swift Charts 사용

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
                    
                }
                .padding()
                
                // 반도넛 차트
                SemiDonutChartView(votes: $votes)
                    .frame(height: 150)
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
                
                // Prediction Section (Line Graph 추가)
                SectionView(title: "Prediction (Yearly Student Count)") {
                    LineGraphView()
                        .frame(height: 250)
                }
                .padding()
                
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Prediction Detail")
    }
}

// Swift Charts 기반의 Line Graph
@available(iOS 16.0, *)

struct LineGraphView: View {
    let data: [(year: Int, students: Int)] = [
        (2010, 144), (2011, 455), (2012, 566), (2013, 342), (2014, 342),
        (2015, 424), (2016, 564), (2017, 799), (2018, 858), (2019, 858),
        (2020, 815), (2021, 800), (2022, 750), (2023, 720)
    ]

    var body: some View {
        Chart {
            ForEach(data, id: \.year) { item in
                LineMark(
                    x: .value("Year", item.year),
                    y: .value("Students", item.students)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom) //   곡선 부드럽게
                .lineStyle(StrokeStyle(lineWidth: 3)) //   선 두께
                
                PointMark(
                    x: .value("Year", item.year),
                    y: .value("Students", item.students)
                )
                .foregroundStyle(.red) //   데이터 포인트 강조
                .annotation {
                    Text("\(item.students)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) //   Y축 왼쪽 정렬
        }
        .chartXAxis {
            AxisMarks(values: Array(stride(from: 2010, to: 2024, by: 1))) { value in
                AxisValueLabel()
                    .font(.caption) //   글자 크기 줄이기
                    .offset(y: 10) //   위치 조정
            }
        }
        .chartXScale(domain: 2010...2023) //   X축을 연속형 값으로 조정
    }
}


//   색상 배열 (각 옵션별 색상 설정)
let colors: [Color] = [Color.purple, Color.orange, Color.green]

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
            let outerRadius: CGFloat = width / 2  //   버튼과 동일한 너비
            let innerRadius: CGFloat = outerRadius * 0.6 //   내부 구멍 크기 조정

            ZStack {
                let angles = calculateAngles()

                ForEach(0..<percentages.count, id: \.self) { index in
                    Path { path in
                        let center = CGPoint(x: width / 2, y: geometry.size.height)
                        
                        //   바깥 반원 그리기
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: outerRadius,
                            startAngle: angles[index].start,
                            endAngle: angles[index].end,
                            clockwise: false
                        )
                        path.addLine(to: center) //   중심으로 라인 추가
                    }
                    .fill(colors[index])
                    .animation(.easeInOut(duration: 0.5), value: votes)
                }

                //   내부 원을 그려서 중앙을 투명하게 만들기
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
                .fill(Color.white) //   내부를 흰색으로 채워 도넛 모양 만들기
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
