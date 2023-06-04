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
    var sendWord = ""
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
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
        setupCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        FirebaseAPI.shared.getPost(first: true, completionHandler: {list in
            self.shareList = list
            self.collectionView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchPost" {
            
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
        
        collectionView.collectionViewLayout = compositionalLayout
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
        let useImage = resize(image: (UIImage(data: shareList[indexPath.row].musicImage)?.withRenderingMode(.alwaysOriginal))!, width: 45)
        cell.musicImage?.setImage(useImage, for: .normal)
        cell.content.text = shareList[indexPath.row].content
        cell.userName.text = shareList[indexPath.row].userName
        print(Manager.shared.goodList)
        print(Manager.shared.goodList.first(where: {$0.contains(shareList[indexPath.row].id!)}))
        if Manager.shared.goodList.first(where: {$0.contains(shareList[indexPath.row].id!)}) != nil {
            print(9999999999999)
            cell.goodBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            goodList.append(true)
        }else{
            cell.goodBtn.setImage(UIImage(systemName: "heart"), for: .normal)
            goodList.append(false)
        }
        
        return cell
    }
    
    
}

extension ShareViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // スクロールが最下部に達したら次のページのデータを取得
        if indexPath.item == FirebaseAPI.shared.postDocuments.count - 1 {
            FirebaseAPI.shared.getPost(first: false, completionHandler: { list in
                self.shareList.append(contentsOf: list)
                collectionView.reloadData()
                
            })
        }
    }
}

extension ShareViewController: ShareCellDelegate {
    func reloadCell(indexPath: IndexPath) {
        let selectedID = shareList[indexPath.row].id!
        FirebaseAPI.shared.goodUpdate(id: selectedID, good: goodList[indexPath.row])
        goodList[indexPath.row].toggle()
        
        collectionView.reloadData()
        
        print(goodList[indexPath.row])
    }

}
