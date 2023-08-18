//
//  CollectionViewCell.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/26.
//

import UIKit

class CollectionViewCell1: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var label: UILabel!
    @IBOutlet var background: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = self.frame.width * 0.2
        self.layer.cornerCurve = .continuous
        
    }

}
