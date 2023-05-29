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
                                    
    
    let listImages = ["music.mic",
                      "music.note.list",
                      "music.note",
                      "music.quarternote.3",
                      "music.note.tv.fill",
                      "music.note.tv",
                      "music.note.house",
                      "music.note.house.fill"]
    
    let mic: UIImage = UIImage(systemName: "music.mic.circle.fill")!
    
    let categoryList = ["恋愛", "盛り上がる", "幸せ", "喜び", "悲しい", "失恋", "希望", "切ない", "憧れ", "憂鬱", "懐かしい", "勇気", "不安", "寂しい", "成長", "挫折", "青春", "春", "夏", "秋", "冬", "夢", "怒り", "友情", "純粋", "幻想", "励まされる", "風刺", "情熱", "熱い", "冷たい", "新感覚", "アガる", "エモい", "感謝", "思い出", "面白い", "救われる", "穏やか", "哀愁", "暗い", "明るい", "片思い", "ノリノリ", "怖い", "開放感", "かっこいい", "可愛い"]
}
