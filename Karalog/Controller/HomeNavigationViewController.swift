//
//  HomeNavigationViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/06/05.
//

import UIKit

class HomeNavigationViewController: UIViewController {
    
    @IBOutlet var navigationBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.delegate = self
    }

}

extension HomeNavigationViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
            return .topAttached
        }
}
