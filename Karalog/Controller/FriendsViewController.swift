//
//  FriendsViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit


//MARK: - FriendsViewController

class FriendsViewController: UIViewController {
    
    var followList: [User] = []
    var followerList: [User] = []
    var selected: String!
    var follow: [String] = []
    var follower: [String] = []
    var selectedUser: User!
    let idArray = ["follower", "follow"]
    
    
    //MARK: - UI objects
    
    @IBOutlet var segmentedCtl: UISegmentedControl!
    var pageViewController: UIPageViewController!
    var viewControllers = [UIViewController]()
    
    
    //MARK: - View Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            let nextView = segue.destination as! ProfileViewController
            nextView.userID = selectedUser.id
            nextView.userName = selectedUser?.name
            nextView.followList = selectedUser?.follow ?? []
            nextView.followerList = selectedUser?.follower ?? []
            nextView.showAll = selectedUser?.showAll
            nextView.notification = selectedUser?.notice ?? []
            
            if let s = selectedUser?.showAll {
                if s {
                    nextView.selectedSettingShow = SettingShow.全て.rawValue
                } else {
                    nextView.selectedSettingShow = SettingShow.フォロワー.rawValue
                }
            } else {
                nextView.selectedSettingShow = SettingShow.フォロワー.rawValue
            }
        }
    }
    
    
    //MARK: - Setup
    
    func setupPageView() {
        guard let followerViewController = storyboard?.instantiateViewController(withIdentifier: "follower") as? FollowerViewController else { return }
        followerViewController.followerList = followerList
        followerViewController.delegate = self
        
        guard let followViewController = storyboard?.instantiateViewController(withIdentifier: "follow") as? FollowViewController else { return }
        followViewController.followList = followList
        followViewController.delegate = self
        
        viewControllers.append(followerViewController)
        viewControllers.append(followViewController)
        
        pageViewController = children.first as? UIPageViewController
        if selected == "follower" {
            pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
        } else {
            pageViewController.setViewControllers([viewControllers[1]], direction: .forward, animated: false, completion: nil)
        }
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
    }
    
    func setupSegment() {
        if selected == "follower" {
            segmentedCtl.selectedSegmentIndex = 0
        } else {
            segmentedCtl.selectedSegmentIndex = 1
        }
        segmentedCtl.addTarget(self, action: #selector(segmentChanged(segmentCtl:)), for: UIControl.Event.valueChanged)
        
    }
    
    func setup() {
        Task {
            
            
            for user in follow {
                
                if let a = await userFB.getUserInformation(id: user) {
                    followList.append(a)
                }
            }
            
            for user in follower {
                if let a = await userFB.getUserInformation(id: user) {
                    followerList.append(a)
                }
            }
            
            print("")
            print("---followerList")
            print(followerList)
            setupPageView()
            setupSegment()
        }
    }
    
    
    //MARK: - Objective - C

    @objc func segmentChanged(segmentCtl: UISegmentedControl) {
       let index = segmentCtl.selectedSegmentIndex
       switch index {
       case 0:
           pageViewController.setViewControllers([viewControllers[index]], direction: .reverse, animated: true)
           
       case 1:
           pageViewController.setViewControllers([viewControllers[index]], direction: .forward, animated: true)
           
       default:
           break
       }
        
    }
    
}


//MARK: - UIPageViewControllerDelegate

extension FriendsViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
}


//MARK: - UIPageViewControllerDataSource

extension FriendsViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController), index > 0 {
            return viewControllers[index - 1]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController), index < viewControllers.count-1 {
            return viewControllers[index + 1]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            
        if let vcName = pageViewController.viewControllers?.first?.restorationIdentifier {
            let index = idArray.firstIndex(of: vcName)
            segmentedCtl.selectedSegmentIndex = index!
        }
    }
    
}


//MARK: - FollowerDelegate

extension FriendsViewController: FollowerDelegate {
    func selectedFollowerCell(indexPath: IndexPath) {
        selectedUser = followerList[indexPath.row]
        performSegue(withIdentifier: "toProfile", sender: nil)
    }
}


//MARK: - FollowDelegate

extension FriendsViewController: FollowDelegate {
    func selectedFollowCell(indexPath: IndexPath) {
        selectedUser = followList[indexPath.row]
        performSegue(withIdentifier: "toProfile", sender: nil)
    }
}
