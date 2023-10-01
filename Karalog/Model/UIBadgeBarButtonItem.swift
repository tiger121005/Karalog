//
//  UIBadgeBarButtonItem.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/09/26.
//

import UIKit

class UIBadgeBarButtonItem: UIBarButtonItem {
    struct Constants {
        // 表示するバッジの大きさです。
        // 円形バッジを前提として固定値としていますが、2桁以上でも崩れないように
        // するためにはUILabel内にpaddingを設定する等し、Widthの固定値を外して下さい
        static let labelHeight: CGFloat = 18.0
        static let labelWidth: CGFloat = 18.0
        // バッジ位置です。BarButtonItemの中央からの差分をとっています
        static let defaultOffset: CGPoint = .init(x: 12.0, y: -12.0)
    }
        
    // MARK: - Property
        
    public var badgeNumber: Int = 0 {
        didSet { self.updateBadge() }
    }
        
    private lazy var label: UILabel = {
        let label = UILabel()
        // バッジの背景色です。必要に応じて変数化してください。
        label.backgroundColor = .red
        // 1桁の数字を前提としているため円形としています。
        // こちらも必要に応じて変更してください。
        label.layer.cornerRadius = Constants.labelHeight / 2.0
        label.clipsToBounds = true
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        // ラベルの文字色です。必要に応じて変数化してください。
        label.textColor = .white
        label.font = .systemFont(ofSize: 12.0)
        // 前面にでるようにするためにzPosition=1としています。
        label.layer.zPosition = 1
        return label
    }()
        
    // MARK: - Life Cycle
    public init(image: UIImage, target: Any?, action: Selector) {
        super.init()
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        // labelをaddする対象としてCustomViewを使用しています。
        // そのため、UIButtonをCustomViewとしてSetしています。
        self.customView = button
        setupBadgeLabel()
        updateBadge()
    }
        
    required init?(coder: NSCoder) {
        // Interface Builderでの使用は想定していません。
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateBadge() {
        // badgeNumberが更新される都度 Labelの数字を更新します。
        label.text = "\(badgeNumber)"
        label.isHidden = badgeNumber == 0
    }
        
    func setupBadgeLabel() {
        guard let customView = customView else { return }
        customView.addSubview(label)
        label.widthAnchor.constraint(equalToConstant: Constants.labelWidth).isActive = true
        label.heightAnchor.constraint(equalToConstant: Constants.labelHeight).isActive = true
        label.centerXAnchor.constraint(equalTo: customView.centerXAnchor, constant: Constants.defaultOffset.x).isActive = true
        label.centerYAnchor.constraint(equalTo: customView.centerYAnchor, constant: Constants.defaultOffset.y).isActive = true
        }
}
