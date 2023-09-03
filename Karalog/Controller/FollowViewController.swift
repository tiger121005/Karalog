//
//  FollowViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/08/25.
//

import UIKit

protocol FollowDelegate {
    func selectedFollowCell(indexPath: IndexPath)
}

class FollowViewController: UIViewController {
    
    var delegate: FollowDelegate?
    var followList: [User] = []
        
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    
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

extension FollowViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedFollowCell(indexPath: indexPath)
    }
}
