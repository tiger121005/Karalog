//
//  DetailViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit

class DetailViewController: UIViewController {

    var time = ""
    var score = ""
    var key = ""
    var model = ""
    var comment = ""
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
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
