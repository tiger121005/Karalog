//
//  TutoralViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/10/03.
//

import UIKit

class TutorialViewController: UIPageViewController {
    
    var controllers: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPageView()
    }
    func setupPageView(){
        // PageViewControllerで表示するViewControllerをインスタンス化
        let firstVC = storyboard!.instantiateViewController(withIdentifier: "firstTutorial") as! FirstTutorialViewController
        let secondVC = storyboard!.instantiateViewController(withIdentifier: "secondTutorial") as! SecondTutorialViewController
        let thirdVC = storyboard!.instantiateViewController(withIdentifier: "thirdTutorial") as! ThirdTutorialViewController
        let fourthVC = storyboard?.instantiateViewController(withIdentifier: "fourthTutorial") as! FourthTutorialViewController
        
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

extension TutorialViewController: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.controllers.count
    }
    //左にスワイプ
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = self.controllers.firstIndex(of: viewController), index > 0 {
            return self.controllers[index - 1]
        } else {
            return nil
        }
    }
    
    //右にスワイプ
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.controllers.firstIndex(of: viewController), index < self.controllers.count - 1 {
            return self.controllers[index + 1]
        } else {
            return nil
        }
    }
    
    
}


