//
//  Material.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/04/30.
//

import Foundation
import UIKit

struct Material {
    static var shared = Material()
    
    let initialListData: [Lists] = [Lists(listName: "お気に入り",
                                          listImage: (UIImage(systemName: "checkmark.seal.fill")?.withTintColor(UIColor(red: 0.93, green: 0.47, blue: 0.18, alpha: 1.0)).pngData()!)!, id: "0"),
                                    Lists(listName: "歌いたい", listImage: (UIImage(systemName: "lasso.and.sparkles")?.withTintColor(UIColor(red: 0.93, green: 0.43, blue: 0.18, alpha: 1.0)).pngData()!)!, id: "1")]
                                    
    
    let listImages = ["music.mic", "music.note.list", "music.note", "music.quarternote.3", "music.note.tv.fill", "music.note.tv", "music.note.house", "music.note.house.fill"]
    
    let mic: UIImage = UIImage(systemName: "music.mic.circle.fill")!
}
