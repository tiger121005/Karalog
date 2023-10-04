//
//  CheckBox.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/07/14.
//

import UIKit


//MARK: - CheckBox

class CheckBox: UIButton {
    
    

    var uncheckedImage: UIImage!
    var checkedImage: UIImage!
    
    var checkedColor = UIColor.imageColor
    var uncheckedColor = UIColor.gray
    
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
                self.tintColor = checkedColor
                self.layer.shadowRadius = 3
            } else {
                self.setImage(uncheckedImage, for: .normal)
                self.tintColor = uncheckedColor
                self.layer.shadowRadius = 0
            }
        }
    }

    required init?(coder  aDecorder: NSCoder) {
        super.init(coder: aDecorder)!
        let width = self.frame.width
        
        let unchecked = UIImage.checkmark.withTintColor(UIColor.gray).withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
        let checked = UIImage.checkmarkSquareFill.withTintColor(UIColor.imageColor).resized(toWidth: width * 1.2)
        
        uncheckedImage = unchecked
        checkedImage = checked
        
        self.setImage(uncheckedImage, for: .normal)
        self.backgroundColor = UIColor.baseColor
        self.layer.borderWidth = 1.0
        self.layer.borderColor = checkedColor.cgColor
        self.layer.cornerRadius = self.frame.height * 0.2
        self.layer.cornerCurve = .continuous
        self.layer.shadowColor = checkedColor.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.tintColor = UIColor.gray
        addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    
    
    //MARK: - Objective - C

    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked.toggle()
        }
    }

}
