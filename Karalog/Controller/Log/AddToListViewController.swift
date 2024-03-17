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
    }
    
    
    //MARK: - Setup

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CollectionViewCell1", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell1")
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
                musicFB.favoriteUpdate(id: id, favorite: true, completionHandler: { _ in
                    self.dismiss(animated: true)
                })
            }
            
        case 1:
            for id in idList {
                if let music = manager.musicList.first(where: {$0.id == id}) {
                    listFB.addWanna(musicName: music.musicName, artistName: music.artistName, musicImage: music.musicImage, completionHandler: { _ in
                        self.dismiss(animated: true)
                    })
                }
            }
            
        default:
            for id in idList {
                guard let listID = manager.lists[indexPath.row].id else { continue }
                musicFB.addMusicToList(musicID: id, listID: listID) {_ in 
                    self.dismiss(animated: true)
                }
            }
        }
        
            
    }
}


//MARK: - UICollectionViewDataSource

extension AddToListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        manager.lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCollectionCell1", for: indexPath) as! CollectionViewCell1
        let a: [Lists] = manager.lists
        cell.image.image = UIImage(data: a[indexPath.row].listImage) ?? UIImage.KaralogImage
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
