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
    var score: String = ""
    var key: String = ""
    var model: String = ""
    var comment: String = ""
    
    
    //MARK: - UI objects
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    //MARK: - Setup
    
    func setup() {
        dateLabel.text = time
        scoreLabel.text = score
        keyLabel.text = key
        modelLabel.text = model
        commentLabel.text = comment
        commentLabel.numberOfLines = 0
        commentLabel.sizeToFit()
    }
}
