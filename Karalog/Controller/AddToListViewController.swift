//
//  AddToListViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/26.
//

import UIKit

class AddToListViewController: UIViewController {
    
    var idList: [String] = []
    
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        checkIdListData()
    }

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CollectionViewCell1", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell1")
    }

    func checkIdListData() {
        if Manager.shared.lists.isEmpty {
            FirebaseAPI.shared.getlist(completionHandler: {_ in
                self.collectionView.reloadData()
            })
        }
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true)
    }
}

extension AddToListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            for id in idList {
                FirebaseAPI.shared.favoriteUpdate(id: id, favorite: true, completionHandler: { _ in})
            }
        } else {
            for id in idList {
                FirebaseAPI.shared.addMusicToList(musicID: id, listID: Manager.shared.lists[indexPath.row + 1].id!)
            }
        }
        self.dismiss(animated: true)
            
    }
}

extension AddToListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Manager.shared.lists.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCollectionCell1", for: indexPath) as! CollectionViewCell1
        var a = Manager.shared.lists
        a.remove(at: 1)
        cell.image.image = UIImage(data: a[indexPath.row].listImage)!
        cell.label.text = a[indexPath.row].listName
        return cell
    }
}
extension AddToListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 170)
    }
}
