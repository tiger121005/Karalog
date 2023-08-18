//
//  ShareViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/05/25.
//

import UIKit

class ShareViewController: UIViewController {
    
    var shareList: [Post] = []
    var goodList: [Bool] = []
    var sendWord: String = ""
    var category: [String] = []
    var alertCtl: UIAlertController!
    var searchViewHidden: Bool = true
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet var searchView: UIView!
    @IBOutlet var musicTF: UITextField!
    @IBOutlet var artistTF: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var searchBtn: CustomButton!
    @IBOutlet var topView: UIView!
    @IBOutlet var searchViewTopConstraint: NSLayoutConstraint!
    
    let refreshCtl = UIRefreshControl()
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout! {
        didSet{
            flowLayout.minimumLineSpacing = 1
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.scrollDirection = .vertical
            flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchView()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        FirebaseAPI.shared.searchPost(first: true, music: musicTF.text ?? "", artist: artistTF.text ?? "", category: category, completionHandler: {list in
            self.shareList = list
            self.collectionView.reloadData()
        })
        self.view.bringSubviewToFront(topView)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        let location: CGPoint = touch.location(in: self.view)
        if location.x < tableView.frame.minX || location.y < tableView.frame.minY {
            tapOutTableView()
        }else if location.x > tableView.frame.maxX || location.y > tableView.frame.maxY {
            tapOutTableView()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            let nextView = segue.destination as! ProfileViewController
            nextView.userID = UserDefaultsKey.userID.get()
            
        }
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ShareCell", bundle: nil), forCellWithReuseIdentifier: "shareCell")
        collectionView.keyboardDismissMode = .onDrag
        
        let compositionalLayout: UICollectionViewCompositionalLayout = {
            //.estimateを使うと、AutoLayoutが優先されるから、そこの値は適当でいい
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
            //1つのグループに対して、1つのセルを指定
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            //1つのセクションに対して、1つのグループを指定
            let section = NSCollectionLayoutSection(group: group)
            return UICollectionViewCompositionalLayout(section: section)
        }()
        
        collectionView.refreshControl = refreshCtl
        refreshCtl.attributedTitle = NSAttributedString(string: "再読み込み中")
        refreshCtl.addTarget(self, action: #selector(self.reload), for: UIControl.Event.valueChanged)
        
        collectionView.collectionViewLayout = compositionalLayout
    }
    
    func setupCategory() {
        categoryLabel.numberOfLines = 0
        if let _indexPathList = self.tableView.indexPathsForSelectedRows {
            var text: String = ""
            var newLine: Bool = false
            for i in _indexPathList {
                if newLine {
                    text += "\n#" + Material.shared.categoryList[i.row]
                    category.append(Material.shared.categoryList[i.row])
                }else {
                    text = "#" + Material.shared.categoryList[i.row]
                    newLine = true
                    category = [Material.shared.categoryList[i.row]]
                    
                }
            }
            categoryLabel.text = text
        } else {
            categoryLabel.text = ""
            category = []
        }
        self.view.sendSubviewToBack(collectionView)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.isHidden = true
        tableView.allowsMultipleSelection = true
    }
    
    func setupSearchView() {
        searchView.layer.cornerRadius = 15
        searchView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    func resize(image: UIImage, width: Double) -> UIImage {
        // オリジナル画像のサイズからアスペクト比を計算
        let aspectScale = image.size.height / image.size.width
        
        // widthからアスペクト比を元にリサイズ後のサイズを取得
        let resizedSize = CGSize(width: width, height: width * Double(aspectScale))
        
        // リサイズ後のUIImageを生成して返却
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
    
    func tapOutTableView () {
        if tableView.isHidden == false {
            tableView.isHidden = true
        }
    }
    
    func switchSearchView() {
        if searchViewHidden {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                
                self.searchView.center.y = self.searchView.frame.height/2 + (self.navigationController?.navigationBar.frame.maxY)!
                
                
            }, completion: {(finished: Bool) in
                
            })
            searchViewHidden = false
            self.searchViewTopConstraint.constant = (self.navigationController?.navigationBar.frame.maxY)!
        } else {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                
                self.searchView.center.y -= self.searchView.frame.height
                
                if self.musicTF.isFirstResponder {
                    self.musicTF.resignFirstResponder()
                }else if self.artistTF.isFirstResponder {
                    self.artistTF.resignFirstResponder()
                }
                
            }, completion: {(finished: Bool) in
                
            })
            searchViewHidden = true
            self.searchViewTopConstraint.constant -= self.searchView.frame.height
        }
    }
    
    func showGoodNumber(n: Int) -> String {
        if n <= 9999 {
            return String(n)
        } else if n <= 99999999 {
            return "\(Int(n/10000))万"
        } else if n <= 999999999999 {
            return "\(Int(n/100000000))億"
        } else {
            return "\(Int(n/1000000000000))兆"
        }
    }
    
    @IBAction func toProfile() {
        performSegue(withIdentifier: "toProfile", sender: nil)
    }
    
    @IBAction func tapAddCategory() {
        tableView.isHidden.toggle()
    }
    
    @IBAction func tapSearchViewBtn() {
        switchSearchView()
    }
    
