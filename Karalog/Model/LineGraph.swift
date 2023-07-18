//
//  LineGraph.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/07/09.
//

import SwiftUI
import Charts


struct LineMarkView: View {
    var sampleData: [SampleData] = []
    var max: Double = 0.0
    var min: Double = 0.0
    var maxWidth = 0.0
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            
            ScrollView(.horizontal) {
                
                Chart() {
                    ForEach(sampleData) { data in
                        
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Score", data.score)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        PointMark(
                            x: .value("Date", data.date),
                            y: .value("Score", data.score)
                        )
                        
                    }
                    
                }
                .id(1)
                .frame(width: width())
                .chartYScale(domain: minRange(min: min)...maxRange(max: max))
                .foregroundColor(Color("imageColor"))
                .padding(.top)
                .chartXAxis {
                    AxisMarks(preset: .extended) { value in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                
                .onAppear{scrollProxy.scrollTo(1)}
            }
        }
    }
    
    func maxRange(max: Double) -> Double {
        var x = max + 3
        print("iiiiiiiiii", x)
        if x > 100 {
            x = 100
        } else if x == 0 {
            x = 5
        }
        return x
    }
    
    func minRange(min: Double) -> Double {
        var n = min - 3
        print("uuuuuuuuu", n)
        if n < 0 {
            n = 0
        } else if n == 100 {
            n = 95
        }
        return n
    }
    
    func width() -> CGFloat {
        let wid = CGFloat(sampleData.count) * 45 + 19
        if maxWidth >= wid {
            return maxWidth
        } else {
            return wid
        }
    }
}

