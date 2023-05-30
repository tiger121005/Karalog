//
//  ShareViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/05/25.
//

import UIKit

class ShareViewController: UIViewController {
    
    var shareList: [Post] = []
    
    @IBOutlet var collectionView: UICollectionView!

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
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ShareCell", bundle: nil), forCellWithReuseIdentifier: "shareCell")
        collectionView.keyboardDismissMode = .onDrag
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
        if shareList[indexPath.row].goodSelf {
            cell.goodBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            cell.goodBtn.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        return cell
    }
    
    
}

extension ShareViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // スクロールが最下部に達したら次のページのデータを取得
        print("🇲🇸", indexPath.item)
        print("🇲🇱", FirebaseAPI.shared.postDocuments.count - 1)
        print(self.shareList.count)
        if indexPath.item == FirebaseAPI.shared.postDocuments.count - 1 {
            print(33333333333)
            FirebaseAPI.shared.getPost(first: false, completionHandler: { list in
                self.shareList.append(contentsOf: list)
                collectionView.reloadData()
                
            })
        }
    }
}

extension ShareViewController: ShareCellDelegate {
    func reloadCell(indexPath: IndexPath) {
        dump(shareList[indexPath.row])
        let selectedID = shareList[indexPath.row].id!
        FirebaseAPI.shared.goodUpdate(id: selectedID, good: shareList[indexPath.row].goodSelf, shareList: shareList)
        shareList[indexPath.row].goodSelf.toggle()
        
        collectionView.reloadData()
        
        print(shareList[indexPath.row].goodSelf)
    }
}
