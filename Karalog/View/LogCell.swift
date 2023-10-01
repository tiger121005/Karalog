//
//  LogCell.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/10/01.
//

import UIKit


//MARK: - LogCell
class LogCell: UITableViewCell {
    
    
    //MARK: - UIObjects
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let cellSelectedBgView = UIView()
        cellSelectedBgView.backgroundColor = .gray
        self.selectedBackgroundView = cellSelectedBgView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
