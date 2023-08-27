//
//  FollowerViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/08/25.
//

import UIKit

class FollowerViewController: UIViewController {
    
    var followerList: [User] = []
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    

}

extension FollowerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = followerList[indexPath.row].name
        cell.detailTextLabel?.text = followerList[indexPath.row].id
        return cell
    }
    
    
}

extension FollowerViewController: UITableViewDelegate {
    
}
