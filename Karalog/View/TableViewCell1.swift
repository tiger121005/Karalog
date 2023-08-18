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
    
    @IBOutlet var scoreLabel: UILabel!
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
        scoreLabel.transform = CGAffineTransformMakeRotation(CGFloat.pi / 5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
