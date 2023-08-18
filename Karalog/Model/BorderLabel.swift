//
//  BorderLabel.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/08/09.
//

import UIKit

class BorderLabel: UILabel {

    var strokeColor:UIColor = UIColor.white
    var strokeSize:CGFloat = 2.0

    override func drawText(in rect: CGRect) {
        
        self.font = UIFont.boldSystemFont(ofSize: 18)
        
        if let context = UIGraphicsGetCurrentContext() {
            let textColor = UIColor(named: "baseColor")
            
            context.setLineWidth(self.strokeSize)
            context.setLineJoin(CGLineJoin.round)
            context.setTextDrawingMode(.stroke)
            self.textColor = self.strokeColor
            
            super.drawText(in: rect)
            
            context.setTextDrawingMode(.fill)
            self.textColor = textColor
        }
        super.drawText(in: rect)
    }

}
