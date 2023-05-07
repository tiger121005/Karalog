//
//  Function.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/05/05.
//

import Foundation

struct Function {
    static var shared = Function()
    
    func sort(sortKind: Int, updateList: [MusicList], completionHandler: @escaping ([MusicList]) -> Void) {

        var list = updateList
        switch sortKind {
        //日付（遅い）
        case 0:
            var a: [Date] = []
            for i in updateList {
                let b = i.data
                var c: [Date] = []
                for j in b {
                    c.append(dateFromString(string: j.time, format: "yy年MM月dd日HH:mm"))
                }
                a.append(c.min()!)
                

            }
            let d = a.indices.sorted{ a[$1] < a[$0]}
            list = d.map {updateList[$0]}
            print(0)

            //日付け（早い）
        case 1:
            var a: [Date] = []
            for i in updateList {
                let b = i.data
                var c: [Date] = []
                for j in b {
                    c.append(dateFromString(string: j.time, format: "yy年MM月dd日HH:mm"))
                }
                a.append(c.min()!)

            }
            let d = a.indices.sorted{ a[$0] < a[$1]}
            list = d.map{updateList[$0]}
            print(1)

            //得点（高い）
        case 2:
            var a: [Double] = []
            for i in updateList {
                let b = i.data
                var c: [Double] = []
                for j in b {
                    c.append(j.score)
                }
                a.append(c.max()!)
            }
            let d = a.indices.sorted{ a[$1] < a[$0]}
            list = d.map{updateList[$0]}
            print(2)

            //得点（低い）
        case 3:
            var a: [Double] = []
            for i in updateList {
                let b = i.data
                var c: [Double] = []
                for j in b {
                    c.append(j.score)
                }
                a.append(c.max()!)
            }
            let d = a.indices.sorted{ a[$0] < a[$1]}
            list = d.map{updateList[$0]}
            print(3)

            //五十音(早い）
        case 4: list.sort(by: {$0.musicName < $1.musicName})
            print(4)

            //五十音(遅い）
        case 5: list.sort(by: {$1.musicName < $0.musicName})
            print(5)

            //アーティスト（早い）
        case 6: list.sort(by: {($0.artistName, $0.musicName) < ($1.artistName, $1.musicName)})
            print(6)

            //アーティスト（遅い）
        case 7: list.sort(by: {($1.artistName, $0.musicName) < ($0.artistName, $1.musicName)})
            print(7)

        default: print("error sort")
        }
        completionHandler(list)
        
    }
    
    func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
}
