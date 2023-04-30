//
//  AddToListViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/26.
//

import UIKit

class AddToListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    var lists: [Lists] = []
    var listOrder: [String] = []
    var idList: [String] = []
    
    let initialData: [Lists] = [Lists(listName: "お気に入り",
                                      listImage: (UIImage(systemName: "checkmark.seal.fill")?.withTintColor(UIColor(red: 0.93, green: 0.47, blue: 0.18, alpha: 1.0)).pngData()!)!, id: "0")
                                ]
    
    
    
    @IBAction func cancel() {
        self.dismiss(animated: true)
    }
    
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🇹🇰", idList)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CollectionViewCell1", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell1")
        
        lists = []
        listOrder = []
        
        userDB.getDocument { (document, err) in
            if let document = document, document.exists{
                self.listOrder = document.data()!["listOrder"] as? [String] ?? []
                print("getting listOrder")
            } else {
                print("Error getting listOrder")
            }
            self.listRef.getDocuments { (document, err) in
                for i in document!.documents {
                    do {
                        print("getting list")
                        self.lists.append(try i.data(as: Lists.self))
                    } catch {
                        print("Error getting list")
                    }
                }
                var preList: [Lists] = []
                
                for i in self.listOrder {
                    
                    preList.append(self.lists.first(where: {$0.id!.contains(i)})!)
                }
                self.lists = self.initialData
                
                self.lists += preList
                self.collectionView.reloadData()
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCollectionCell1", for: indexPath) as! CollectionViewCell1
        cell.image.image = UIImage(data: lists[indexPath.row].listImage)!
        cell.label.text = lists[indexPath.row].listName
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("🇩🇪", idList)
        if indexPath.row == 0 {
            for id in idList {
                userDB.collection("musicList").document(id).updateData([
                    "favorite": true
                ])
            }
        } else {
            for id in idList {
                userDB.collection("musicList").document(id).updateData([
                    "lists": FieldValue.arrayUnion([lists[indexPath.row].id!])
                ])
            }
        }
        self.dismiss(animated: true)
            
    }
    
    
    
}
