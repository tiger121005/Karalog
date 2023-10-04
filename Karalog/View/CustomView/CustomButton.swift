//
//  CustomButton.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/06/18.
//

import UIKit


//MARK: - CostomButton

class CustomButton: UIButton {
//storyboardでviewを生成する時
    required init(coder aDecorder: NSCoder) {
        super.init(coder: aDecorder)!
        self.layer.borderColor = UIColor.imageColor.cgColor
        self.layer.borderWidth = 1
        
        self.layer.cornerRadius = self.frame.height * 0.5
        self.layer.cornerCurve = .continuous
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        self.tintColor = UIColor.black
        
        
        self.backgroundColor = UIColor.imageColor
        
        
        
    }
    
//コードでviewを生成するとき
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.layer.cornerRadius = self.frame.height * 0.5
//        self.layer.shadowOpacity = 0.7
//        self.layer.shadowRadius = 3
//        self.layer.shadowColor = UIColor(named: "imageShadowColor")?.cgColor
//        self.backgroundColor = UIColor.imageColor
//    }
    
}
