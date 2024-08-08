//
//  LineGraph.swift
//  KaralogSwiftUI
//
//  Created by TAIGA ITO on 2024/07/28.
//

import Charts
import SwiftUI

//MARK: - LineMarkView

struct LineMarkView: View {
    var data: [GraphData]
    var max: Double
    var min: Double
    var maxWidth = UIScreen.main.bounds.width

    var body: some View {

        let imageColor = Color(uiColor: .imageColor)
        let gradient = LinearGradient(
            gradient: Gradient(
                colors: [
                    imageColor.opacity(0.6),
                    imageColor.opacity(0.4),
                    imageColor.opacity(0.08),
                ]
            ),
            startPoint: UnitPoint(x: 0.49, y: 0),
            endPoint: UnitPoint(x: 0.51, y: 1)
        )
        ZStack {
            Color.black
            HStack {
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal) {
                        ZStack {

                            //MARK: - Chart

                            Chart {
                                ForEach(downToZero()) { data in
                                    AreaMark(
                                        x: .value("Date", data.date),
                                        y: .value("Score", data.score)
                                    )
                                    .foregroundStyle(gradient)
                                }
                            }
                            .frame(width: width())
                            .chartYScale(domain: 0...shadowMaxRange())
                            .padding(.top)
                            .chartXAxis {
                                AxisMarks(preset: .extended) { value in
                                    AxisGridLine()

                                    AxisValueLabel()
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: gridLineValues().map { $0 - minRange() }) {
                                    value in
                                    AxisGridLine()
                                }
                            }

                            Chart {
                                ForEach(data) { data in

                                    LineMark(
                                        x: .value("Date", data.date),
                                        y: .value("Score", data.score)

                                    )
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    .foregroundStyle(imageColor)

                                    PointMark(
                                        x: .value("Date", data.date),
                                        y: .value("Score", data.score)
                                    )
                                    .foregroundStyle(imageColor)

                                }
                            }
                            .id(1)
                            .frame(width: width())
                            .chartYScale(domain: minRange()...maxRange())
                            .padding(.top)
                            .chartXAxis {
                                AxisMarks(preset: .extended) { value in
                                    AxisGridLine()
                                        .foregroundStyle(Color.gray)
                                    AxisValueLabel()
                                        .foregroundStyle(Color.gray)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: gridLineValues()) {
                                    AxisGridLine()
                                        .foregroundStyle(Color.gray)
                                }
                            }
                        }

                        .onAppear { scrollProxy.scrollTo(1) }
                    }
                }
                Spacer().frame(width: 0)
                VStack(spacing: 22) {

                    //MARK: - ScaleLabel

                    Text(String(gridLineValues().reversed()[0]))
                        .font(Font.system(size: 10))
                        .foregroundColor(Color.white)

                    ForEach(1..<6) { i in

                        Text(String(gridLineValues().reversed()[i]))
                            .font(Font.system(size: 10))
                            .foregroundColor(Color.white)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom)
            }
        }
    }

    //MARK: - Setup

    func maxRange() -> Double {
        var x: Double!

        let difference1 = ceil(max) - floor(min)

        if difference1 == 1 {
            x = ceil(max)
            if x > 100 {
                x = 100
            }
        } else {
            for i in 1...20 {
                let a = i * 5
                let difference = ceil(max / Double(a)) - floor(min / Double(a))
                if difference == 1 {
                    x = ceil(max / Double(a)) * Double(a)
                    if x > 100 {
                        x = 100
                    }
                    break
                }
            }
        }
        return x
    }

    func minRange() -> Double {
        var x: Double!
        let difference1 = ceil(max) - floor(min)

        if difference1 == 1 {
            x = floor(min)
        } else {
            for i in 1...20 {
                let a = i * 5
                let difference = ceil(max / Double(a)) - floor(min / Double(a))
                if difference == 1 {
                    x = floor(min / Double(a)) * Double(a)
                    break
                }
            }
        }
        return x
    }

    func width() -> CGFloat {
        let wid = CGFloat(data.count) * 45 + 19
        if maxWidth - 27 >= wid {
            return maxWidth - 27
        } else {
            return wid
        }
    }

    func downToZero() -> [GraphData] {

        let a = data.map{ GraphData(date: $0.date, score: $0.score - minRange()) }
        return a
    }

    func shadowMaxRange() -> Double {
        return gridLineValues()[5] - gridLineValues()[0]
    }

    func gridLineValues() -> [Double] {
        let difference = maxRange() - minRange()
        var values: [Double] = []

        for i in 0...5 {
            values.append(minRange() + difference * 0.2 * Double(i))
        }
        return values
    }

}

#Preview {
    MusicDetailView(navigationPath: .constant(NavigationPath.init()),
                    datas: [MusicData(time: "23年03月29日20:29",
                                      score: 89.839,
                                      key: 0,
                                      model: "DAM",
                                      comment: "valdbvakjsdnvlakjndv;ak"),
                            MusicData(time: "23年09月31日20:29",
                                      score: 81.829,
                                      key: 0,
                                      model: "DAM",
                                      comment: "valdbvakjsdnvlakjndv;ak")],
                    musicName: "hogehoge",
                    musicImage: "https://ogre.natalie.mu/media/news/music/2023/0417/mrsgreenapple_jkt202304.jpg?imwidth=750&imdensity=1")
}
