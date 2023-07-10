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
        
        Chart(sampleData) { data in
            
            LineMark(
                x: .value("Date", data.date),
                y: .value("得点", data.score)
            )
            
            .lineStyle(StrokeStyle(lineWidth: 3))
            
        }
        .chartYScale(domain: minRange(min: min)...maxRange(max: max))
//        .chartXAxis{
//            AxisMarks(
//                values: xTitles(data: sampleData)
//            ){
//                AxisValueLabel<>
//            }
//            AxisMarks(
//                values: xValues(data: sampleData)
//            ){
//                AxisGridLine()
//            }
//        }
//        .chartYAxis{
//            AxisMarks(
//                values:
//            )
//        }
        .foregroundColor(Color("imageColor"))
        .padding()
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
            let s = Function.shared.stringFromDate(date: d, format: "yy/MM/dd")
            values.append(s)
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
