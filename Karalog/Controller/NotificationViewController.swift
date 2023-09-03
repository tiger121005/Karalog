//
//  NotificationViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit

class NotificationViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var notificationList: [Notice] = []
    var userID: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

extension NotificationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if notificationList[indexPath.row].title == "フォローリクエスト" {
            let alert = UIAlertController(title: "フォローリクエスト", message: "”\(notificationList[indexPath.row].from)”からフォローリクエストを承認しますか", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                
            }
            
            let approve = UIAlertAction(title: "承認", style: .default) { (action) in
                FirebaseAPI.shared.deleteRequest(notice: self.notificationList[indexPath.row])
                FirebaseAPI.shared.follow(followUser: self.notificationList[indexPath.row].from, followedUser: self.userID)
                Manager.shared.user.request.remove(at: indexPath.row)
                self.notificationList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            
            alert.addAction(cancel)
            alert.addAction(approve)
            present(alert, animated: true, completion: nil)
        }
    }
}

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
