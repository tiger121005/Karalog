//
//  Function.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/05/05.
//

import Foundation
import UIKit

struct Function {
    static var shared = Function()
    private var impactFeedbackGenerator: UIImpactFeedbackGenerator?
    private var notificationFeedbackGenerator: UINotificationFeedbackGenerator?
    
    func login(first: Bool, user: User) {
        Manager.shared.user = user
        print(28273, Manager.shared.user)
        FirebaseAPI.shared.setFirebase(userID: user.id!)
        UserDefaultsKey.userID.set(value: user.id!)
        if first {
            Manager.shared.lists = Material.shared.initialListData
        } else {
            FirebaseAPI.shared.getList(completionHandler: {_ in})
        }
    }
    
    func sort(sortKind: String, updateList: [MusicList], completionHandler: @escaping ([MusicList]) -> Void) {
        
        var list = updateList
        switch sortKind {
        //日付（遅い）
        case "0":
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
            print(0)

        //日付け（早い）
        case "1":
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
        case "2":
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
        case "3":
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
        case "4": list.sort(by: {$0.musicName < $1.musicName})
            print(4)

        //五十音(遅い）
        case "5": list.sort(by: {$1.musicName < $0.musicName})
            print(5)

        //アーティスト（早い）
        case "6": list.sort(by: {($0.artistName, $0.musicName) < ($1.artistName, $1.musicName)})
            print(6)

        //アーティスト（遅い）
        case "7": list.sort(by: {($1.artistName, $0.musicName) < ($0.artistName, $1.musicName)})
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

enum ImpactFeedbackStyle: Int {
    case light
    case medium
    case heavy
    case soft
    case rigid

    var value: UIImpactFeedbackGenerator.FeedbackStyle {
        return .init(rawValue: rawValue)!
    }

}

enum NotificationFeedbackType: Int {
    case success
    case failure
    case error

    var value: UINotificationFeedbackGenerator.FeedbackType {
        return .init(rawValue: rawValue)!
    }

}

enum Haptic {
    case impact(_ style: ImpactFeedbackStyle, intensity: CGFloat? = nil)
    case notification(_ type: NotificationFeedbackType)
}
