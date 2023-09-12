//
//  FollowerViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/08/25.
//

import UIKit


//MARK: - FollowerDelegate

protocol FollowerDelegate {
    func selectedFollowerCell(indexPath: IndexPath)
}


//MARK: - FollowerViewController

class FollowerViewController: UIViewController {
    
    var delegate: FollowerDelegate?
    
    var followerList: [User] = []
    
    
    //MARK: - UI objects
    
    @IBOutlet var tableView: UITableView!  {
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


//MARK: - UITableViewDelegate

extension FollowerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedFollowerCell(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
