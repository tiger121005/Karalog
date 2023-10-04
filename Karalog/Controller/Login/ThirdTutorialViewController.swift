//
//  ThirdTutorialViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/10/03.
//

import UIKit

class ThirdTutorialViewController: UIViewController {

    @IBOutlet var showBtn: CheckBox!
    var show: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func tapCheckBox() {
        if show {
            UserDefaultsKey.showTutorial.set(value: "false")
            show = false
        } else {
            UserDefaultsKey.showTutorial.remove()
            show = true
        }
    }

}
