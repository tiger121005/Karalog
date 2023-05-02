//
//  AddToListViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/26.
//

import UIKit

class AddToListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var idList: [String] = []
    
    
    @IBAction func cancel() {
        self.dismiss(animated: true)
    }
    
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CollectionViewCell1", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell1")
        
        if Manager.shared.lists.isEmpty {
            FirebaseAPI.shared.getlist(completionHandler: {_ in
                self.collectionView.reloadData()
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Manager.shared.lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCollectionCell1", for: indexPath) as! CollectionViewCell1
        cell.image.image = UIImage(data: Manager.shared.lists[indexPath.row].listImage)!
        cell.label.text = Manager.shared.lists[indexPath.row].listName
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            for id in idList {
                FirebaseAPI.shared.favoriteUpdate(id: id, favorite: true, completionHandler: { _ in})
            }
        } else {
            for id in idList {
                FirebaseAPI.shared.addMusicToList(musicID: id, listID: Manager.shared.lists[indexPath.row].id!)
            }
        }
        self.dismiss(animated: true)
            
    }
    
    
    
}
