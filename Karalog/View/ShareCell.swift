//
//  ShareCell.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/05/25.
//

import UIKit


// MARK: ShareCellDelegate

protocol ShareCellDelegate {
    func reloadCell(indexPath: IndexPath)
    func tapMusic(indexpath: IndexPath)
    func tapArtist(indexPath: IndexPath)
}


// MARK: ShareCell

class ShareCell: UICollectionViewCell {
    
    var delegate: ShareCellDelegate?
    var indexPath: IndexPath!
    
    
    //MARK: - UI objects
    
    @IBOutlet var musicImage: UIButton!
    @IBOutlet var musicName: UIButton!
    @IBOutlet var artistName: UIButton!
    @IBOutlet var content: UILabel!
    @IBOutlet var goodBtn: UIButton!
    @IBOutlet var userName: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var goodNumLabel: UILabel!
    
    
    //CollectionView methods

    override func awakeFromNib() {
        super.awakeFromNib()
        content.numberOfLines = 0
        
        self.layer.cornerRadius = self.frame.width * 0.07
        self.layer.cornerCurve = .continuous
        
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor.baseColor.cgColor
        
        musicImage.layer.cornerRadius = musicImage.frame.height * 0.1
        musicImage.clipsToBounds = true
        
        self.musicName.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.NotoSansJPBlack(size: 20)
            return outgoing
        }
        
        self.artistName.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.NotoSansJPBold(size: 18)
            return outgoing
        }
        

        self.content.font = UIFont.systemFont(ofSize: 16)
        self.userName.font = UIFont.systemFont(ofSize: 14)
        self.goodNumLabel.font = UIFont.systemFont(ofSize: 14)
        self.categoryLabel.font = UIFont.systemFont(ofSize: 14)
        
        self.musicName.tintColor = UIColor.label
        self.artistName.tintColor = UIColor.label
        
        self.musicName.contentHorizontalAlignment = .left
        self.artistName.contentHorizontalAlignment = .left
        
    }
    
    
    //MARK: - UI interaction
    
    @IBAction func touchGoodBtn(_ sender: Any) {
        delegate?.reloadCell(indexPath: indexPath)
    }
    
    @IBAction func touchMusicBtn(_ sender: Any) {
        delegate?.tapMusic(indexpath: indexPath)
    }
    
    @IBAction func touchArtistBtn(_ sender: Any) {
        delegate?.tapArtist(indexPath: indexPath)
    }
    
}
