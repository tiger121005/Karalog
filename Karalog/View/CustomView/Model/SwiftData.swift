//
//  SwiftData.swift
//  KaralogSwiftUI
//
//  Created by TAIGA ITO on 2024/08/08.
//

import SwiftUI
import Foundation
import SwiftData

@Model
final class MusicSwiftData: Identifiable {
    var musicName: String
    var artistName: String
    var musicImage: String
    var favorite: Bool
    @Relationship(inverse: \ListSwiftData.music) var lists: [ListSwiftData] = []
    @Relationship(inverse: \MusicDataSwiftData.parent) var data: [MusicDataSwiftData] = []
    @Attribute(.unique) var id: String
    
    init(musicName: String, artistName: String, musicImage: String, favorite: Bool, lists: [ListSwiftData] = [], data: [MusicDataSwiftData], id: String) {
        self.musicName = musicName
        self.artistName = artistName
        self.musicImage = musicImage
        self.favorite = favorite
        self.lists = lists
        self.data = data
        self.id = id
    }
}

@Model
final class MusicDataSwiftData {
    var parent: MusicSwiftData
    
    var score: Double
    var key: Int
    var model: String
    var comment: String
    var time: String
    @Attribute(.unique) var id: String
    
    init(parent: MusicSwiftData, score: Double, key: Int, model: String, comment: String, time: String, id: String) {
        self.parent = parent
        self.score = score
        self.key = key
        self.model = model
        self.comment = comment
        self.time = time
        self.id = time
    }
}

@Model
final class ListSwiftData {
    var title: String
    var listImage: Data
    var music: [MusicSwiftData]
    @Attribute(.unique) var id: String
    
    init(title: String, listImage: Data, music: [MusicSwiftData] = [], id: String) {
        self.title = title
        self.listImage = listImage
        self.music = music
        self.id = id
    }
}

public extension ModelContext {
  enum StorageType {
    case inMemory
    case file
  }
  
  convenience init(
    for types: any PersistentModel.Type...,
    storageType: StorageType = .inMemory,
    shouldDeleteOldFile: Bool = true,
    fileName: String = #function
  ) throws {
    // 1. モデル定義のメタタイプで Schema を初期化
    let schema = Schema(types)
    
    let sqliteURL = URL.documentsDirectory
      .appending(component: fileName)
      .appendingPathExtension("sqlite")
    
    // ファイルストレージの DB を削除するかで
    // これは動作確認をする上で設けています。
    if shouldDeleteOldFile {
      let fileManager = FileManager.default
      
      if fileManager.fileExists(atPath: sqliteURL.path) {
        try fileManager.removeItem(at: sqliteURL)
      }
    }
    
    // 2. Schema で ModelConfiguration を初期化
    let modelConfiguration: ModelConfiguration = {
      switch storageType {
      case .inMemory:
        // ファイルストレージを使用せずにメモリのみで SwiftData を扱う
        ModelConfiguration(
          schema: schema,
          isStoredInMemoryOnly: true
        )
      case .file:
        // ファイルストレージに永続化するための url を指定
        ModelConfiguration(
          schema: schema,
          url: sqliteURL
        )
      }
    }()
    
    // 3. ModelConfiguration で ModelContainer を初期化
    let modelContainer = try ModelContainer(
      for: schema,
      configurations: [modelConfiguration]
    )
    
    // 4. ModelContainer で ModelContext を初期化
    self.init(modelContainer)
  }
}
