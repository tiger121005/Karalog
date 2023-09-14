//
//  ShareViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/05/25.
//

import UIKit

var fromPost = false


//MARK: - ShareViewController

class ShareViewController: UIViewController {
    
    var shareList: [Post] = []
    var sendWord: String = ""
    var category: [String] = []
    var searchViewHidden: Bool = true
    var finalContent: Bool = false
    
    
    //MARK: - UI objects
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet var searchView: UIView!
    @IBOutlet var musicTF: UITextField!
    @IBOutlet var artistTF: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var searchBtn: CustomButton!
    @IBOutlet var searchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout! {
        didSet{
            flowLayout.minimumLineSpacing = 1
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.scrollDirection = .vertical
            flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }
    var alertCtl: UIAlertController!
    var addAlert: UIAlertController!
    let refreshCtl = UIRefreshControl()
    var outBtn: UIButton!
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchView()
        setupCollectionView()
        title = "SHARE"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showMessage()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        closeTableView(touch: touches.first)
        
    }
    
    
    //MARK: - Setup
    
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
        collectionView.addSubview(refreshCtl)
        collectionView.collectionViewLayout = compositionalLayout
    }
    
    func setCategory() {
        categoryLabel.numberOfLines = 0
        if let _indexPathList = self.tableView.indexPathsForSelectedRows {
            var text: String = ""
            var newLine: Bool = false
            for i in _indexPathList {
                if newLine {
                    text += "\n#" + material.categoryList[i.row]
                    category.append(material.categoryList[i.row])
                }else {
                    text = "#" + material.categoryList[i.row]
                    newLine = true
                    category = [material.categoryList[i.row]]
                    
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
        
        musicTF.delegate = self
        artistTF.delegate = self
        
        categoryLabel.layer.cornerRadius = 5
        categoryLabel.layer.cornerCurve = .continuous
        
        searchView.layer.cornerRadius = 15
        searchView.layer.cornerCurve = .continuous
        searchView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        //tableView表示時、関係ない部分を暗くする
        let tapOutBtn = UIAction() {_ in
            self.switchSearchView()
        }
        outBtn = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), primaryAction: tapOutBtn)
        outBtn.backgroundColor = .black.withAlphaComponent(0.3)
        self.view.addSubview(outBtn)
        outBtn.isHidden = true
    }
    
    func setData() {
        Task {
            let list = await postFB.searchPost(first: true, music: musicTF.text ?? "", artist: artistTF.text ?? "", category: category)
            self.shareList = list
            self.finalContent = false
            self.collectionView.reloadData()
        }
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
            self.view.bringSubviewToFront(searchView)
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
        outBtn.isHidden.toggle()
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
    
    func showMessage() {
        print("post: ", fromPost)
        if fromPost {
            
            addAlert = UIAlertController(title: "投稿しました", message: "", preferredStyle: .alert)
            present(addAlert, animated: true, completion: nil)
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideAlert), userInfo: nil, repeats: false)
            fromPost = false
        }
    }
    
    func closeTableView(touch: UITouch?) {
        if let _touch = touch {
            let location: CGPoint = _touch.location(in: self.view)
            if location.x < tableView.frame.minX || location.y < tableView.frame.minY {
                tapOutTableView()
            }else if location.x > tableView.frame.maxX || location.y > tableView.frame.maxY {
                tapOutTableView()
            }
        }
    }
    
    
    //MARK: - UI interaction
    
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
        Task {
            let list = await postFB.searchPost(first: true, music: musicTF.text!, artist: artistTF.text!, category: category)
            self.shareList = list
            self.finalContent = false
            self.collectionView.reloadData()
            switchSearchView()
            tableView.isHidden = true
        }
    }
    
    @IBAction func clear() {
        Task {
            musicTF.text = ""
            artistTF.text = ""
            category = []
            categoryLabel.text = ""
            let list = await postFB.searchPost(first: true, music: "", artist: "", category: [])
            self.shareList = list
            self.finalContent = false
            self.collectionView.reloadData()
            
            switchSearchView()
            tableView.isHidden = true
        }
    }
    
    
    //MARK: - Objective - C
    
    @objc func hideAlert() {
        addAlert.dismiss(animated: true)
    }
    
    @objc func reload() {
        Task {
            let list = await postFB.searchPost(first: true, music: musicTF.text!, artist: artistTF.text!, category: category)
            self.shareList = list
            self.finalContent = false
            self.collectionView.reloadData()
            self.refreshCtl.endRefreshing()
        }
    }
}


//MARK: - UICollectionViewDelegate

extension ShareViewController: UICollectionViewDelegate {
    
}


//MARK: - UICollectionViewDataSource

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
//        cell.musicName.sizeToFit()
        cell.artistName?.setTitle(shareList[indexPath.row].artistName, for: .normal)
