//
//  FollowViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/08/25.
//

import UIKit

class FollowViewController: UIViewController {
    
    var followList: [User] = []
        
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    
}

extension FollowViewController: UITableViewDelegate {
    
}

extension FollowViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = followList[indexPath.row].name
        cell.detailTextLabel?.text = followList[indexPath.row].id
        return cell
    }
    
    
}
