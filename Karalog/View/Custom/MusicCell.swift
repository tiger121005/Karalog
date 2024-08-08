//
//  MusicCell.swift
//  KaralogSwiftUI
//
//  Created by TAIGA ITO on 2024/07/29.
//

import SwiftUI

struct MusicCell: View {
    @State var imageURL: URL?
    @State var image: UIImage = .noImage
    @State var music: String
    @State var artist: String
    var width: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .frame(width: (width / 3) - 10, height: (width / 3) - 10)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .task {
                    image = await UIImage.fromUrl(url: imageURL)
                }
            Text(music)
                .font(.title3)
                .fontWeight(.bold)
            Text(artist)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.bottom)
        }
        .frame(width: (width / 2) - 20)
        .foregroundColor(.white)
        .background(Color.black)
        .cornerRadius(20)
    }
}


//import UIKit
//
////MARK: - LogCell1Delegate
//
//protocol MusicCellDelegate {
//
//    func reloadCell(indexPath: IndexPath)
//
//}
//
////MARK: - LogCell
//
//class MusicCell: UICollectionViewCell {
//
//    var delegate: MusicCellDelegate?
//    var indexPath: IndexPath!
//
//    //MARK: - UI objects
//
//    @IBOutlet var scoreLabel: UILabel!
//    @IBOutlet var musicLabel: UILabel!
//    @IBOutlet var artistLabel: UILabel!
//    @IBOutlet var musicImage: UIImageView!
//    @IBOutlet var favoriteBtn: UIButton!
//    @IBOutlet var checkmark: UIImageView!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        self.layer.borderColor = UIColor.gray.cgColor
//        self.layer.borderWidth = 0
//        self.layer.cornerRadius = self.frame.height * 0.2
//        self.layer.cornerCurve = .continuous
//
//        musicImage.layer.cornerRadius = musicImage.frame.height * 0.1
//        musicImage.clipsToBounds = true
//
//        checkmark.layer.cornerRadius = checkmark.frame.height * 0.5
//        checkmark.isHidden = true
//    }
//
//    override var isSelected: Bool {
//        didSet {
//            if isSelected {
//                // 選択状態が切り替わった時に実行される
//                self.checkmark.isHidden = false
//                self.layer.borderWidth = 1.0
//            } else {
//                self.checkmark.isHidden = true
//                self.layer.borderWidth = 0
//
//            }
//        }
//    }
//
//    @IBAction func touchFavoriteBtn(_ sender: Any) {
//
//        delegate?.reloadCell(indexPath: indexPath)
//
//    }
//}
