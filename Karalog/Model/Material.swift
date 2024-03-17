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
        guard let starImage = UIImage.starFill.withTintColor(UIColor.imageColor).resized(toWidth: 300) else { return [] }
        
        
        let newStar = renderer.image { context in
            // 背景色を描画
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
            
            // SFSymbolを描画
            starImage.draw(in: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
        }
        guard let starData = newStar.jpegData(compressionQuality: 1.0) else { return [] }
        
        guard let lassoImage = UIImage.lassoAndSparkles.withTintColor(UIColor.imageColor).resized(toWidth: 300) else { return [] }
        
        let newLasso = renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
            lassoImage.draw(in: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
        }
        guard let lassoData = newLasso.jpegData(compressionQuality: 1.0) else { return [] }
        
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
    
    
    let noMusicImageURL = "https://s.widget-club.com/samples/4Xo8MX7tM5NRDsSL9BxGgs0vtQt2/9yMsO8MumnSoOb4W58Rt/1F199258-FC7E-4241-B785-269FE34C0A38.jpg?q=70"
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
    
    static func fromUrl(url: String) async -> UIImage? {
        
        guard let imageUrl = URL(string: url) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            return UIImage(data: data)
        } catch {
            return nil
        }
        
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func rotatedBy(degree: CGFloat) -> UIImage? {
        let radian = degree * CGFloat.pi / 180
        var rotatedRect = CGRect(origin: .zero, size: self.size)
            
        rotatedRect = rotatedRect.applying(CGAffineTransform(rotationAngle: radian))
        
        UIGraphicsBeginImageContext(rotatedRect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: rotatedRect.size.width / 2, y: rotatedRect.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)
        
        guard let cgImage = self.cgImage else { return nil }

        context.rotate(by: radian)
        context.draw(cgImage, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))

        guard let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
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
    
    static var arrowshapeTurnUpRight: UIImage {
        return UIImage(systemName: "arrowshape.turn.up.right")!
    }
    
    static var camera: UIImage {
        return UIImage(systemName: "camera")!
    }
    
    static var checkmark: UIImage {
        return UIImage(systemName: "checkmark")!
    }
    
    static var checkmarkSealFill: UIImage {
        return UIImage(systemName: "checkmark.seal.fill")!
    }
    
    static var checkmarkSquareFill: UIImage {
        return UIImage(systemName: "checkmark.square.fill")!
    }
    
    static var circleInsetFilled: UIImage {
        return UIImage(systemName: "circle.inset.filled")!
    }
    
    static var ellipsisCircle: UIImage {
        return UIImage(systemName: "ellipsis.circle")!
    }
    
    static var eye: UIImage {
        return UIImage(systemName: "eye")!
    }
    
    static var eyeSlash: UIImage {
        return UIImage(systemName: "eye.slash")!
    }
    
    static var folder: UIImage {
        return UIImage(systemName: "folder")!
    }
    
    static var heart: UIImage {
        return UIImage(systemName: "heart")!
    }
    
    static var heartFill: UIImage {
        return UIImage(systemName: "heart.fill")!
    }
    
    static var house: UIImage {
        return UIImage(systemName: "house")!
    }
    
    static var KaralogImage: UIImage {
        return UIImage(named: "KaralogImage")!
    }
    
    static var KaralogQRImage: UIImage {
        return UIImage(named: "KaralogQRImage")!
    }
    
    static var lassoAndSparkles: UIImage {
        return UIImage(systemName: "lasso.and.sparkles")!
    }
    
    static var line3Horizontal: UIImage {
        return UIImage(systemName: "line.3.horizontal")!
    }
    
    static var magnifyingglass: UIImage {
        return UIImage(systemName: "magnifyingglass")!
    }
    
    static var multiply: UIImage {
        return UIImage(systemName: "multiply")!
    }
    
    static var musicMicCircleFill: UIImage {
        return UIImage(systemName: "music.mic.circle.fill")!
    }
    
    static var musicNote: UIImage {
        return UIImage(systemName: "music.note")!
    }
    
    static var pencil: UIImage {
        return UIImage(systemName: "pencil")!
    }
    
    static var photo: UIImage {
        return UIImage(systemName: "photo")!
    }
    
    static var star: UIImage {
        return UIImage(systemName: "star")!
    }
    
    static var starFill: UIImage {
        return UIImage(systemName: "star.fill")!
    }
    
    static var trash: UIImage {
        return UIImage(systemName: "trash")!
    }
    
    static var personCircle: UIImage {
        return UIImage(systemName: "person.circle")!
    }
    
    static var plus: UIImage {
        return UIImage(systemName: "plus")!
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
    class func NotoSansJPBold(size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSansJP-Bold", size: size)!
    }
    
    class func NotoSansJPBlack(size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSansJP-Black", size: size)!
    }
    
    class func FuturaBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Futura Bold", size: size)!
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


//MARK: - UIViewController

extension UIViewController {
    func segue(identifier: Segue) {
        let id = identifier.rawValue
        self.performSegue(withIdentifier: id, sender: nil)
    }
}
