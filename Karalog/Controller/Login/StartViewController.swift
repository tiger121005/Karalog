//
//  StartViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/06/18.
//

import UIKit


//MARK: - StartViewController

class StartViewController: UIViewController {
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        UserDefaultsKey.userID.remove()
        judgeSegue()
        UserDefaultsKey.judgeSort.set(value: Sort.late.rawValue)
        
    }
    
    
    //MARK: - Setup
    
    func judgeSegue() {
        //userIDが保存されていた場合
        guard let u: String = UserDefaultsKey.userID.get() else {
            //保存されていない場合
            segue(identifier: .login)
            return
        }
        
        Task {
            print("userID: ", u)
            guard let a = await userFB.getUserInformation(id: u) else {
                segue(identifier: .login)
                return
            }
            
            utility.login(first: false, user: a) {_ in
                if UserDefaultsKey.showTutorial.get() == nil {
                    self.segue(identifier: .tutorial)
                } else {
                    self.segue(identifier: .tabBar)
                }
            }
            
        }
        
    }
    
    
}
