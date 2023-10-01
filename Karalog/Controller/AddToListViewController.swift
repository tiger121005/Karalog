//
//  AddToListViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/26.
//

import UIKit


//MARK: - AddToListViewController

class AddToListViewController: UIViewController {
    
    var idList: [String] = []
    
    
    //MARK: - UI objects
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    //MARK: - View Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        checkIdListData()
    }
    
    
    //MARK: - Setup

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CollectionViewCell1", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell1")
    }

    func checkIdListData() {
        
        listFB.getList(completionHandler: {_ in
            self.collectionView.reloadData()
        })
        
    }
    
    
    // MARK: UI interaction
    
    @IBAction func cancel() {
        self.dismiss(animated: true)
    }
}


//MARK: - UICollectionViewDelegate

extension AddToListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            for id in idList {
                musicFB.favoriteUpdate(id: id, favorite: true, completionHandler: { _ in})
            }
            
        case 1:
            for id in idList {
                if let music = manager.musicList.first(where: {$0.id == id}) {
                    listFB.addWanna(musicName: music.musicName, artistName: music.artistName, musicImage: music.musicImage)
                }
            }
            
        default:
            for id in idList {
                musicFB.addMusicToList(musicID: id, listID: manager.lists[indexPath.row + 1].id!)
            }
        }
        
        self.dismiss(animated: true)
            
    }
}


//MARK: - UICollectionViewDataSource

extension AddToListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        manager.lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCollectionCell1", for: indexPath) as! CollectionViewCell1
        var a: [Lists] = manager.lists
        cell.image.image = UIImage(data: a[indexPath.row].listImage)!
        cell.label.text = a[indexPath.row].listName
        return cell
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension AddToListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 190)
    }
}
