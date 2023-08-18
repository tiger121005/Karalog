//
//  EmphasizeLabel.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/08/09.
//

import UIKit

class EmphasizeLabel: UILabel {

    var shadowColorForCustom: UIColor = .clear
    var shadowOffsetForCustom: CGSize = .zero
    var shadowRadiusForCustom: CGFloat = 0.0

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let text = text, let attributed = attributedText else { return }
        let mutable = NSMutableAttributedString(attributedString: attributed)
        let shadow = createShadow()
        let range = NSRange(location: 0, length: text.count)
        mutable.addAttribute(.shadow, value: shadow, range: range)
        attributedText = mutable
    }

    private func createShadow() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = shadowColorForCustom
        shadow.shadowOffset = shadowOffsetForCustom
        shadow.shadowBlurRadius = shadowRadiusForCustom
        return shadow
    }

}
