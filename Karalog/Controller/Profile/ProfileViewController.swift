//
//  ProfileViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import FirebaseAuth


//MARK: - ProfileViewController

class ProfileViewController: UIViewController {
    
    var userName: String!
    var userID: String!
    var musicList: [MusicList] = []
    var followList: [String] = []
    var followerList: [String] = []
    var showAll: Bool!
    var getImage: Bool!
    var notification: [Notice] = []
    var selectPostKind: String!
    var selectedSettingShow = SettingShow.all.rawValue
    var selectedSettingFollow = SettingFollow.all.rawValue
    var menuHidden: Bool = true
    var outBtn: UIButton!
    var followSelected: String!
    var fromFriends = false
    let hamburgerMenuList = ["通知", "名前変更", "いいね", "QRコード", "公開制限", "画像の送信", "ログアウト"]
    
    
    //MARK: - UI objects
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userIDLabel: UILabel!
    @IBOutlet var nameView: UIView!
    
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
    
    var activityIndicatorView = UIActivityIndicatorView()
    let refreshCtl = UIRefreshControl()
    var noticeBadge = UILabel()
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupFollowView()
        setupNameView()
        setupScrollView()
        showPast.iconToRight()
        setupBarItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        setupBestView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !menuHidden {
            switchMenu()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch Segue(rawValue: segue.identifier) {
        case .selectedPost:
            let nextView = segue.destination as! SelectedPostViewController
            nextView.kind = selectPostKind
            nextView.userID = userID
            nextView.userName = userName
            
        case .friends:
            let nextView = segue.destination as! FriendsViewController
            nextView.selected = followSelected
            nextView.follow = followList
            nextView.follower = followerList
            
        case .notification:
            let nextView = segue.destination as! NotificationViewController
            nextView.notificationList = notification
            nextView.userID = userID
            
        case .qr:
            let nextView = segue.destination as! QRViewController
            nextView.userID = userID
            
        default:
            break
            
        }
    }
    
    
    //MARK: - Setup
    func makeIndicator() {
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .imageColor

        view.addSubview(activityIndicatorView)
    }
    
    func setupNameView() {
        nameView.layer.cornerRadius = nameView.frame.height * 0.1
        nameView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        nameView.layer.shadowColor = UIColor.black.cgColor
        nameView.layer.shadowOpacity = 0.8
        nameView.layer.shadowRadius = 5
    }
    
