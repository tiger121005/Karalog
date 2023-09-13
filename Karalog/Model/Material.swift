//
//  Material.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/04/30.
//

import UIKit


//MARK: - Material

struct Material {
    static var shared = Material()
    
    let initialListData: [Lists] = [Lists(listName: "お気に入り",
                                          listImage: UIImage.checkmarkSealFill.withTintColor(UIColor(red: 0.93, green: 0.47, blue: 0.18, alpha: 1.0)).pngData()!, id: "favorite"),
                                    Lists(listName: "歌いたい", listImage: UIImage.lassoAndSparkles.withTintColor(UIColor(red: 0.93, green: 0.43, blue: 0.18, alpha: 1.0)).pngData()!, id: "wanna")]
                                    
    
    let listImages = ["music.mic",
                      "music.note.list",
                      "music.note",
                      "music.quarternote.3",
                      "music.note.tv.fill",
                      "music.note.tv",
                      "music.note.house",
                      "music.note.house.fill"]
    
    let mic: UIImage = UIImage.musicMicCircleFill
    
    let categoryList = ["恋愛", "盛り上がる", "幸せ", "喜び", "悲しい", "失恋", "希望", "切ない", "憧れ", "憂鬱", "懐かしい", "勇気", "不安", "寂しい", "成長", "挫折", "青春", "春", "夏", "秋", "冬", "夢", "怒り", "友情", "純粋", "幻想", "励まされる", "風刺", "情熱", "熱い", "冷たい", "新感覚", "アガる", "エモい", "感謝", "思い出", "面白い", "救われる", "穏やか", "哀愁", "暗い", "明るい", "片思い", "ノリノリ", "怖い", "開放感", "かっこいい", "可愛い"]
    
    
    
}


//MARK: - Sort

enum Sort: String {
    case 追加順（遅） = "追加順（降）"
    case 追加順（早） = "追加順（昇）"
    case 得点（高） = "得点（降）"
    case 得点（低） = "得点（昇）"
    case 曲名順（降） = "曲名順（降）"
    case 曲名順（昇） = "曲名順（昇）"
    case アーティスト順（降） = "アーティスト順(降）"
    case アーティスト順（昇） = "アーティスト順(昇）"
}


//MARK: - ModelMenuType

//機種設定
enum ModelMenuType: String {
    case 未選択 = "未選択"
    case DAM = "DAM"
    case JOYSOUND = "JOYSOUND"
}


//MARK: - SettingShow

enum SettingShow: String {
    case 全て = "全て"
    case フォロワー = "フォロワーのみ"
    
}


//MARK: - SettingFollow

enum SettingFollow: String {
    case 全て = "全て"
    case 認証 = "認証"
}


//MARK: - ImpactFeedbackStyle

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


//MARK: - NotificationFeedbackType

enum NotificationFeedbackType: Int {
    case success
    case failure
    case error

    var value: UINotificationFeedbackGenerator.FeedbackType {
        return .init(rawValue: rawValue)!
    }

}


//MARK: - Haptic

enum Haptic {
    case impact(_ style: ImpactFeedbackStyle, intensity: CGFloat? = nil)
    case notification(_ type: NotificationFeedbackType)
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


//MARK: - UIColor

extension UIColor {
    static var imageColor: UIColor {
        return UIColor(named: "imageColor")!
    }
    
    static var baseColor: UIColor {
        return UIColor(named: "baseColor")!
    }
    
    static var subImageColor: UIColor {
        return UIColor(named: "subImageColor")!
    }
}


//MARK: - UIImage

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    static var eye: UIImage {
        return UIImage(systemName: "eye")!
    }
    
    static var eyeSlash: UIImage {
        return UIImage(systemName: "eye.slash")!
    }
    
    static var trash: UIImage {
        return UIImage(systemName: "trash")!
    }
    
    static var folder: UIImage {
        return UIImage(systemName: "folder")!
    }
    
    static var ellipsisCircle: UIImage {
        return UIImage(systemName: "ellipsis.circle")!
    }
    
    static var circleInsetFilled: UIImage {
        return UIImage(systemName: "circle.inset.filled")!
    }
    
    static var pencil: UIImage {
        return UIImage(systemName: "pencil")!
    }
    
    static var star: UIImage {
        return UIImage(systemName: "star")!
    }
    
    static var starFill: UIImage {
        return UIImage(systemName: "star.fill")!
    }
    
    static var heart: UIImage {
        return UIImage(systemName: "heart")!
    }
    
    static var heartFill: UIImage {
        return UIImage(systemName: "heart.fill")!
    }
    
    static var checkmarkSealFill: UIImage {
        return UIImage(systemName: "checkmark.seal.fill")!
    }
    
    static var lassoAndSparkles: UIImage {
        return UIImage(systemName: "lasso.and.sparkles")!
    }
    
    static var musicMicCircleFill: UIImage {
        return UIImage(systemName: "music.mic.circle.fill")!
    }
    
    static var KaralogQRImage: UIImage {
        return UIImage(named: "KaralogQRImage")!
    }
    
    static var KaralogImage: UIImage {
        return UIImage(named: "KaralogImage")!
    }
}
