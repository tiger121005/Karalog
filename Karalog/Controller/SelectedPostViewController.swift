//
//  SelectedPostViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/08/10.
//

import UIKit

class SelectedPostViewController: UIViewController, ShareCellDelegate {
    
    var goodList: [Bool] = []
    var remainingList: [String] = []
    var kind: String!
    var shareList: [Post] = []
    var userID: String!
    var userName: String!
    var finalContent: Bool = false
    
    @IBOutlet var collectionView: UICollectionView!
    
    let refreshCtl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if kind == "past" {
            FirebaseAPI.shared.searchUserPost(first: true, id: userID, name: userName) { list in
                self.shareList = list
                self.finalContent = false
                self.collectionView.reloadData()
                
            }
        } else if kind == "good" {
            Task {
                remainingList = Manager.shared.user.goodList
                let first6 = remainingList.prefix(6)
                
                remainingList.removeFirst(first6.count)
                
                self.shareList = await FirebaseAPI.shared.searchGoodList(goodList: first6)
                self.collectionView.reloadData()
            }
        }
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ShareCell", bundle: nil), forCellWithReuseIdentifier: "shareCell")
        
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
    
    func reloadCell(indexPath: IndexPath) {
        
    }
    
    func tapMusic(indexpath: IndexPath) {
        
    }
    
    func tapArtist(indexPath: IndexPath) {
        
    }
    

    @objc func reload() {
        if kind == "past" {
            FirebaseAPI.shared.searchUserPost(first: true, id: userID, name: userName) { list in
                self.shareList = list
                self.finalContent = false
                self.collectionView.reloadData()
                self.refreshCtl.endRefreshing()
            }
        } else if kind == "good" {
            Task {
                let first6 = remainingList.prefix(6)
                
                remainingList.removeFirst(first6.count)
                
                self.shareList = await FirebaseAPI.shared.searchGoodList(goodList: first6)
                self.collectionView.reloadData()
                self.refreshCtl.endRefreshing()
            }
        }
    }
}

extension SelectedPostViewController: UICollectionViewDelegate {
    
}

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
        let useImage = resize(image: (UIImage(data: shareList[indexPath.row].musicImage)?.withRenderingMode(.alwaysOriginal))!, width: 70)
        
        cell.musicImage?.setImage(useImage, for: .normal)
        cell.content.text = shareList[indexPath.row].content
        
        cell.userName.text = shareList[indexPath.row].userID
        var a: String = ""
        for i in shareList[indexPath.row].category {
            a += "#" + i
        }
        cell.categoryLabel.text = a
        if Manager.shared.user.goodList.first(where: {$0.contains(shareList[indexPath.row].id!)}) != nil {
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

extension SelectedPostViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        Task {
            print(99999, indexPath.row, self.shareList.count)
            // スクロールが最下部に達したら次のページのデータを取得
            if !finalContent {
                if indexPath.row == self.shareList.count - 1 {
                    if kind == "past" {
                        FirebaseAPI.shared.searchUserPost(first: false, id: userID, name: userName) { list in
                            if list.isEmpty {
                                self.finalContent = true
                                return
                            }
                            self.shareList.append(contentsOf: list)
                            DispatchQueue.main.async {
                                collectionView.reloadData()
                            }
                        }
                    } else if kind == "good" {
                        let first6 = remainingList.prefix(6)
                        if first6.isEmpty {
                            self.finalContent = true
                            return
                        }
                        remainingList.removeFirst(first6.count)
                        
                        self.shareList.append(contentsOf: await FirebaseAPI.shared.searchGoodList(goodList: first6))
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}
