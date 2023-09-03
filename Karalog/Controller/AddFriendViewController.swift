//
//  AddFriendViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit

class AddFriendViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var userList: [User] = []
    var userName: String!
    var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchBar()
        title = "友達を見つける"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            let nextView = segue.destination as! ProfileViewController
            nextView.userName = userName
            nextView.userID = userID
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
}

extension AddFriendViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userName = userList[indexPath.row].name
        userID = userList[indexPath.row].id
        performSegue(withIdentifier: "toProfile", sender: nil)
    }
}

extension AddFriendViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = userList[indexPath.row].name
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.text = userList[indexPath.row].id
        cell.detailTextLabel?.textColor = .white
        cell.backgroundColor = .black
        return cell
    }
}

extension AddFriendViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        userList = []
        print(searchText)
        if searchText == "" {
            userList = []
        }else{
            FirebaseAPI.shared.searchUserName(string: searchText) { list in
                self.userList = list
                Task {
                    if let user = await FirebaseAPI.shared.getUserInformation(id: searchText) {
                        self.userList.insert(user, at: 0)
                    }
                    self.tableView.reloadData()
                }
                
            }
        }
        
    }
}
