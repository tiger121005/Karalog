//
//  CollectionViewCell2.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/26.
//

import UIKit


//MARK: - CollectionViewCell2

class CollectionViewCell2: UICollectionViewCell {
    
    
    //MARK: - UI objects
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var musicLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    
    
    //MARK: - CollectionViewCell methods

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = self.frame.width * 0.2
        self.layer.cornerCurve = .continuous
        
        image.layer.cornerRadius = self.frame.width * 0.1
        image.layer.cornerCurve = .continuous
    }

}
