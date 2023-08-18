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
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewLeftConstraint: NSLayoutConstraint!

    
    var userName: String!
    var userID: String!
    var followList: [String] = []
    var followerList: [String] = []
    var selectPostKind: String = "past"
    var selectedSettingShow = SettingShow.全て
    var selectedSettingFollow = SettingFollow.全て
    var menuHidden: Bool = true
    var outBtn: UIButton!
    
    
    let hamburgerMenuList = ["名前変更", "いいね", "QRコード", "公開制限", "フォロー制限", "ログアウト"]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectedPost" {
            let nextView = segue.destination as! SelectedPostViewController
            nextView.kind = selectPostKind
        }
    }
    
    func setupView() {
        FirebaseAPI.shared.getUserInformation(id: userID) { user in
            self.userName = user.name
            self.followList = user.follow
            self.followerList = user.follower
            self.followNumBtn.setTitle(String(self.followList.count), for: .normal)
            self.followerNumBtn.setTitle(String(self.followerList.count), for: .normal)
            self.userNameLabel.text = self.userName
        }
        
        
        let tapOutBtn = UIAction() {_ in
            self.switchMenu()
        }
        
        outBtn = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), primaryAction: tapOutBtn)
        outBtn.backgroundColor = .black.withAlphaComponent(0.3)
        self.view.addSubview(outBtn)
        outBtn.isHidden = true
        
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
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
    
    @IBAction func showMenuBtn() {
        switchMenu()
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
                }

                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)

                alert.addAction(doneAction)
                alert.addAction(cancelAction)
                present(alert, animated: true)
        case 1:
            performSegue(withIdentifier: "toSelectedPost", sender: nil)
            selectPostKind = "good"
            
        case 2:
            performSegue(withIdentifier: "toQR", sender: nil)
            
        case 3:
            let alert = UIAlertController(title: "公開制限", message: "", preferredStyle: .actionSheet)
            
            let all = UIAlertAction(title: SettingShow.全て.rawValue, style: .default) {_ in
                self.selectedSettingShow = SettingShow.全て
            }
            
            let follower = UIAlertAction(title: SettingShow.フォロワー.rawValue, style: .default) {_ in
                self.selectedSettingShow = SettingShow.フォロワー
            }
            
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
            
            alert.addAction(all)
            alert.addAction(follower)
            alert.addAction(cancel)
            present(alert, animated: true)
            
        case 4:
            let alert = UIAlertController(title: "フォロー制限", message: "", preferredStyle: .actionSheet)
            
            let all = UIAlertAction(title: SettingFollow.全て.rawValue, style: .default) {_ in
                self.selectedSettingFollow = SettingFollow.全て
            }
            
            let follower = UIAlertAction(title: SettingFollow.認証.rawValue, style: .default) {_ in
                self.selectedSettingFollow = SettingFollow.認証
            }
            
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
            
            alert.addAction(all)
            alert.addAction(follower)
            alert.addAction(cancel)
            present(alert, animated: true)
            
        case 5:
            let alert = UIAlertController(title: "ログアウト", message: "”Karalog”からログアウトしますか？", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                
            }
            let delete = UIAlertAction(title: "ログアウト", style: .destructive) { (action) in
                do {
                    try Auth.auth().signOut()
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
        
        if indexPath.row == 5 {
            cell.textLabel?.textColor = UIColor.red
        } else  {
            cell.textLabel?.textColor = UIColor.systemBackground
        }
        
        return cell
    }
    
    
}
