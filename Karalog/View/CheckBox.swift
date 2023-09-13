//
//  CheckBox.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/07/14.
//

import UIKit


//MARK: - CheckBox

class CheckBox: UIButton {

    let checkedImage = UIImage(systemName: "arrowshape.turn.up.right.fill")
    let uncheckedImage = UIImage(systemName: "arrowshape.turn.up.right")
    
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
                self.tintColor = UIColor.imageColor
                
            } else {
                self.setImage(uncheckedImage, for: .normal)
                self.tintColor = UIColor.separator
                
            }
        }
    }

    required init?(coder  aDecorder: NSCoder) {
        super.init(coder: aDecorder)!
        self.setImage(uncheckedImage, for: .normal)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.imageColor.cgColor
        self.layer.cornerRadius = self.frame.height * 0.2
        self.layer.cornerCurve = .continuous
        self.tintColor = UIColor.separator
        addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    
    
    //MARK: - Objective - C

    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked.toggle()
        }
    }

}
