//
//  TutoralViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/10/03.
//

import UIKit

class TutoralViewController: UIPageViewController {
    
    var controllers: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPageView()
    }
    func setupPageView(){
        // PageViewControllerで表示するViewControllerをインスタンス化
        let firstVC = storyboard!.instantiateViewController(withIdentifier: "firstTutorial") as! FirstViewController
        let secondVC = storyboard!.instantiateViewController(withIdentifier: "secondTutorial") as! SecondViewController
        let thirdVC = storyboard!.instantiateViewController(withIdentifier: "thirdTutorial") as! ThirdViewController
        let fourthVC = storyboard?.instantiateViewController(withIdentifier: "fourthTutorial") as! FourthViewVontroller

        // インスタンス化したViewControllerを配列に追加
        self.controllers = [firstVC, secondVC, thirdVC, fourthVC]

        // 最初に表示するViewControllerを指定する
        setViewControllers([self.controllers[0]],
                            direction: .forward,
                            animated: true,
                            completion: nil)

        // PageViewControllerのDataSourceとの関連付け
        self.dataSource = self
    }

}

extension TutoralViewController: UIPageViewControllerDataSource {
    
}

extension TutorialViewController: UIPageViewControllerDelegate
