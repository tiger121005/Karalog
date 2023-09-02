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
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        
        let u: String! = UserDefaultsKey.userID.get()
        if u != nil {
            Task {
                guard let a = await FirebaseAPI.shared.getUserInformation(id: u) else {
                    self.performSegue(withIdentifier: "toLogin", sender: nil)
                    return
                }
                Function.shared.login(first: false, user: a)
                
                self.performSegue(withIdentifier: "toTabBar", sender: nil)
            }
        } else {
            self.performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
}
