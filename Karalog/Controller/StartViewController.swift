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
        let u: String! = UserDefaultsKey.userID.get()
        if u != nil {
            print(939384, u)
            Task {
                Manager.shared.user = await FirebaseAPI.shared.getUserInformation(id: u)
                Function.shared.login(first: false, user: await FirebaseAPI.shared.getUserInformation(id: u)!)
                
                self.performSegue(withIdentifier: "toTabBar", sender: nil)
            }
        } else {
            self.performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
}
