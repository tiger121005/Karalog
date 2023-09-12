//
//  ListFirebase.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/09/10.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore

let listFB = ListFirebase.shared


//MARK: ListFirebase

class ListFirebase: ObservableObject {
    static let shared = ListFirebase()
    
    let db = Firestore.firestore()
    var userRef: DocumentReference!
    var listRef: CollectionReference!
    var wannaRef: CollectionReference!
    var userID: String!
    
    func setupListFB(userID: String) {
        self.userID = userID
        userRef = db.collection("user").document(userID)
        listRef = userRef.collection("lists")
        wannaRef = userRef.collection("wannaList")
    }
    
    
    //MARK: - Get
    
    //listsを取得
    func getList(completionHandler: @escaping (Any) -> Void) {
        userRef.getDocument() { (document, err) in
            if let _document = document, _document.exists{
                do {
                    let user = try _document.data(as: User.self)
                    manager.user.listOrder = user.listOrder
                } catch {
                    return
                }
                
                print("getting listOrder")
                
                self.listRef.getDocuments() { (collection, err) in
                    if let _err = err {
                        print("error getting list: \(_err)")
                        
                    }else{
                        print("getting list")
                        manager.lists = []
                        for document in collection!.documents {
                            do{
                                manager.lists.append(try document.data(as: Lists.self))
                            }catch{
                                print(error)
                            }
                        }
                        var preList: [Lists] = []
                        for i in manager.user.listOrder {
                            preList.append(manager.lists.first(where: {$0.id!.contains(i)})!)
                        }
                        manager.lists = Material.shared.initialListData
                        manager.lists += preList
                        print(manager.lists)
                        completionHandler(true)
                    }
                }
                
            } else {
                print("Error getting listOrder")
            }
            
            
        }
    }
    
    //wannaListを取得
    func getWanna(completionHandler: @escaping ([MusicList]) -> Void) {
        wannaRef.getDocuments { (collection, err) in
            var list: [MusicList] = []
            if let _err = err {
                print("Error getting wanna list: \(String(describing: _err))")
                completionHandler([])
            } else {
                for document in collection!.documents {
                    let name = document.data()[UserRef.WannaListRef.musicName.rawValue] as! String
                    let artist = document.data()[UserRef.WannaListRef.artistName.rawValue] as! String
                    let image = document.data()[UserRef.WannaListRef.musicImage.rawValue] as! Data
                    let id = document.documentID
                    list.append(MusicList(musicName: name,
                                          artistName: artist,
                                          musicImage: image,
                                          favorite: false,
                                          lists: [],
                                          data: [],
                                          id: id))
                }
                completionHandler(list)
            }
            
        }
    }
    
    
    //MARK: - Add
    
    //listを追加
    func addList(listName: String, listImage: Data) {
        let ref = listRef.addDocument(data: [
            UserRef.ListsRef.listName.rawValue: listName,
            UserRef.ListsRef.listImage.rawValue: listImage
        ]){err in
            if let _err = err {
                print("Error adding list: \(_err)")
            }else{
                print("list successfully added")
                
            }
            
        }
        userRef.updateData([
            UserRef.listOrder.rawValue: FieldValue.arrayUnion([ref.documentID])
        ])
        manager.lists.append(Lists(listName: listName, listImage: listImage, id: ref.documentID))
        manager.user.listOrder.append(ref.documentID)
    }
    
    //wannaListを追加
    func addWanna(musicName: String, artistName: String, musicImage: Data) {
        wannaRef.addDocument(data: [
            UserRef.WannaListRef.musicName.rawValue: musicName,
            UserRef.WannaListRef.artistName.rawValue: artistName,
            UserRef.WannaListRef.musicImage.rawValue: musicImage
        ]) {err in
            if let _err = err {
                print("Error adding music: \(_err)")
            }else{
                print("music successfully added")
            }
        }
    }
    
    
    
    
    //MARK: - Delete
    
    //listを削除
    func deleteList(indexPath: IndexPath, completionHandler: @escaping (Any) -> Void) {
        let listID = manager.lists[indexPath.row].id!
        listRef.document(listID).delete() { err in
            if let _err = err {
                print("error removing music: \(_err)")
            }else{
                print("music successfully removed")
                self.userRef.updateData([
                    UserRef.listOrder.rawValue: FieldValue.arrayRemove([listID])
                ]){err in
                    if let _err = err {
                        print("Error deleting music order: \(_err)")
                    }else{
                        print("music order successfully deleted")
                        manager.lists.remove(at: indexPath.row)
                        
                    }
                    completionHandler(true)
                }
            }
            
        }
    }
    
    //wannaListを削除
    func deleteWanna(wannaID: String) {
        wannaRef.document(wannaID).delete(){err in
            if let _err = err {
                print("Error deleting detail: \(_err)")
            }else{
                print("detail successfully deleted")
                
            }
        }
    }
    
    
    
    
    //MARK: Update
    
    //listOrderを更新
    func listOrderUpdate(listOrder: [String]) {
        userRef.updateData([
            UserRef.listOrder.rawValue: listOrder
        ]) {err in
            if let _err = err {
                print("Error updating list order: \(_err)")
            }else{
                print("list order successfully updated")
                manager.user.listOrder = listOrder
            }
        }
    }
}
