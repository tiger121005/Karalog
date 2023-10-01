//
//  Material.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/04/30.
//

import UIKit


//MARK: - Material
let material = Material.shared

struct Material {
    static var shared = Material()
    
    
    func initialListData() -> [Lists] {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 300))
        var starImage = UIImage.starFill.withTintColor(UIColor.imageColor)
        starImage = starImage.resized(toWidth: 300)!
        
        let newStar = renderer.image { context in
            // 背景色を描画
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
            
            // SFSymbolを描画
            starImage.draw(in: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
        }
        let starData = newStar.jpegData(compressionQuality: 1.0)!
        
        var lassoImage = UIImage.lassoAndSparkles.withTintColor(UIColor.imageColor)
        lassoImage = lassoImage.resized(toWidth: 300)!
        let newLasso = renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
            lassoImage.draw(in: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
        }
        let lassoData = newLasso.jpegData(compressionQuality: 1.0)!
        
        return [Lists(listName: "お気に入り", listImage: starData, id: "favorite"),
                Lists(listName: "歌いたい", listImage: lassoData, id: "wanna")]
    }
    
   
                                    
    
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
    
    static var lightImageColor: UIColor {
        return UIColor(named: "lightImageColor")!
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
    
    func rotatedBy(degree: CGFloat) -> UIImage {
        let radian = degree * CGFloat.pi / 180
        var rotatedRect = CGRect(origin: .zero, size: self.size)
            
        rotatedRect = rotatedRect.applying(CGAffineTransform(rotationAngle: radian))
        
        UIGraphicsBeginImageContext(rotatedRect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: rotatedRect.size.width / 2, y: rotatedRect.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)

        context.rotate(by: radian)
        context.draw(self.cgImage!, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return rotatedImage
    }
    
    func toCIImage() -> CIImage? {
        if let ciImage = self.ciImage {
            return ciImage
        }
        if let cgImage = self.cgImage {
            return CIImage(cgImage: cgImage)
        }
        return nil
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
    
    static var multiply: UIImage {
        return UIImage(systemName: "multiply")!
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
    
    static var musicNote: UIImage {
        return UIImage(systemName: "music.note")!
    }
    
    static var line3Horizontal: UIImage {
        return UIImage(systemName: "line.3.horizontal")!
    }
    
    static var KaralogQRImage: UIImage {
        return UIImage(named: "KaralogQRImage")!
    }
    
    static var KaralogImage: UIImage {
        return UIImage(named: "KaralogImage")!
    }
}


//MARK: - UIButton

extension UIButton {
    // ボタンのアイコンをLeading(右側)に表示する
    func iconToRight() {
        if #available(iOS 11.0, *) {
            // leadingはiOS 11以降のため
            contentHorizontalAlignment = .leading
        } else {
            contentHorizontalAlignment = .right
        }
        semanticContentAttribute =
            UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
            ? .forceLeftToRight : .forceRightToLeft
    }
}


//MARK: - UIView

extension UIView {

    func clipMask(withRect rect: CGRect, isReversed: Bool = false) {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()

        if isReversed {
            // 切り抜きを反転させる場合は、自身のboundsをpathに追加する
            path.addRect(bounds)

            // 塗りつぶしルールの指定
            // 反転させる場合は、パスが重なっていない箇所を領域外と判定して残す
            maskLayer.fillRule = .evenOdd
        }

        path.addRect(rect)
        maskLayer.path = path

        // 作成したMask用のレイヤーをセットする
        layer.mask = maskLayer
    }
}


//MARK: - UIFont

extension UIFont {
    class func NotoSansJPBold(size: CGFloat) -> UIFont! {
        return UIFont(name: "NotoSansJP-Bold", size: size)!
    }
    
    class func NotoSansJPBlack(size: CGFloat) -> UIFont! {
        return UIFont(name: "NotoSansJP-Black", size: size)!
    }
}


//MARK: - RawRepresentable

extension RawRepresentable {
    init?(rawValue: Self.RawValue?) {
        guard let rawValue = rawValue else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
}
