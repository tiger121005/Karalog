//
//  AllListViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import FirebaseCore

class AllListViewController: UIViewController {
    
    var index: Int = 0
    var listID: String = ""
    var listName: String = ""
    var changeOrder: Bool = false
    
    let refreshCtl = UIRefreshControl()
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        title = "LIST"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveListOrder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toList" {
            let nextView = segue.destination as! ListViewController
            
            nextView.listID = listID
            nextView.listName = listName
        } else if segue.identifier == "toAddList" {
            let nextView = segue.destination as! AddListViewController
            
        } 
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CollectionViewCell1", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell1")
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
        collectionView.dragInteractionEnabled = true
        
        collectionView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        refreshCtl.attributedTitle = NSAttributedString(string: "再読み込み中")
        collectionView.addSubview(refreshCtl)
    }
    
    func saveListOrder() {
        if changeOrder {
            FirebaseAPI.shared.listOrderUpdate(listOrder: Manager.shared.user.listOrder)
            changeOrder = false
        }
    }
    
    func reloadList() {
        collectionView.reloadData()
    }
    
    @objc func reload() {
        FirebaseAPI.shared.getList() {_ in
            self.collectionView.reloadData()
            self.refreshCtl.endRefreshing()
        }
        
    }
    
}

extension AllListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            listID = "0"
        } else if indexPath.row == 1 {
            listID = "1"
        } else {
            listID = Manager.shared.lists[indexPath.row].id!
        }
        listName = Manager.shared.lists[indexPath.row].listName
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
                    let alert = UIAlertController(title: "削除", message: "”" + Manager.shared.lists[indexPath.row].listName + "”" + "を削除しますか", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                        
                    }
                    
                    let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                        FirebaseAPI.shared.deleteList(indexPath: indexPath, completionHandler: {_  in
                            self.collectionView.reloadData()
                        })
                        
                    }
                    alert.addAction(cancel)
                    alert.addAction(delete)
                    self.present(alert, animated: true, completion: nil)
                }
            }

            return UIMenu(title: "編集", image: nil, identifier: nil, children: [delete])
        }

        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: actionProvider)
    }
}

extension AllListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Manager.shared.lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCollectionCell1", for: indexPath) as! CollectionViewCell1
        cell.image.image = UIImage(data: Manager.shared.lists[indexPath.row].listImage)!
        cell.label.text = Manager.shared.lists[indexPath.row].listName
        if cell.image.image == UIImage(systemName: "music.mic"){
            
        }
        
        return cell
    }
}

extension AllListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 170)
    }
}

extension AllListViewController: UICollectionViewDropDelegate {
    //並び替え
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        switch coordinator.proposal.operation {
        case .move:
            let destinationIndexPath: IndexPath
                    if let _indexPath = coordinator.destinationIndexPath {
                        destinationIndexPath = _indexPath
                    } else {
                        let section = collectionView.numberOfSections - 1
                        let row = collectionView.numberOfItems(inSection: section)
                        destinationIndexPath = IndexPath(row: row, section: section)
                    }
                    coordinator.items.forEach { item in
                        guard let _sourceIndexPath = item.sourceIndexPath else { return }
                        collectionView.performBatchUpdates({
                            let i = Manager.shared.lists.remove(at: _sourceIndexPath.row)
                            let j = Manager.shared.user.listOrder.remove(at: _sourceIndexPath.row - 2)
                            Manager.shared.lists.insert(i, at: destinationIndexPath.row)
                            Manager.shared.user.listOrder.insert(j, at: destinationIndexPath.row - 2)
                            collectionView.deleteItems(at: [_sourceIndexPath])
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
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let lastItemInFirstSection = collectionView.numberOfItems(inSection: 0)
        let destinationIndexPath: IndexPath = destinationIndexPath ?? .init(item: lastItemInFirstSection - 1, section: 0)
        if session.localDragSession == nil {
            // 外部からのドロップならキャンセルする
            return UICollectionViewDropProposal(operation: .cancel)
            
        } else if destinationIndexPath.row >= 2 {
            
            // 内部からのドロップなら並び替えする
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
    }
}

extension AllListViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.row <= 1 { return [] }
        let itemIdentifier = Manager.shared.lists[indexPath.item].id! as String
        let itemProvider = NSItemProvider(object: itemIdentifier as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}
