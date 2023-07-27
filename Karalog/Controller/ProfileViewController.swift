//
//  ProfileViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var followBtn: UIButton!
    @IBOutlet var followNumBtn: UIButton!
    @IBOutlet var followerNumBtn: UIButton!
    
    var userName: String!
    var userID: String!
    var followList: [User] = []
    var followerList: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        FirebaseAPI.shared.getAnotherUser(id: userID) { user in
            self.followList = user.follow
            self.followerList = user.follower
            self.followNumBtn.setTitle(String(self.followList.count), for: .normal)
            self.followerNumBtn.setTitle(String(self.followerList.count), for: .normal)
        }
        userNameLabel.text = userName
        
    }

}
