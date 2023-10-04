//
//  FollowViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/08/25.
//

import UIKit


//MARK: - FollowDelegate

protocol FollowDelegate {
    func selectedFollowCell(indexPath: IndexPath)
}


//MARK: - FollowViewController

class FollowViewController: UIViewController {
    
    var delegate: FollowDelegate?
    var followList: [User] = []
    
    
    //MARK: - UI objects
        
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    //MARK: - View Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    
    //MARK: - Setup
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    
}


//MARK: - UITableViewDataSource

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


//MARK: - UITableviewDelegate

extension FollowViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedFollowCell(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
