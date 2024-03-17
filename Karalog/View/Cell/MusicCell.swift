//
//  MusicCell.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/09/29.
//

import UIKit

//MARK: - LogCell1Delegate

protocol MusicCellDelegate {
    
    func reloadCell(indexPath: IndexPath)
    
}


//MARK: - LogCell

class MusicCell: UICollectionViewCell {
    
    var delegate: MusicCellDelegate?
    var indexPath: IndexPath!
    
    
    //MARK: - UI objects
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var musicLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var musicImage: UIImageView!
    @IBOutlet var favoriteBtn: UIButton!
    @IBOutlet var checkmark: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 0
        self.layer.cornerRadius = self.frame.height * 0.2
        self.layer.cornerCurve = .continuous
        
        musicImage.layer.cornerRadius = musicImage.frame.height * 0.1
        musicImage.clipsToBounds = true
        
        checkmark.layer.cornerRadius = checkmark.frame.height * 0.5
        checkmark.isHidden = true
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                // 選択状態が切り替わった時に実行される
                self.checkmark.isHidden = false
                self.layer.borderWidth = 1.0
            } else {
                self.checkmark.isHidden = true
                self.layer.borderWidth = 0
                
            }
        }
    }

    
    @IBAction func touchFavoriteBtn(_ sender: Any) {

        delegate?.reloadCell(indexPath: indexPath)
        
    }
}
