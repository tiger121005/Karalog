//
//  Function.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/05/05.
//

import UIKit

var function = Function.shared


//MARK: - Function

struct Function {
    static var shared = Function()
    private var impactFeedbackGenerator: UIImpactFeedbackGenerator?
    private var notificationFeedbackGenerator: UINotificationFeedbackGenerator?
    
    func login(first: Bool, user: User) {
        manager.user = user
        userFB.setupFirebase(userID: user.id!)
        UserDefaultsKey.userID.set(value: user.id!)
        if first {
            manager.lists = material.initialListData()
            UserDefaultsKey.judgeSort.set(value: Sort.追加順（遅）.rawValue)
        } else {
            listFB.getList(completionHandler: {_ in})
        }
    }
    
    func sort(sortKind: String, updateList: [MusicList], completionHandler: @escaping ([MusicList]) -> Void) {
        
        var list: [MusicList] = []
        switch sortKind {
        case Sort.追加順（遅）.rawValue:
            var a: [Date] = []
            for i in updateList {
                let b = i.data
                var c: [Date] = []
                for j in b {
                    c.append(dateFromString(string: j.time, format: "yy年MM月dd日HH:mm"))
                }
                a.append(c.min()!)
                

            }
            let d = a.indices.sorted{ a[$1] < a[$0] }
            list = d.map { updateList[$0] }

        case Sort.追加順（早）.rawValue:
            list = updateList.reversed()


        case Sort.得点（高）.rawValue:
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

        case Sort.得点（低）.rawValue:
            list = updateList.reversed()


        case Sort.曲名順（昇）.rawValue:
            list = updateList.sorted(by: {$0.musicName < $1.musicName})

        case Sort.曲名順（昇）.rawValue:
            list = updateList.reversed()

        case Sort.アーティスト順（降）.rawValue:
            list = updateList.sorted(by: {($0.artistName, $0.musicName) < ($1.artistName, $1.musicName)})

        case Sort.アーティスト順（昇）.rawValue:
            list = updateList.reversed()

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
    
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    mutating func playImpact(type: Haptic) {
        switch type {
            case .impact(let style, let intensity):
                impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style.value)
                impactFeedbackGenerator?.prepare()

                if let _intensity = intensity {
                    impactFeedbackGenerator?.impactOccurred(intensity: _intensity)
                } else {
                    impactFeedbackGenerator?.impactOccurred()
                }
                impactFeedbackGenerator = nil

            case .notification(let type):
                notificationFeedbackGenerator = UINotificationFeedbackGenerator()
                notificationFeedbackGenerator?.prepare()
                notificationFeedbackGenerator?.notificationOccurred(type.value)
                notificationFeedbackGenerator = nil
        }
    }
}


