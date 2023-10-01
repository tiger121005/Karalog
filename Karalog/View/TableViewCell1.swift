//
//  TableViewCell1.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/26.
//

import UIKit


//MARK: - TableViewCell1Delegate

protocol TableViewCell1Delegate {
    func reloadCell(indexPath: IndexPath)
}


//MARK: - TableViewCell1

class TableViewCell1: UITableViewCell {
    
    var delegate: TableViewCell1Delegate?
    var indexPath: IndexPath!
    
    //MARK: - UI objects
    
    @IBOutlet var background: UIView!
    @IBOutlet var cell: UIView!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var musicLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var musicImage: UIImageView!
    @IBOutlet var favoriteBtn: UIButton!
    
    
    //MARK: - TableViewCell methods

    override func awakeFromNib() {
        super.awakeFromNib()
        musicImage.layer.cornerRadius = musicImage.frame.height * 0.1
        musicImage.clipsToBounds = true
        
        
        
        
        cell.backgroundColor = .clear
        cell.layer.cornerRadius = cell.frame.height * 0.3
        cell.layer.cornerCurve = .continuous
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 2
        
        background.backgroundColor = .black
        let maskLayer = CAShapeLayer()
        maskLayer.frame = cell.frame
        maskLayer.cornerRadius = cell.frame.height * 0.3
        maskLayer.cornerCurve = .continuous
        background.layer.mask = maskLayer
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.cell.backgroundColor = selected ? .darkGray : .black

    }
    
    
    //MARK: - UI interaction
    
    @IBAction func touchFavoriteBtn(_ sender: Any) {

        delegate?.reloadCell(indexPath: indexPath)
        
    }
    
}