//        cell.artistName.sizeToFit()
//
//        let topMusicBorder = CALayer()
//        topMusicBorder.frame = CGRect (x: 0, y: cell.musicName.frame.height, width: cell.musicName.frame.width, height: 1)
//        topMusicBorder.backgroundColor = UIColor.imageColor.cgColor
//        cell.musicName.layer.addSublayer(topMusicBorder)
//
//        let topArtistBorder = CALayer()
//        topArtistBorder.frame = CGRect (x: 0, y: cell.artistName.frame.height, width: cell.artistName.frame.width, height: 1)
//        topArtistBorder.backgroundColor = UIColor.imageColor.cgColor
//        cell.artistName.layer.addSublayer(topArtistBorder)
        
        let useImage = resize(image: (UIImage(data: shareList[indexPath.row].musicImage)?.withRenderingMode(.alwaysOriginal))!, width: 70)
        
        cell.musicImage?.setImage(useImage, for: .normal)
        cell.content.text = shareList[indexPath.row].content
        
        cell.userName.text = shareList[indexPath.row].userID
        var a: String = ""
        
        cell.categoryLabel.isHidden = false
        for i in shareList[indexPath.row].category {
            a += "#" + i
        }
        cell.categoryLabel.text = a
        
        if manager.user.goodList.contains(where: {$0.contains(shareList[indexPath.row].id!)}) {
            cell.goodBtn.setImage(UIImage.heartFill, for: .normal)
            
            print(shareList[indexPath.row].musicName)
            
        }else{
            cell.goodBtn.setImage(UIImage.heart, for: .normal)
            
            print(shareList[indexPath.row].musicName)
            
        }
        cell.goodNumLabel.text = showGoodNumber(n:shareList[indexPath.row].goodNumber)
        
        return cell
    }
    
}


//MARK: - UICollectionViewDelegateFlowLayout

extension ShareViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        Task {
            print(99999, indexPath.row, self.shareList.count)
            // スクロールが最下部に達したら次のページのデータを取得
            if !finalContent {
                if indexPath.row == self.shareList.count - 1 {

                    let list = await postFB.searchPost(first: false, music: musicTF.text ?? "", artist: artistTF.text ?? "", category: category)
                    if list.isEmpty {
                        finalContent = true
                        return
                    }
                    let oldCount = self.shareList.count
                    self.shareList.append(contentsOf: list)
                    let newCount = self.shareList.count
                    let newIndexPaths = (oldCount..<newCount).map { IndexPath(item: $0, section: 0) }
                    DispatchQueue.main.async {
                        collectionView.insertItems(at: newIndexPaths)
                    }

                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UICollectionReusableView に設定した Idenfier", for: indexPath as IndexPath)
            // インジケータをぐるぐるさせる処理
            // 次ページを読み込む処理

            return reusableView
        }

        return UICollectionReusableView()
    }
}


//MARK: - ShareCellDelegate

extension ShareViewController: ShareCellDelegate {
    func reloadCell(indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shareCell", for: indexPath) as! ShareCell
        let selectedID = shareList[indexPath.row].id!
        
        var good: Bool!
        if manager.user.goodList.contains(where: { $0 == selectedID}) {
            good = true
        } else {
            good = false
        }
        
        postFB.goodUpdate(id: selectedID, good: good)
        
        if good {
            shareList[indexPath.row].goodNumber -= 1
            cell.goodBtn.setImage(UIImage.heart, for: .normal)
        } else {
            shareList[indexPath.row].goodNumber += 1
            cell.goodBtn.setImage(UIImage.heartFill, for: .normal)
        }
        
        cell.goodNumLabel.text = showGoodNumber(n: shareList[indexPath.row].goodNumber)
        
        collectionView.reloadData()
    }
    
    func tapMusic(indexpath indexPath: IndexPath) {
        let selectedMusic = shareList[indexPath.row].musicName
        //変わっていることをわかるようにする
        shareList = []
        collectionView.reloadData()
        
        Task {
            
            let list = await postFB.searchPost(first: true, music: selectedMusic, artist: "", category: [])
            self.shareList = list
            self.musicTF.text = selectedMusic
            self.artistTF.text = ""
            self.category = []
            self.categoryLabel.text = ""
            self.finalContent = false
            self.collectionView.reloadData()
        }
    }
    
    func tapArtist(indexPath: IndexPath) {
        let selectedArtist = shareList[indexPath.row].artistName
        //変わっていることをわかるようにする
        shareList = []
        collectionView.reloadData()
        Task {
            
            let list = await postFB.searchPost(first: true, music: "", artist: selectedArtist, category: [])
            self.shareList = list
            self.musicTF.text = ""
            self.artistTF.text = selectedArtist
            self.category = []
            self.categoryLabel.text = ""
            self.finalContent = false
            self.collectionView.reloadData()
        }
    }
}


//MARK: - UITableViewDelegate

extension ShareViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if tableView.indexPathsForSelectedRows!.count <= 5 {
            cell?.accessoryType = .checkmark
            setCategory()
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
        setCategory()
    }
}


//MARK: - UITableViewDataSource

extension ShareViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        material.categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = material.categoryList[indexPath.row]
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


//MARK: - UITextFieldDelegate

extension ShareViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == musicTF {
            artistTF.becomeFirstResponder()
        }
        return true
    }
}
