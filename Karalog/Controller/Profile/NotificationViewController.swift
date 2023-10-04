//
//  NotificationViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit


//MARK: - NotificationViewController

class NotificationViewController: UIViewController {
    
    var notificationList: [Notice] = []
    var userID: String!
    
    //MARK: - UI objects
    
    @IBOutlet var tableView: UITableView!
    
    
    //MARK: - View Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        title = "通知"
    }
    
    
    //MARK: - Setup
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}


//MARK: - UITableViewDelegate

extension NotificationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("manager", manager.user.request.count)
        if notificationList[indexPath.row].title == "フォローリクエスト" {
            let alert = UIAlertController(title: "フォローリクエスト", message: "”\(notificationList[indexPath.row].from)”からフォローリクエストを承認しますか", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                
            }
            
            let approve = UIAlertAction(title: "承認", style: .default) { (action) in
                userFB.deleteRequest(notice: self.notificationList[indexPath.row])
                userFB.follow(followUser: self.notificationList[indexPath.row].from, followedUser: self.userID)
                print("indexPath", indexPath.row)
                print(manager.user.notice.count)
                manager.user.notice.remove(at: indexPath.row)
                self.notificationList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            
            alert.addAction(cancel)
            alert.addAction(approve)
            present(alert, animated: true, completion: nil)
        }
    }
}


//MARK: - UITableViewDataSource

extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = notificationList[indexPath.row].title
        cell.detailTextLabel?.text = notificationList[indexPath.row].content
        return cell
    }
    
    
}
