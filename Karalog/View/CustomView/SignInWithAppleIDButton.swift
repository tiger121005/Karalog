//
//  SignInWithAppleIDButton.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/12/27.
//

import UIKit
import AuthenticationServices

@IBDesignable class SignInWithAppleIDButton: UIButton {
    
    private var appleIDButton: ASAuthorizationAppleIDButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    super.draw(rect)

    appleIDButton = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .black)

    addSubview(appleIDButton)

    appleIDButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        appleIDButton.topAnchor.constraint(equalTo: self.topAnchor),
        appleIDButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        appleIDButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        appleIDButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    ])
    
}
