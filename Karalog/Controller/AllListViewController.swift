//
//  AllListViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class AllListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDropDelegate, UICollectionViewDragDelegate {
    
    

    var listRef: CollectionReference!
    var lists: [Lists] = []
    var index = 0
    var listID = ""
    var listOrder: [String] = []
    var userID = ""
    var changeOrder = false
    
    @IBOutlet var listCV: UICollectionView!
    
    let initialData: [Lists] = [Lists(listName: "お気に入り",
                                      listImage: (UIImage(systemName: "checkmark.seal.fill")?.withTintColor(UIColor(red: 0.93, green: 0.47, blue: 0.18, alpha: 1.0)).pngData()!)!, id: "0"),
                                Lists(listName: "歌いたい",
                                      listImage: (UIImage(systemName: "lasso.and.sparkles")?.withTintColor(UIColor(red: 0.93, green: 0.43, blue: 0.18, alpha: 1.0)).pngData()!)!, id: "1")]
    let firstData = UIImage(systemName: "checkmark.seal.fill")?.withTintColor(UIColor(red: 0.93, green: 0.47, blue: 0.18, alpha: 1.0)).pngData()!
    let secondData = UIImage(systemName: "lasso.and.sparkles")?.withTintColor(UIColor(red: 0.93, green: 0.43, blue: 0.18, alpha: 1.0)).pngData()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listCV.delegate = self
        listCV.dataSource = self
        listCV.register(UINib(nibName: "CollectionViewCell1", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell1")
        listCV.dropDelegate = self
        listCV.dragDelegate = self
        listCV.dragInteractionEnabled = true
        
        userID = UserDefaults.standard.string(forKey: "userID")!
        listRef = Firestore.firestore().collection("user").document(userID).collection("lists")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lists = []
        listOrder = []
        
        Firestore.firestore().collection("user").document(userID).getDocument { (document, err) in
            if let document = document, document.exists{
                self.listOrder = document.data()!["listOrder"] as? [String] ?? []
                print("getting listOrder")
            } else {
                print("Error getting listOrder")
            }
            self.listRef.getDocuments { (document, err) in
                for i in document!.documents {
                    print("🇳🇫", i)
                    do {
                        self.lists.append(try i.data(as: Lists.self))
                        print("🇦🇷", self.lists)
                    } catch {
                        print("Error getting list")
                    }
                }
                var preList: [Lists] = []
                print(self.listOrder)
                for i in self.listOrder {
                    
                    preList.append(self.lists.first(where: {$0.id!.contains(i)})!)
                }
                self.lists = self.initialData
                print("🇧🇩", preList)
                self.lists += preList
                print("🇶🇦", self.lists)
                DispatchQueue.main.async {
                    self.listCV.reloadData()
                }
            }
        }
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if changeOrder {
            Firestore.firestore().collection("user").document(userID).updateData([
                "listOrder": listOrder
            ])
            changeOrder = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toList" {
            let nextView = segue.destination as! ListViewController
            
            nextView.listID = listID
        } else if segue.identifier == "toAddList" {
            let nextView = segue.destination as! AddListViewController
            
            nextView.listRef = listRef
        } 
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCollectionCell1", for: indexPath) as! CollectionViewCell1
        cell.image.image = UIImage(data: lists[indexPath.row].listImage)!
        cell.label.text = lists[indexPath.row].listName
        if cell.image.image == UIImage(systemName: "music.mic"){
            
        }
        
//        cell.background.layer.cornerRadius = cell.background.frame.width * 0.2
//        cell.background.clipsToBounds = true
//        cell.ListNameLabel.textColor = .black
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 170)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            listID = "0"
        } else if indexPath.row == 1 {
            listID = "1"
        } else {
            listID = lists[indexPath.row].id!
        }
        
        performSegue(withIdentifier: "toList", sender: nil)
    }
    
    //長押しした時の処理
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt
        indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // ②メニューの定義
        let actionProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            let delete = UIAction(title: "削除", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                if indexPath.row == 0{
                    let alert = UIAlertController(title: "できません", message: "｢お気に入り｣は削除できません", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "OK", style: .default) { (action) in
                        
                    }
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                }else if indexPath.row == 1{
                    let alert = UIAlertController(title: "できません", message: "｢歌いたい｣は削除できません", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "OK", style: .default) { (action) in
                        
                    }
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                }else{
                    //alert
                    let alert = UIAlertController(title: "削除", message: "”" + self.lists[indexPath.row].listName + "”" + "を削除しますか", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                        
                        let selectedId = self.lists[indexPath.row].id!
                        self.listRef.document(selectedId).delete() { err in
                            if let err = err {
                                print("error removing music: \(err)")
                            }else{
                                print("music successfully removed")
                                self.lists.remove(at: indexPath.row)
                                self.listCV.reloadData()
                            }
                        }
                        
                        
                    
                    }
                    alert.addAction(cancel)
                    alert.addAction(delete)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            //menuの中にmenuを作る
//            let editMenu: UIMenu = {
//                let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { _ in
//                    // some action
//                    self.allListName.remove(at: indexPath.row)
//                    self.allListImage.remove(at: indexPath.row)
//                    self.allNumberList.remove(at: indexPath.row)
//                    self.AllListCollectionView.reloadData()
//                }
//                return UIMenu(title: "Edit..", image: nil, identifier: nil, children: [delete])
//            }()

            return UIMenu(title: "編集", image: nil, identifier: nil, children: [delete])
        }

        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: actionProvider)
    }
    
    //並び替え
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        switch coordinator.proposal.operation {
        case .move:
            let destinationIndexPath: IndexPath
                    if let indexPath = coordinator.destinationIndexPath {
                        destinationIndexPath = indexPath
                    } else {
                        let section = collectionView.numberOfSections - 1
                        let row = collectionView.numberOfItems(inSection: section)
                        destinationIndexPath = IndexPath(row: row, section: section)
                    }
                    coordinator.items.forEach { item in
                        guard let sourceIndexPath = item.sourceIndexPath else { return }
                        collectionView.performBatchUpdates({
                            let i = self.lists.remove(at: sourceIndexPath.row)
                            let j = self.listOrder.remove(at: sourceIndexPath.row - 2)
                            self.lists.insert(i, at: destinationIndexPath.row)
                            self.listOrder.insert(j, at: destinationIndexPath.row - 2)
                            collectionView.deleteItems(at: [sourceIndexPath])
                            collectionView.insertItems(at: [destinationIndexPath])
                            changeOrder = true
                        })
                        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                    }
        
        case .cancel, .forbidden, .copy:
            return
            
        @unknown default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.row <= 1 { return [] }
        let itemIdentifier = lists[indexPath.item].id! as String
        let itemProvider = NSItemProvider(object: itemIdentifier as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let lastItemInFirstSection = listCV.numberOfItems(inSection: 0)
        let destinationIndexPath: IndexPath = destinationIndexPath ?? .init(item: lastItemInFirstSection - 1, section: 0)
        if session.localDragSession == nil {
            // 外部からのドロップならキャンセルする
            return UICollectionViewDropProposal(operation: .cancel)
            
        } else if destinationIndexPath.row >= 2 {
            print(999393993333)
            // 内部からのドロップなら並び替えする
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            print(777777777)
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
    }
    

}
