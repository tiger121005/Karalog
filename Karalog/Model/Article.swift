//
//  Article.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/26.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct ITunesData: Codable {
    
    var resultCount: Int
    var results: [MusicInfoModel]
}

struct MusicInfoModel: Codable {
    var artistName: String
    var trackName: String
    var artworkUrl100: String
    
    init(artistName: String, trackName: String, artworkUrl100: String){
        self.artistName = artistName
        self.trackName = trackName
        self.artworkUrl100 = artworkUrl100
    }
}

public struct MusicList: Codable {
    let musicName: String
    let artistName: String
    let musicImage: Data
    var favorite: Bool
    var lists: [String]
    var data: [MusicData]
    @DocumentID var id: String?
}

public struct MusicData: Codable {
    let time: String
    let score: Double
    let key: Int
    let model: String
    let comment: String
}

public struct Lists: Codable {
    let listName: String
    let listImage: Data
    @DocumentID var id: String?
}

public struct Post: Codable {
    let musicName: String
    let artistName: String
    let musicImage: Data
    let content: String
    let time: Timestamp
    var userID: String
    var goodNumber: Int
    var category: [String]
    @DocumentID var id: String?
}

public struct SampleData: Identifiable {
    public var id: String { date }
    let date: String
    let score: Double
}

public struct User: Codable {
    let name: String
    var goodList: [String]
    var listOrder: [String]
    var showAll: Bool
    var follow: [String]
    var follower: [String]
    var request: [String]
    var notice: [Notice]
    @DocumentID var id: String?
}
    
public struct Notice: Codable {
    let title: String
    let content: String
    var seen: Bool
    let from: String
}

enum UserDefaultsKey: String {
    case userID = "userID"
    case judgeSort = "judgeSort"
    
    func get() -> String? {
        return UserDefaults.standard.string(forKey: self.rawValue)
    }

    func set(value: String) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }

    func remove() {
        UserDefaults.standard.removeObject(forKey: self.rawValue)
    }
}

enum SettingShow: String {
    case 全て = "全て"
    case フォロワー = "フォロワーのみ"
    
}

enum SettingFollow: String {
    case 全て = "全て"
    case 認証 = "認証"
}
