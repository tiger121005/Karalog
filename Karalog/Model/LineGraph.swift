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
                .frame(width: (CGFloat(sampleData.count) * 45) + 19)
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
        var x = ceil(max/5)*5
        print("iiiiiiiiii", x)
        if x > 100 {
            x = 100
        } else if x == 0 {
            x = 5
        }
        return x
    }
    
    func minRange(min: Double) -> Double {
        var n = floor(min/5)*5
        print("uuuuuuuuu", n)
        if n < 0 {
            n = 0
        } else if n == 100 {
            n = 95
        }
        return n
    }
    
    func xTitles(data: [SampleData]) -> [String] {
        var values: [String] = []
        for i in data {
            let d = Function.shared.dateFromString(string: i.date, format: "yy年MM月dd日HH:mm")
            let s = Function.shared.stringFromDate(date: d, format: "MM/dd")
            values.append(s)
            print("values2222222222", values)
            print("6666666666666666", sampleData.map{$0.date})
        }
        return values
    }
    
    func xValues(data: [SampleData]) -> [String] {
        var values: [String] = []
        for i in data {
            values.append(i.date)
        }
        return values
    }
}

