//
//  StartViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/06/18.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.string(forKey: "userID") != nil {
            self.performSegue(withIdentifier: "toTabBar", sender: nil)
            if let _goodList = UserDefaults.standard.array(forKey: "goodList") as? [String] {
                Manager.shared.goodList = _goodList
            }else{
                FirebaseAPI.shared.getGoodList()
            }

        } else {
            self.performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
}
