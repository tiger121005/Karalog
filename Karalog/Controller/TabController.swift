//
//  TabController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/10/02.
//

import UIKit

class TabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let home = storyboard?.instantiateViewController(withIdentifier: "home") as? UINavigationController else { return }
        
        guard let list = storyboard?.instantiateViewController(withIdentifier: "list") as? UINavigationController else { return }
        
        guard let share = storyboard?.instantiateViewController(withIdentifier: "share") as? UINavigationController else { return }
        
        guard let profile = storyboard?.instantiateViewController(withIdentifier: "profile") as? UINavigationController else { return }
        
        let views = [home, list, share, profile]
        
        let images = [UIImage.house,
                          UIImage.folder,
                          UIImage.arrowshapeTurnUpRight,
                          UIImage.personCircle]
        let titles = ["HOME", "LIST", "SHARE", "PROFILE"]
        
        for i in 0...3 {
            views[i].tabBarItem = UITabBarItem(title: titles[i], image: images[i].withTintColor(UIColor.gray).withConfiguration(UIImage.SymbolConfiguration(weight: .bold)), selectedImage: images[i].withTintColor(UIColor.imageColor).withConfiguration(UIImage.SymbolConfiguration(weight: .bold)))
        }
        
        viewControllers = views
        
    }
    

    

}
