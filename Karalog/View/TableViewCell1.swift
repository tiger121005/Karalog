//
//  TableViewCell1.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/26.
//

import UIKit

protocol TableViewCell1Delegate {
    func reloadCell(indexPath: IndexPath)
}

class TableViewCell1: UITableViewCell {
    
    @IBOutlet var colorImage: UIImageView!
    @IBOutlet var musicLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var musicImage: UIImageView!
    @IBOutlet var favoriteBtn: UIButton!
    
    
    var delegate: TableViewCell1Delegate?
    var indexPath: IndexPath!
    
    @IBAction func touchFavoriteBtn(_ sender: Any) {

        delegate?.reloadCell(indexPath: indexPath)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        colorImage.layer.shadowColor = UIColor.secondaryLabel.cgColor
        colorImage.layer.shadowOffset = CGSize(width: 0, height: colorImage.frame.height*0.3)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
