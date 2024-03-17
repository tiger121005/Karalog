//
//  Article.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/26.
//

import Foundation
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseFirestore


//MARK: - ITunesData

struct ITunesData: Codable {
    
    var resultCount: Int
    var results: [MusicInfoModel]
}


//MARK: - MusicInfoModel

public struct MusicInfoModel: Codable {
    var artistName: String
    var trackName: String
    var artworkUrl100: String
    
    init(artistName: String, trackName: String, artworkUrl100: String){
        self.artistName = artistName
        self.trackName = trackName
        self.artworkUrl100 = artworkUrl100
    }
}


//MARK: - MusicList

public struct MusicList: Codable {
    let musicName: String
    let artistName: String
    let musicImage: String
    var favorite: Bool
    var lists: [String]
    var data: [MusicData]
    @DocumentID var id: String?
}


//MARK: - MusicData

public struct MusicData: Codable {
    let time: String
    let score: Double
    let key: Int
    let model: String
    let comment: String
}


//MARK: - Lists

public struct Lists: Codable {
    let listName: String
    let listImage: Data
    @DocumentID var id: String?
}


//MARK: - FBString
public struct ListName: Codable {
    let listName: String
    @DocumentID var id: String?
}



//MARK: - Post

public struct Post: Codable {
    let musicName: String
    let artistName: String
    let musicImage: String
    let content: String
    let time: Timestamp
    var userID: String
    var goodNumber: Int
    var category: [String]
    @DocumentID var id: String?
}


//MARK: - SampleData

public struct SampleData: Identifiable {
    public var id: String { date }
    let date: String
    let score: Double
}


//MARK: - User

public struct User: Codable {
    let name: String
    var goodList: [String]
    var listOrder: [String]
    var showAll: Bool
    var follow: [String]
    var follower: [String]
    var request: [String]
    var notice: [Notice]
    var getImage: Bool
    @DocumentID var id: String?
}


//MARK: - Notice
    
public struct Notice: Codable {
    let title: String
    let content: String
    var seen: Bool
    let from: String
}


//MARK: - DetectLog

public struct DetectLog: Codable {
    let music: String
    let artist: String
    let score: String
    var model: String
    let comment: String
}


//MARK: - UserDefaultsKey

enum UserDefaultsKey: String {
    case userID = "userID"
    case judgeSort = "judgeSort"
    case showTutorial = "showTutorial"
    
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


//MARK: - Segue

enum Segue: String {
    case login = "toLogin"
    case tutorial = "toTutorial"
    case tabBar = "toTabBar"
    case addToList = "toAddToList"
    case musicDetail = "toMusicDetail"
    case addMusic = "toAddMusic"
    case detail = "toDetail"
    case list = "toList"
    case addWanna = "toAddWanna"
    case addListMusic = "toAddListMusic"
    case addDetail = "toAddDetail"
    case addFriend = "toAddFriend"
    case friends = "toFriends"
    case notification = "toNotification"
    case selectedPost = "toSelectedPost"
    case qr = "toQR"
    case profile = "toProfile"
    case post = "toPost"
    
}


//MARK: - Sort

enum Sort: String {
    case late = "追加順（降）"
    case early = "追加順（昇）"
    case scoreHigh = "得点（降）"
    case scoreLow = "得点（昇）"
    case musicDown = "曲名順（降）"
    case musicUp = "曲名順（昇）"
    case artistDown = "アーティスト順(降）"
    case artistUp = "アーティスト順(昇）"
}


//MARK: - ModelMenuType

//機種設定
enum ModelMenuType: String {
    case no = "未選択"
    case DAM = "DAM"
    case JOYSOUND = "JOYSOUND"
}


//MARK: - SettingShow

enum SettingShow: String {
    case all = "全て"
    case follower = "フォロワーのみ"
    
}


//MARK: - SettingFollow

enum SettingFollow: String {
    case all = "全て"
    case certificaiton = "認証"
}


//MARK: - SettingGetImage

enum SettingGetImage: String {
    case allow = "許可する"
    case not = "許可しない"
}


//MARK: - Haptic

enum Haptic {
    case impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat? = nil)
    case notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
}


//MARK: - UserRef

enum UserRef: String {
    case goodList = "goodList"
    case listOrder = "listOrder"
    case name = "name"
    case showAll = "showAll"
    case follow = "follow"
    case follower = "follower"
    case request = "request"
    case notice = "notice"
    case getImage = "getImage"
    
    enum NoticeRef: String {
        case title = "title"
        case content = "content"
        case seen = "seen"
        case from = "from"
    }
    
    enum MusicListRef: String {
        case musicName = "musicName"
        case artistName = "artistName"
        case musicImage = "musicImage"
        case favorite = "favorite"
        case lists = "lists"
        case data = "data"
        
        enum MusicDataRef: String {
            case time = "time"
            case score = "score"
            case key = "key"
            case model = "model"
            case comment = "comment"
        }
    }
    
    enum ListsRef: String {
        case listImage = "listImage"
        case listName = "listName"
    }
    
    enum WannaListRef: String {
        case musicName = "musicName"
        case artistName = "artistName"
        case musicImage = "musicImage"
    }
}


//MARK: - ShareRef

enum ShareRef: String {
    case time = "time"
    case musicName = "musicName"
    case artistName = "artistName"
    case musicImage = "musicImage"
    case userID = "userID"
    case content = "content"
    case goodNumber = "goodNumber"
    case category = "category"
}


//Model

enum Model: String {
    case DAMAI = "DAM精密採点AI"
    case DAMDXG = "DAM精密採点DX-G"
    case JOYnew = "JOY新"
    case JOYold = "JOY旧"
}


//Objects

enum Objects: String {
    case music = "music"
    case artist = "artist"
    case score = "score"
    case comment = "comment"
}

