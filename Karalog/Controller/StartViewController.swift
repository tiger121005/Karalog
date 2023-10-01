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
        
        setupDarkMode()
        judgeSegue()
        UserDefaultsKey.judgeSort.set(value: Sort.追加順（遅）.rawValue)
        
    }
    
    
    //MARK: - Setup
    
    func setupDarkMode() {
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
    }
    
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
            function.login(first: false, user: a)
            
            segue(identifier: .tabBar)
        }
        
    }
    
    func segue(identifier: Segue) {
        let id = identifier.rawValue
        self.performSegue(withIdentifier: id, sender: nil)
    }
    
}