    @IBAction func tapSearchBtn() {
        FirebaseAPI.shared.searchPost(first: true, music: musicTF.text ?? "", artist: artistTF.text ?? "", category: category, completionHandler: { list in
            self.shareList = list
            self.collectionView.reloadData()
        })
        switchSearchView()
        tableView.isHidden = true
    }
    
    @IBAction func clear() {
        musicTF.text = ""
        artistTF.text = ""
        category = []
        categoryLabel.text = ""
        FirebaseAPI.shared.searchPost(first: true, music: "", artist: "", category: [],  completionHandler: { list in
            self.shareList = list
            self.collectionView.reloadData()
        })
        switchSearchView()
        tableView.isHidden = true
    }
    
    @objc func reload() {
        FirebaseAPI.shared.searchPost(first: true, music: "", artist: "", category: []) { list in
            self.shareList = list
            self.collectionView.reloadData()
            self.refreshCtl.endRefreshing()
        }
    }
}

extension ShareViewController: UICollectionViewDelegate {
    
}

extension ShareViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        shareList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shareCell", for: indexPath) as! ShareCell
        
        //cellのdelegateを呼び出して、indexに代入。お気に入りボタンに使用
        cell.delegate = self
        cell.indexPath = indexPath
        
        cell.musicName?.setTitle(shareList[indexPath.row].musicName, for: .normal)
        cell.artistName?.setTitle(shareList[indexPath.row].artistName, for: .normal)
        let useImage = resize(image: (UIImage(data: shareList[indexPath.row].musicImage)?.withRenderingMode(.alwaysOriginal))!, width: 70)
        
        cell.musicImage?.setImage(useImage, for: .normal)
        cell.content.text = shareList[indexPath.row].content
        
        cell.userName.text = shareList[indexPath.row].userID
        var a: String = ""
        for i in shareList[indexPath.row].category {
            a += "#" + i
        }
        cell.categoryLabel.text = a
        if Manager.shared.goodList.first(where: {$0.contains(shareList[indexPath.row].id!)}) != nil {
            cell.goodBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            goodList.append(true)
        }else{
            cell.goodBtn.setImage(UIImage(systemName: "heart"), for: .normal)
            goodList.append(false)
        }
        cell.goodNumLabel.text = showGoodNumber(n:shareList[indexPath.row].goodNumber)
        
        return cell
    }
    
}

extension ShareViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // スクロールが最下部に達したら次のページのデータを取得
        if indexPath.item == FirebaseAPI.shared.postDocuments.count - 1 {
            FirebaseAPI.shared.searchPost(first: false, music: musicTF.text ?? "", artist: artistTF.text ?? "", category: category, completionHandler: { list in
                self.shareList.append(contentsOf: list)
                collectionView.reloadData()
            })
        }
    }
}

extension ShareViewController: ShareCellDelegate {
    func reloadCell(indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shareCell", for: indexPath) as! ShareCell
        let selectedID = shareList[indexPath.row].id!
        FirebaseAPI.shared.goodUpdate(id: selectedID, good: goodList[indexPath.row])
        print(goodList[indexPath.row], "goodListBefore")
        if goodList[indexPath.row] {
            shareList[indexPath.row].goodNumber -= 1
            cell.goodBtn.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            shareList[indexPath.row].goodNumber += 1
            cell.goodBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        
        cell.goodNumLabel.text = showGoodNumber(n: shareList[indexPath.row].goodNumber)
        goodList[indexPath.row].toggle()
        print(goodList[indexPath.row], "goodListAfter")
        collectionView.reloadData()
    }
    
    func tapMusic(indexpath indexPath: IndexPath) {
        let selectedMusic = shareList[indexPath.row].musicName
        FirebaseAPI.shared.searchPost(first: true, music: selectedMusic, artist: "", category: []) { list in
            self.shareList = list
            self.musicTF.text = selectedMusic
            self.artistTF.text = ""
            self.category = []
            self.categoryLabel.text = ""
            self.collectionView.reloadData()
        }
    }
    
    func tapArtist(indexPath: IndexPath) {
        let selectedArtist = shareList[indexPath.row].artistName
        FirebaseAPI.shared.searchPost(first: true, music: "", artist: selectedArtist, category: []) { list in
            self.shareList = list
            self.musicTF.text = ""
            self.artistTF.text = selectedArtist
            self.category = []
            self.categoryLabel.text = ""
            self.collectionView.reloadData()
        }
    }
}

extension ShareViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if tableView.indexPathsForSelectedRows!.count <= 5 {
            cell?.accessoryType = .checkmark
            setupCategory()
        }else{
            func alert(title: String, message: String) {
                alertCtl = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertCtl.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertCtl, animated: true)
            }
            alert(title: "入力ミス", message: "選択できるのは5個までです")
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .none
        setupCategory()
    }
}

extension ShareViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Material.shared.categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = Material.shared.categoryList[indexPath.row]
        cell.selectionStyle = .none
        // セルの状態を確認しチェック状態を反映する
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        if selectedIndexPaths != nil && (selectedIndexPaths?.contains(indexPath))! {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
}