    func setupFollowView() {
        
        self.followNumBtn.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 25)
            return outgoing
        }
        
        self.followerNumBtn.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 25)
            return outgoing
        }
        
    }
    
    func setupScrollView() {
        scrollView.refreshControl = refreshCtl
        refreshCtl.attributedTitle = NSAttributedString(string: "再読み込み中")
        refreshCtl.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        scrollView.addSubview(refreshCtl)
    }
    
    func setupBarItem() {
        title = "PROFILE"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        menuBtn.image = UIImage.line3Horizontal.withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
    }
    
    func setupView() {
        showPast.isHidden = true
        menuBtn.isHidden = true
        followNumBtn.isEnabled = false
        followerNumBtn.isEnabled = false
        followBtn.isHidden = true
        if userID == nil {
            userID = manager.user.id
        }
        Task {
            activityIndicatorView.startAnimating()
            if !fromFriends {
                guard let user = await userFB.getUserInformation(id: self.userID) else {
                    activityIndicatorView.stopAnimating()
                    let alert = UIAlertController(title: "エラー", message: "ユーザーが見つかりません", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) {_ in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                    
                    return
                    
                }
                self.userName = user.name
                self.followList = user.follow
                self.followerList = user.follower
                self.showAll = user.showAll
                self.getImage = user.getImage
                self.notification = user.notice
                
                
                if showAll {
                    self.selectedSettingShow = SettingShow.all.rawValue
                } else {
                    self.selectedSettingShow = SettingShow.follower.rawValue
                }
                
            }
            self.followNumBtn.setTitle(String(self.followList.count), for: .normal)
            self.followerNumBtn.setTitle(String(self.followerList.count), for: .normal)
            self.userNameLabel.text = self.userName
            self.userIDLabel.text = "ID: " + userID
            
            menuBtn.isHidden = false
            showPast.isHidden = false
            menuBtn.isHidden = false
            followNumBtn.isEnabled = true
            followerNumBtn.isEnabled = true
            followBtn.isHidden = false
            
            if userID != manager.user.id {
                menuBtn.isHidden = true
                if !showAll && !manager.user.follow.contains(where: { $0 == userID}) {
                    bestView.isHidden = true
                    followNumBtn.isEnabled = false
                    followerNumBtn.isEnabled = false
                    showPast.isHidden = true
                }
            }
            self.activityIndicatorView.stopAnimating()
        }
        
        //tableView表示時、関係ない部分を暗くする
        let tapOutBtn = UIAction() {_ in
            self.switchMenu()
        }
        outBtn = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), primaryAction: tapOutBtn)
        outBtn.backgroundColor = .black.withAlphaComponent(0.5)
        self.view.addSubview(outBtn)
        outBtn.isHidden = true
        
        //followBtnの名前の設定
        if userID == manager.user.id {
            followBtn.setTitle("友達を見つける", for: .normal)
        } else {
            if manager.user.follow.contains(where: {$0 == userID}) {
                followBtn.setTitle("フォローを外す", for: .normal)
            } else if manager.user.request.contains(where: {$0 == userID}) {
                followBtn.setTitle("リクエスト中", for: .normal)
            } else {
                followBtn.setTitle("フォローする", for: .normal)
            }
        }
        
        
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupBestView() {
        //backgroundを設定
        let gradientTintColor: CGColor = UIColor.imageColor.cgColor
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
        
        bestView.layer.cornerRadius = 20
        bestView.layer.cornerCurve = .continuous
        bestView.clipsToBounds = true
        
        musicImage.layer.cornerRadius = musicImage.frame.width * 0.1
        musicImage.clipsToBounds = true
        
        Task {
            
            
            if userID == UserDefaultsKey.userID.get() {
                self.musicList = manager.musicList
            } else {
                self.musicList = await musicFB.getAnotherMusic(id: self.userID)
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
                a.append(b.max() ?? 0)
            }
            let c = a.indices.sorted{ a[$1] < a[$0]}
            a.sort(by: {$1 < $0})
            list = c.map{musicList[$0]}
            guard var best = list.first else { return }
            let bestScore = a.first
            if a.count > 1 {
                for i in 1..<a.count {
                    if bestScore == a[i] {
                        if list[i].data.count > best.data.count {
                            best = list[i]
                        } else if list[i].data.count == best.data.count && list[i].data.last!.time > best.data.last!.time{
                            best = list[i]
                        }
                    }
                }
            }
            musicLabel.text = best.musicName
            artistLabel.text = best.artistName
            let useImage = await UIImage.fromUrl(url: best.musicImage)
            musicImage.image = useImage
            
            let scoreList = best.data.map{$0.score}
            let max = scoreList.max() ?? 0
            scoreLabel.text = String(format: "%.3f", max)
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
    
    
    //MARK: - UI interaction
    
    @IBAction func showMenuBtn() {
        switchMenu()
    }
    
    @IBAction func tapFollowBtn() {
        if userID == manager.user.id {
            segue(identifier: .addFriend)
        } else {
            guard let id = manager.user.id else { return }
            if let _i = manager.user.follow.firstIndex(where: {$0 == userID}) {
                //deleteFollow
                userFB.deleteFollow(followedUser: userID, indexPathRow: _i)
                if !showAll {
                    bestView.isHidden = true
                    followNumBtn.isEnabled = false
                    followerNumBtn.isEnabled = false
                    showPast.isHidden = true
                }
                if let i = followerList.firstIndex(where: {$0 == id}) {
                    followerList.remove(at: i)
                    followerNumBtn.setTitle(String(followerList.count), for: .normal)
                }
                followBtn.setTitle("フォローする", for: .normal)
            } else if manager.user.request.contains(where: {$0 == userID}) {
                //deleteRequest
                let notice = Notice(title: "フォローリクエスト",
                                    content: "\(manager.user.name)さん（ユーザーID: \(id)）からフォローリクエストが届きました",
                                    seen: false,
                                    from: id)
                userFB.cancelRequest(notice: notice, receiveUser: userID)
                followBtn.setTitle("フォローする", for: .normal)
            } else {
                if showAll {
                    //follow
                    userFB.follow(followUser: id, followedUser: userID)
                    followerList.append(id)
                    followerNumBtn.setTitle(String(followerList.count), for: .normal)
                    followBtn.setTitle("フォローを外す", for: .normal)
                } else {
                    //sendRequest
                    userFB.sendRequest(receiveUser: userID)
                    followBtn.setTitle("リクエスト中", for: .normal)
                    
                }
            }
        }
    }
    
    @IBAction func tapToPastPost() {
        selectPostKind = "past"
        segue(identifier: .selectedPost)
    }
    
    @IBAction func tapFollowNumBtn() {
        followSelected = "follow"
        segue(identifier: .friends)
    }
    
    @IBAction func tapFollowerNumBtn() {
        followSelected = "follower"
        segue(identifier: .friends)
    }
    
    
    //MARK: - Objective - C
    
    
    
    @objc func reload() {
        Task {
            let user = await userFB.getUserInformation(id: self.userID)
            if manager.user.id == userID {
                manager.user = user
            } else {
                guard let id = manager.user.id else { return }
                manager.user = await userFB.getUserInformation(id: id)
            }
            
            self.userName = user?.name
            self.followList = user?.follow ?? []
            self.followerList = user?.follower ?? []
            self.followNumBtn.setTitle(String(self.followList.count), for: .normal)
            self.followerNumBtn.setTitle(String(self.followerList.count), for: .normal)
            self.userNameLabel.text = self.userName
            self.notification = manager.user.notice
            if let s = user?.showAll {
                if s {
                    self.selectedSettingShow = SettingShow.all.rawValue
                } else {
                    self.selectedSettingShow = SettingShow.follower.rawValue
                }
            } else {
                self.selectedSettingShow = SettingShow.follower.rawValue
            }
            
            //followBtnの名前の設定
            if userID == manager.user.id {
                followBtn.setTitle("友達を見つける", for: .normal)
            } else {
                if manager.user.follow.contains(where: {$0 == userID}) {
                    followBtn.setTitle("フォローを外す", for: .normal)
                } else if manager.user.request.contains(where: {$0 == userID}) {
                    followBtn.setTitle("リクエスト中", for: .normal)
                } else {
                    
                    followBtn.setTitle("フォローする", for: .normal)
                }
            }
            
            //表示設定
            if userID != manager.user.id {
                if !showAll && !manager.user.follow.contains(where: { $0 == userID}) {
                    bestView.isHidden = true
                    followNumBtn.isEnabled = false
                    followerNumBtn.isEnabled = false
                    showPast.isHidden = true
                    menuBtn.isHidden = true
                } else {
                    bestView.isHidden = false
                    followerNumBtn.isEnabled = true
                    followNumBtn.isEnabled = true
                    showPast.isHidden = false
                    menuBtn.isHidden = false
                }
            }
            
            //bestView
            if userID == UserDefaultsKey.userID.get() {
                self.musicList = manager.musicList
            } else {
                self.musicList = await musicFB.getAnotherMusic(id: self.userID)
            }
            if self.musicList.isEmpty {
                musicLabel.text = "まだありません"
                artistLabel.text = ""
                scoreLabel.text = ""
                return
            }
            var list: [MusicList] = []
            var a: [Double] = []
            for m in self.musicList {
                let b = m.data.map{$0.score}
                if let max = b.max() {
                    a.append(max)
                } else {
                    a.append(0)
                }
            }
            let c = a.indices.sorted{ a[$1] < a[$0]}
            a.sort(by: {$1 < $0})
            list = c.map{musicList[$0]}
            if var best = list.first {
                let bestScore = a.first
                if a.count > 1 {
                    for i in 1..<a.count {
                        if bestScore == a[i] {
                            guard let last = list[i].data.last else { return }
                            if list[i].data.count > best.data.count {
                                best = list[i]
                            } else if list[i].data.count == best.data.count && last.time > last.time{
                                best = list[i]
                            }
                        }
                    }
                }
                musicLabel.text = best.musicName
                artistLabel.text = best.artistName
                let useImage = await UIImage.fromUrl(url: best.musicImage)
                musicImage.image = useImage
                let scoreList = best.data.map{$0.score}
                if let max = scoreList.max() {
                    scoreLabel.text = String(format: "%.3f", max)
                } else {
                    scoreLabel.text = String(format: "%.3f", 0)
                }
                
                refreshCtl.endRefreshing()
            }
        }
        
    }
    

}


//MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            switchMenu()
            segue(identifier: .notification)
            
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
                userFB.updateUserName(rename: textFieldOnAlert.text ?? "")
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
            segue(identifier: .selectedPost)
            
        case 3:
            switchMenu()
            segue(identifier: .qr)
            
        case 4:
            let alert = UIAlertController(title: "公開制限", message: "", preferredStyle: .actionSheet)
            
            let all = UIAlertAction(title: SettingShow.all.rawValue, style: .default) {_ in
                if self.selectedSettingShow != SettingShow.all.rawValue {
                    self.selectedSettingShow = SettingShow.all.rawValue
                    userFB.updateShowAll(id: self.userID, newBool: true)
                }
            }
            
            let follower = UIAlertAction(title: SettingShow.follower.rawValue, style: .default) {_ in
                if self.selectedSettingShow != SettingShow.follower.rawValue {
                    self.selectedSettingShow = SettingShow.follower.rawValue
                    userFB.updateShowAll(id: self.userID, newBool: false)
                }
                
            }
            
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
            
            alert.addAction(all)
            alert.addAction(follower)
            alert.addAction(cancel)
            present(alert, animated: true)
            
            
        case 5:
            let alert = UIAlertController(title: "画像の送信", message: "画像認識向上のため撮影した採点画面の画像を送信することを許可しますか", preferredStyle: .actionSheet)
            let allow = UIAlertAction(title: SettingGetImage.allow.rawValue, style: .default) {_ in
                if self.getImage != true {
                    userFB.updateGetImage(id: self.userID, newBool: true)
                    self.getImage = true
                }
            }
            let not = UIAlertAction(title: SettingGetImage.not.rawValue, style: .cancel) {_ in
                if self.getImage != false {
                    userFB.updateGetImage(id: self.userID, newBool: false)
                    self.getImage = false
                }
            }
            
            alert.addAction(allow)
            alert.addAction(not)
            present(alert, animated: true)
            
            
        case 6:
            let alert = UIAlertController(title: "ログアウト", message: "”Karalog”からログアウトしますか？", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                
            }
            let delete = UIAlertAction(title: "ログアウト", style: .destructive) { (action) in
                do {
                    try Auth.auth().signOut()
                    UserDefaultsKey.userID.remove()
                    manager.user = nil
                    manager.musicList = []
                    manager.lists = []
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


//MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hamburgerMenuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = hamburgerMenuList[indexPath.row]
        cell.backgroundColor = UIColor.baseColor

        
        if indexPath.row == 6 {
            cell.textLabel?.textColor = UIColor.red
        } else  {
            cell.textLabel?.textColor = UIColor.white
        }
        
        return cell
    }
    
    
}
