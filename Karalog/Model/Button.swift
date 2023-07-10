//
//  Button.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/06/18.
//

import UIKit

class Button: UIButton {

    func cornerDesign() {
        self.layer.cornerRadius = self.frame.height * 0.5
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 3
        self.layer.shadowColor = UIColor(named: "imageShadowColor")?.cgColor
        self.backgroundColor = UIColor(named: "imageColor")
    }
}
