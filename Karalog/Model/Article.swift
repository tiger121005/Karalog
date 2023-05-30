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
    var trackId: Int
    
    init(artistName: String, trackName: String, artworkUrl100: String, trackId: Int){
        self.artistName = artistName
        self.trackName = trackName
        self.artworkUrl100 = artworkUrl100
        self.trackId = trackId
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
    let musicID: Int
    let musicName: String
    let artistName: String
    let musicImage: Data
    let content: String
    let time: Timestamp
    let userName: String
    var goodNumber: Int
    var goodSelf: Bool
    var category: [String]
    @DocumentID var id: String?
}
