//
//  Function.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/05/05.
//

import UIKit

var utility = Utility.shared


//MARK: - Function

struct Utility {
    static var shared = Utility()
    private var impactFeedbackGenerator: UIImpactFeedbackGenerator?
    private var notificationFeedbackGenerator: UINotificationFeedbackGenerator?
    
    func login(first: Bool, user: User, completionHandler: @escaping (Bool) -> Void) {
        manager.user = user
        guard let id = user.id else { return }
        userFB.setupFirebase(userID: id)
        UserDefaultsKey.userID.set(value: id)
        if first {
            manager.lists = material.initialListData()
            UserDefaultsKey.judgeSort.set(value: Sort.late.rawValue)
            completionHandler(true)
        } else {
            listFB.getList(completionHandler: {_ in
                completionHandler(true)
            })
        }
    }
    
    func sort(sortKind: String, updateList: [MusicList]) async -> [MusicList] {
        
        var list: [MusicList] = []
        switch sortKind {
        case Sort.late.rawValue:
            var a: [Date] = []
            for i in updateList {
                let b = i.data
                var c: [Date] = []
                for j in b {
                    if let string = dateFromString(string: j.time, format: "yy年MM月dd日HH:mm") {
                        c.append(string)
                    }
                }
                if let min = c.min() {
                    a.append(min)
                }

            }
            let d = a.indices.sorted{ a[$1] < a[$0] }
            list = d.map { updateList[$0] }

        case Sort.early.rawValue:
            list = updateList.reversed()


        case Sort.scoreHigh.rawValue:
            var a: [Double] = []
            for i in updateList {
                let b = i.data
                var c: [Double] = []
                for j in b {
                    c.append(j.score)
                }
                if let max = c.max() {
                    a.append(max)
                }
            }
            let d = a.indices.sorted{ a[$1] < a[$0]}
            list = d.map{updateList[$0]}

        case Sort.scoreLow.rawValue:
            list = updateList.reversed()


        case Sort.musicDown.rawValue:
            list = updateList.sorted(by: {$0.musicName < $1.musicName})

        case Sort.musicUp.rawValue:
            list = updateList.reversed()

        case Sort.artistDown.rawValue:
            list = updateList.sorted(by: {($0.artistName, $0.musicName) < ($1.artistName, $1.musicName)})

        case Sort.artistUp.rawValue:
            list = updateList.reversed()

        default: print("error sort")
        }
        return list
        
    }
    
    func dateFromString(string: String, format: String) -> Date? {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        if let date = formatter.date(from: string) {
            return date
        } else {
            return nil
        }
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
                impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style)
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
                notificationFeedbackGenerator?.notificationOccurred(type)
                notificationFeedbackGenerator = nil
        }
    }
}


