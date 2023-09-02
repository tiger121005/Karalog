//
//  ProfileViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var followBtn: UIButton!
    @IBOutlet var followNumBtn: UIButton!
    @IBOutlet var followerNumBtn: UIButton!
    @IBOutlet var showPast: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet var bestView: UIView!
    @IBOutlet var musicLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var musicImage: UIImageView!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var menuBtn: UIBarButtonItem!
    
    var userName: String!
    var userID: String!
    var musicList: [MusicList] = []
    var followList: [String] = []
    var followerList: [String] = []
    var showAll: Bool!
    var notification: [Notice] = []
    var selectPostKind: String!
    var selectedSettingShow = SettingShow.全て.rawValue
    var selectedSettingFollow = SettingFollow.全て.rawValue
    var menuHidden: Bool = true
    var outBtn: UIButton!
    var followSelected: String!
    
    let refreshCtl = UIRefreshControl()
    let hamburgerMenuList = ["通知", "名前変更", "いいね", "公開制限", "ログアウト"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        setupBestView()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectedPost" {
            let nextView = segue.destination as! SelectedPostViewController
            nextView.kind = selectPostKind
            nextView.userID = userID
            nextView.userName = userName
        } else if segue.identifier == "toFriends" {
            let nextView = segue.destination as! FriendsViewController
            nextView.selected = followSelected
            nextView.follow = followList
            print(46483, followerList)
            nextView.follower = followerList
        } else if segue.identifier == "toNotification" {
            let nextView = segue.destination as! NotificationViewController
            nextView.notificationList = notification
            nextView.userID = userID
        }
    }
    
    func setupView() {
        Task {
            let user = await FirebaseAPI.shared.getUserInformation(id: self.userID)
            self.userName = user?.name
            self.followList = user?.follow ?? []
            self.followerList = user?.follower ?? []
            self.showAll = user?.showAll
            self.notification = user?.notice ?? []
            self.followNumBtn.setTitle(String(self.followList.count), for: .normal)
            self.followerNumBtn.setTitle(String(self.followerList.count), for: .normal)
            self.userNameLabel.text = self.userName
            if let s = user?.showAll {
                if s {
                    self.selectedSettingShow = SettingShow.全て.rawValue
                } else {
                    self.selectedSettingShow = SettingShow.フォロワー.rawValue
                }
            } else {
                self.selectedSettingShow = SettingShow.フォロワー.rawValue
            }
            if userID != Manager.shared.user.id {
                if !showAll && Manager.shared.user.follow.first(where: { $0 == userID}) == nil {
                    bestView.isHidden = true
                    followNumBtn.isEnabled = false
                    followerNumBtn.isEnabled = false
                    showPast.isHidden = true
                }
            }
            
        }
        
        //tableView表示時、関係ない部分を暗くする
        let tapOutBtn = UIAction() {_ in
            self.switchMenu()
        }
        outBtn = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), primaryAction: tapOutBtn)
        outBtn.backgroundColor = .black.withAlphaComponent(0.3)
        self.view.addSubview(outBtn)
        outBtn.isHidden = true
        
        //followBtnの名前の設定
        if userID == Manager.shared.user.id {
            followBtn.setTitle("友達を見つける", for: .normal)
        } else {
            if Manager.shared.user.follow.first(where: {$0 == userID}) != nil {
                followBtn.setTitle("フォローを外す", for: .normal)
            } else if Manager.shared.user.request.first(where: {$0 == userID}) != nil{
                followBtn.setTitle("リクエスト中", for: .normal)
            } else {
                followBtn.setTitle("フォローする", for: .normal)
            }
        }
        
        if Manager.shared.user.id != userID {
            menuBtn.isHidden = true
        }
        
        scrollView.refreshControl = refreshCtl
        refreshCtl.attributedTitle = NSAttributedString(string: "再読み込み中")
        refreshCtl.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        scrollView.addSubview(refreshCtl)
        
        
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupBestView() {
        //backgroundを設定
        let gradientTintColor: CGColor = UIColor(named: "imageColor")!.cgColor
        let gradientBaseColor: CGColor = UIColor.black.cgColor
        let gradient = CAGradientLayer()
        gradient.frame = bestView.bounds
        var colors: [CGColor] = []
        for _ in 0...2 {
            colors.append(gradientBaseColor)
        }
        colors.append(gradientTintColor)
        for _ in 0...5 {
            colors.append(gradientBaseColor)
        }
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.drawsAsynchronously = true
        bestView.layer.insertSublayer(gradient, at: 0)
        
        Task {
            
            
            if userID == UserDefaultsKey.userID.get() {
                self.musicList = Manager.shared.musicList
            } else {
                self.musicList = await FirebaseAPI.shared.getAnotherMusic(id: self.userID)
            }
            if self.musicList.isEmpty {
                musicLabel.text = "まだありません"
                artistLabel.text = ""
                scoreLabel.text = ""
                return
            }
            var list: [MusicList] = []
            var a: [Double] = []
            for m in musicList {
                let b = m.data.map{$0.score}
                a.append(b.max()!)
            }
            let c = a.indices.sorted{ a[$1] < a[$0]}
            a.sort(by: {$1 < $0})
            list = c.map{musicList[$0]}
            var best = list.first
            let bestScore = a.first
            if a.count > 1 {
                for i in 1...a.count - 1 {
                    if bestScore == a[i] {
                        if list[i].data.count > best!.data.count {
                            print(11111, list[i].musicName)
                            best = list[i]
                        } else if list[i].data.count == best?.data.count && list[i].data.last!.time > best!.data.last!.time{
                            print(22222, list[i].musicName)
                            best = list[i]
                        }
                    }
                }
            }
            print(a)
            musicLabel.text = best?.musicName
            artistLabel.text = best?.artistName
            let useImage = UIImage(data: best!.musicImage)?.withRenderingMode(.alwaysOriginal)
            musicImage.image = useImage
            let scoreList = best?.data.map{$0.score}
            let max = scoreList!.max()
            scoreLabel.text = String(format: "%.3f", max!)
        }
    }
    
    func switchMenu() {
        
        if menuHidden {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                
                self.tableView.center.x -= self.tableView.frame.width
                
            }) {(finished: Bool) in
                
            }
            self.outBtn.isHidden = false
            self.view.bringSubviewToFront(tableView)
            menuHidden = false
            self.tableViewLeftConstraint.constant -= self.tableView.frame.width
        } else {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                self.tableView.center.x += self.tableView.frame.width
            }) {(finished: Bool) in
                
            }
            outBtn.isHidden = true
            menuHidden = true
            self.tableViewLeftConstraint.constant += self.tableView.frame.width
        }
    }
    
    @IBAction func tapFollowBtn() {
        if userID == Manager.shared.user.id {
            performSegue(withIdentifier: "toAddFriend", sender: nil)
        } else {
            if let _i = Manager.shared.user.follow.firstIndex(where: {$0 == userID}) {
                FirebaseAPI.shared.deleteFollow(followedUser: userID, indexPathRow: _i)
                followBtn.setTitle("フォローする", for: .normal)
            } else {
                if showAll {
                    FirebaseAPI.shared.follow(followUser: Manager.shared.user.id!, followedUser: userID)
                    followBtn.setTitle("フォローを外す", for: .normal)
                } else {
                    FirebaseAPI.shared.sendRequest(receiveUser: userID)
                    followBtn.setTitle("リクエスト中", for: .normal)
                    
                }
            }
        }
    }
    
    @IBAction func showMenuBtn() {
        switchMenu()
    }
    
    @IBAction func tapToPastPost() {
        selectPostKind = "past"
        performSegue(withIdentifier: "toSelectedPost", sender: nil)
    }
    
    @IBAction func tapFollowNumBtn() {
        followSelected = "follow"
        performSegue(withIdentifier: "toFriends", sender: nil)
    }
    
    @IBAction func tapFollowerNumBtn() {
        followSelected = "follower"
        performSegue(withIdentifier: "toFriends", sender: nil)
    }
    
    @objc func reload() {
        Task {
            let user = await FirebaseAPI.shared.getUserInformation(id: self.userID)
            self.userName = user?.name
            self.followList = user?.follow ?? []
            self.followerList = user?.follower ?? []
            self.followNumBtn.setTitle(String(self.followList.count), for: .normal)
            self.followerNumBtn.setTitle(String(self.followerList.count), for: .normal)
            self.userNameLabel.text = self.userName
            if let s = user?.showAll {
                if s {
                    self.selectedSettingShow = SettingShow.全て.rawValue
                } else {
                    self.selectedSettingShow = SettingShow.フォロワー.rawValue
                }
            } else {
                self.selectedSettingShow = SettingShow.フォロワー.rawValue
            }
            
            //bestView
            if userID == UserDefaultsKey.userID.get() {
                self.musicList = Manager.shared.musicList
            } else {
                self.musicList = await FirebaseAPI.shared.getAnotherMusic(id: self.userID)
            }
            if self.musicList.isEmpty {
                musicLabel.text = "まだありません"
                artistLabel.text = ""
                scoreLabel.text = ""
                return
            }
            var list: [MusicList] = []
            var a: [Double] = []
            for m in musicList {
                let b = m.data.map{$0.score}
                a.append(b.max()!)
            }
            let c = a.indices.sorted{ a[$1] < a[$0]}
            a.sort(by: {$1 < $0})
            list = c.map{musicList[$0]}
            var best = list.first
            let bestScore = a.first
            if a.count > 0 {
                for i in 1...a.count - 1 {
                    if bestScore == a[i] {
                        if list[i].data.count > best!.data.count {
                            print(11111, list[i].musicName)
                            best = list[i]
                        } else if list[i].data.count == best?.data.count && list[i].data.last!.time > best!.data.last!.time{
                            print(22222, list[i].musicName)
                            best = list[i]
                        }
                    }
                }
            }
            print(a)
            musicLabel.text = best?.musicName
            artistLabel.text = best?.artistName
            let useImage = UIImage(data: best!.musicImage)?.withRenderingMode(.alwaysOriginal)
            musicImage.image = useImage
            let scoreList = best?.data.map{$0.score}
            let max = scoreList!.max()
            scoreLabel.text = String(format: "%.3f", max!)
            
            refreshCtl.endRefreshing()
        }
        
    }
    
    enum SettingShow: String {
        case 全て = "全て"
        case フォロワー = "フォロワーのみ"
        
    }
    
    enum SettingFollow: String {
        case 全て = "全て"
        case 認証 = "認証"
    }

}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            switchMenu()
            performSegue(withIdentifier: "toNotification", sender: nil)
            
        case 1:
            var textFieldOnAlert = UITextField()

            let alert = UIAlertController(title: "変更後の名前を入力",
                                                message: nil,
                                                preferredStyle: .alert)
            alert.addTextField { textField in
                textFieldOnAlert = textField
                textFieldOnAlert.returnKeyType = .done
            }

            let doneAction = UIAlertAction(title: "決定", style: .default) { _ in
                FirebaseAPI.shared.updateUserName(rename: textFieldOnAlert.text ?? "")
                self.userName = textFieldOnAlert.text
                self.userNameLabel.text = textFieldOnAlert.text
            }

            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
                alert.addAction(doneAction)
                alert.addAction(cancelAction)
                present(alert, animated: true)
            
        case 2:
            switchMenu()
            selectPostKind = "good"
            performSegue(withIdentifier: "toSelectedPost", sender: nil)
            
        case 3:
            let alert = UIAlertController(title: "公開制限", message: "", preferredStyle: .actionSheet)
            
            let all = UIAlertAction(title: SettingShow.全て.rawValue, style: .default) {_ in
                if self.selectedSettingShow != SettingShow.全て.rawValue {
                    self.selectedSettingShow = SettingShow.全て.rawValue
                    FirebaseAPI.shared.updateShowAll(id: self.userID, newBool: true)
                }
            }
            
            let follower = UIAlertAction(title: SettingShow.フォロワー.rawValue, style: .default) {_ in
                print(11111)
                if self.selectedSettingShow != SettingShow.フォロワー.rawValue {
                    print(22222)
                    self.selectedSettingShow = SettingShow.フォロワー.rawValue
                    FirebaseAPI.shared.updateShowAll(id: self.userID, newBool: false)
                }
                
            }
            
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
            
            alert.addAction(all)
            alert.addAction(follower)
            alert.addAction(cancel)
            present(alert, animated: true)
            
        case 4:
            let alert = UIAlertController(title: "ログアウト", message: "”Karalog”からログアウトしますか？", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                
            }
            let delete = UIAlertAction(title: "ログアウト", style: .destructive) { (action) in
                do {
                    try Auth.auth().signOut()
                    UserDefaultsKey.userID.remove()
                    Manager.shared.user = nil
                    Manager.shared.musicList = []
                    Manager.shared.lists = []
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                catch let error as NSError {
                    print(error)
                }
            }
            alert.addAction(cancel)
            alert.addAction(delete)
            present(alert, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hamburgerMenuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = hamburgerMenuList[indexPath.row]
        cell.backgroundColor = UIColor(named: "subImageColor")
        var selectedView = UIView()
        var color: UIColor = UIColor(named: "subImageColor")!
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
             color = UIColor(hue: hue, saturation: saturation, brightness: brightness * 0.9, alpha: alpha)
        }
        selectedView.backgroundColor = color
        cell.selectedBackgroundView = selectedView
        
        if indexPath.row == 4 {
            cell.textLabel?.textColor = UIColor.red
        } else  {
            cell.textLabel?.textColor = UIColor.black
        }
        
        return cell
    }
    
    
}
