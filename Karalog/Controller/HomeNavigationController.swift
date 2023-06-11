//
//  HomeNavigationController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/06/05.
//

import UIKit

class HomeNavigationController: UINavigationController {
    
    @IBOutlet var navigationBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.delegate = self
    }

}

extension HomeNavigationController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
