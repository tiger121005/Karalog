//
//  SelectedPostViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/08/10.
//

import UIKit
import DZNEmptyDataSet


//MARK: - SelectedPostViewController

class SelectedPostViewController: UIViewController {
    
    var remainingList: [String] = []
    var kind: String!
    var shareList: [Post] = []
    var imageList: [UIImage] = []
    var userID: String!
    var userName: String!
    var finalContent: Bool = false
    let goodList = manager.user.goodList
    
    
    //MARK: - UI objects
    
    @IBOutlet var collectionView: UICollectionView!
    let refreshCtl = UIRefreshControl()
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setData()
    }
    
    
    //MARK: - Setup
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ShareCell", bundle: nil), forCellWithReuseIdentifier: "shareCell")
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
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
    
    func setupTitle() {
        if kind == "good" {
            title = "いいね"
        } else {
            title = "過去の投稿"
        }
    }
    
    func setData() {
        Task {
            if kind == "past" {
                guard let list = await postFB.searchUserPost(first: true, id: userID, name: userName) else { return }
                self.shareList = list
                self.finalContent = false
                
            } else if kind == "good" {
                
                remainingList = manager.user.goodList
                let first6 = remainingList.prefix(6)
                
                remainingList.removeFirst(first6.count)
                
                self.shareList = await postFB.searchGoodList(goodList: first6)
                
            }
            await reloadData()
        }
    }
    
    func getImage() async {
        imageList = []
        let list = self.shareList
        var updatedList: [Post] = []
        if list.count != 0 {
            for i in 0..<list.count {
                if let image = await UIImage.fromUrl(url: list[i].musicImage) {
                    imageList.append(image)
                    updatedList.append(list[i])
                }
            }
            shareList = updatedList
        }
    }
    
    func reloadData() async {
        Task {
            await getImage()
            collectionView.reloadData()
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
    
    
    //MARK: - Objective - C
    
    @objc func reload() {
        Task {
            if kind == "past" {
                guard let list = await postFB.searchUserPost(first: true, id: userID, name: userName) else { return }
                self.shareList = list
                self.finalContent = false
            } else if kind == "good" {
                let first6 = remainingList.prefix(6)
                
                remainingList.removeFirst(first6.count)
                
                self.shareList = await postFB.searchGoodList(goodList: first6)
            }
            await reloadData()
            self.refreshCtl.endRefreshing()
        }
    }
}


//MARK: - UICollectionViewDelegate

extension SelectedPostViewController: UICollectionViewDelegate {
    
    //長押しした時の処理
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt
                        indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if kind == "past" && userID == manager.user.id{
            
            let actionProvider: ([UIMenuElement]) -> UIMenu? = { _ in
                let delete = UIAction(title: "削除", image: UIImage.trash, attributes: .destructive) { _ in
                    
                    //alert
                    let alert = UIAlertController(title: "削除", message: "”" + self.shareList[indexPath.row].musicName + "”" + "を削除しますか", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                        
                    }
                    
                    let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                        guard let id = self.shareList[indexPath.row].id else { return }
                        postFB.deletePost(id: id) {_ in
                            self.shareList.remove(at: indexPath.row)
                            self.imageList.remove(at: indexPath.row)
                            self.collectionView.deleteItems(at: [indexPath])
                        }
                        
                    }
                    alert.addAction(cancel)
                    alert.addAction(delete)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
                return UIMenu(title: "編集", image: nil, identifier: nil, children: [delete])
            }
            
            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil,
                                              actionProvider: actionProvider)
        } else {
            return nil
        }
        
        
        
        
    }
}


//MARK: - UICollectionViewDataSource

extension SelectedPostViewController: UICollectionViewDataSource {
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
        let useImage = resize(image: imageList[indexPath.row], width: 70)
        cell.musicImage?.setImage(useImage, for: .normal)
        
        
        cell.content.text = shareList[indexPath.row].content
        
        cell.userName.text = shareList[indexPath.row].userID
        var a: String = ""
        for i in shareList[indexPath.row].category {
            a += "#" + i
        }
        cell.categoryLabel.text = a
        if manager.user.goodList.contains(where: { id in id == shareList[indexPath.row].id! }) {
            cell.goodBtn.setImage(UIImage.heartFill, for: .normal)
            
        }else{
            cell.goodBtn.setImage(UIImage.heart, for: .normal)
            
        }
        cell.goodNumLabel.text = showGoodNumber(n:shareList[indexPath.row].goodNumber)
        
        return cell
    }
    
    
}


//MARK: - UICollectionViewDelegateFlowLayout

extension SelectedPostViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        Task {
            // スクロールが最下部に達したら次のページのデータを取得
            if !finalContent {
                if indexPath.row == self.shareList.count - 1 {
                    if kind == "past" {
                        guard var list = await postFB.searchUserPost(first: false, id: userID, name: userName) else { return }
                        if list.isEmpty {
                            print("finalContent")
                            return
                        }
                        
                        var updatedList: [Post]  = []
                        for i in 0..<list.count {
                            if let image = await UIImage.fromUrl(url: list[i].musicImage) {
                                imageList.append(image)
                                updatedList.append(list[i])
                                
                            }
                            
                        }
                        list = updatedList
                        
                        let oldCount = self.shareList.count
                        self.shareList.append(contentsOf: list)
                        let newCount = self.shareList.count
                        let newIndePaths = (oldCount..<newCount).map {IndexPath(item: $0, section: 0) }
                        DispatchQueue.main.async {
                            collectionView.insertItems(at: newIndePaths)
                        }
                        
                    } else if kind == "good" {
                        let first6 = remainingList.prefix(6)
                        if first6.isEmpty {
                            self.finalContent = true
                            return
                        }
                        remainingList.removeFirst(first6.count)
                        var post = await postFB.searchGoodList(goodList: first6)
                        
                        var a = 0
                        for i in 0..<post.count {
                            guard let image = await UIImage.fromUrl(url: post[i].musicImage) else {
                                post.remove(at: i - a)
                                a += 1
                                continue
                            }
                            imageList.append(image)
                        }
                        
                        let oldCount = self.shareList.count
                        self.shareList.append(contentsOf: post)
                        let newCount = self.shareList.count
                        let newCountIndexPaths = (oldCount..<newCount).map {IndexPath(item: $0, section: 0) }
                        DispatchQueue.main.async {
                            self.collectionView.insertItems(at: newCountIndexPaths)
                            
                        }
                    }
                }
                
            }
        }
    }
}


//MARK: - ShareCellDelegate

extension SelectedPostViewController: ShareCellDelegate {
    func reloadCell(indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shareCell", for: indexPath) as! ShareCell
        if let selectedID = shareList[indexPath.row].id {
            
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
    }
    
    func tapMusic(indexpath: IndexPath) {
        
    }
    
    func tapArtist(indexPath: IndexPath) {
        
    }
}


//MARK: - DZNEmptyDataSetSource

extension SelectedPostViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString {
        return NSAttributedString("データがありません")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage {
        return UIImage.KaralogImage.resized(toWidth: 250) ?? UIImage.KaralogImage
    }
}


//MARK: - DZNEmptyDataSetDelegate

extension SelectedPostViewController: DZNEmptyDataSetDelegate {
    
}
