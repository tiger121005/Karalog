//
//  DetailViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit


//MARK: - DetailViewController

class DetailViewController: UIViewController {

    var time: String = ""
    var musicName: String = ""
    var artistName: String = ""
    var musicImage: UIImage!
    var score: String = ""
    var key: String = ""
    var model: String = ""
    var comment: String = ""
    
    let commentTitleHeight: CGFloat = 24
    let topBottomSpace: CGFloat = 10
    let middleSpace: CGFloat = 10
    var commentLabelHeight: CGFloat!
    let radius: CGFloat = 15
    
    let scoreViewHeight: CGFloat = 70
    let otherViewHeight: CGFloat = 50
    let space: CGFloat = 15
    
    //MARK: - UI objects
    
    @IBOutlet var musicImageView: UIImageView!
    @IBOutlet var blackLayer: UIView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var musicLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var modelLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var views: [UIView]!
    @IBOutlet var commentViewHeight: NSLayoutConstraint!
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    //MARK: - Setup
    
    func setup() {
        
        musicImageView.image = musicImage
        
        blackLayer.backgroundColor = .black.withAlphaComponent(0.3)
        
        dateLabel.text = time
        
        musicLabel.text = musicName
        
        artistLabel.text = artistName
        
        scoreLabel.text = score
        scoreLabel.textColor = UIColor.white
        
        keyLabel.text = key
        
        modelLabel.text = model
        
        commentLabel.text = comment
        commentLabel.numberOfLines = 0
        commentLabel.sizeToFit()
        let commentLabelHeight = commentLabel.frame.height
        let otherHeight = (topBottomSpace * 2) + middleSpace + commentTitleHeight
        let commentHeight = otherHeight + commentLabelHeight
        commentViewHeight.constant = commentHeight
        
        
        for view in views {
            view.layer.cornerRadius = radius
            view.layer.cornerCurve = .continuous
            view.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            view.layer.shadowColor = UIColor.baseColor.cgColor
            view.layer.shadowOpacity = 0.8
            view.layer.shadowRadius = 3
        }
    }
}
