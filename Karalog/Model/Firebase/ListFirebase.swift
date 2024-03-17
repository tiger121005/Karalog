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
import FirebaseStorage

let listFB = ListFirebase.shared


//MARK: ListFirebase

class ListFirebase: ObservableObject {
    static let shared = ListFirebase()
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var storageRef: StorageReference!
    var imagesRef: StorageReference!
    var listImageRef: StorageReference!
    var userRef: DocumentReference!
    var listRef: CollectionReference!
    var wannaRef: CollectionReference!
    var userID: String!
    
    func setupListFB(userID: String) {
        self.userID = userID
        userRef = db.collection("user").document(userID)
        listRef = userRef.collection("lists")
        wannaRef = userRef.collection("wannaList")
        storageRef = storage.reference()
        imagesRef = storageRef.child("images")
        
    }
    
    
    //MARK: - Get
    
    
    // リストを取得する関数
    func getList(completionHandler: @escaping (Bool) -> Void) {
        getOrder() {_ in
            self.getRandomList() { collection in
                guard let collection else { return }
                for document in collection.documents {
                    do {
                        let listName = try document.data(as: ListName.self)
                        let id = document.documentID
                        
                        self.listImageRef = self.storageRef.child("images/user/\(String(describing: self.userID))/list/\(id).jpeg")
                            
                        self.listImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                            if let error = error {
                                print("Error getting list image: \(error)")
                                completionHandler(false)
                                return
                            }
                                
                            
                            if let data = data {
                                manager.lists.append(Lists(listName: listName.listName, listImage: data, id: id))
                            }
                                
                            if manager.lists.count == collection.documents.count + 2 {
                                var preList: [Lists] = []
                                for i in manager.user.listOrder {
                                    guard let list = manager.lists.first(where: {$0.id!.contains(i)}) else { continue }
                                    preList.append(list)
                                }
                                manager.lists = material.initialListData()
                                manager.lists += preList
                                
                                // リストデータの取得が完了したことを completionHandler で通知
                                completionHandler(true)
                            }
                        }
                    } catch {
                        print(error)
                        completionHandler(false)
                    }
                }
                manager.lists = material.initialListData()
                completionHandler(true)
            }
        }
    }

    
    
    func getOrder(completionHandler: @escaping (Bool) -> Void) {
        userRef.getDocument() { (document, error) in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    manager.user.listOrder = user.listOrder
                } catch {
                    print("Error getting user data: \(error)")
                    completionHandler(false)
                    return
                }
                
                print("Getting listOrder")
                completionHandler(true)
            } else {
                print("Error getting listOrder")
                completionHandler(false)
            }
        }
    }
    
    func getRandomList(completionHandler: @escaping (QuerySnapshot?) -> Void) {
        self.listRef.getDocuments() { (collection, error) in
            if let error = error {
                print("Error getting list: \(error)")
                completionHandler(nil)
                return
            }
            completionHandler(collection)
            print("Getting list")
            manager.lists = material.initialListData()
        }
    }
    
    //wannaListを取得
    func getWanna() async -> [MusicList]? {
        await withCheckedContinuation { continuation in
            wannaRef.getDocuments { (collection, err) in
                var list: [MusicList] = []
                if let _err = err {
                    print("Error getting wanna list: \(String(describing: _err))")
                    continuation.resume(returning: nil)
                } else {
                    guard let collection else { return }
                    for document in collection.documents {
                        
                        let name = document.data()[UserRef.WannaListRef.musicName.rawValue] as! String
                        let artist = document.data()[UserRef.WannaListRef.artistName.rawValue] as! String
                        let image = document.data()[UserRef.WannaListRef.musicImage.rawValue] as! String
                        let id = document.documentID
                        list.append(MusicList(musicName: name,
                                              artistName: artist,
                                              musicImage: image,
                                              favorite: false,
                                              lists: [],
                                              data: [],
                                              id: id))
                    }
                    continuation.resume(returning: list)
                }
                
            }
        }
    }
    
    
    //MARK: - Add
    
    //listを追加
    func addList(listName: String, listImage: Data) {
        
        let ref = self.listRef.addDocument(data: [
            UserRef.ListsRef.listName.rawValue: listName
        ]){err in
            if let _err = err {
                print("Error adding list: \(_err)")
            }else{
                print("list successfully added")
                
            }
        }
        
        listImageRef = storageRef.child("images/user/\(String(describing: userID))/list/\(ref.documentID).jpeg")
        let storagePath = "gs://karalog-39e53.appspot.com/images/user/\(String(describing: userID))/list/\(ref.documentID).jpeg"
        listImageRef = storage.reference(forURL: storagePath)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        listImageRef.putData(listImage, metadata: metaData) { (metaData, err) in
            if let err {
                print("Error adding list image: \(err)")
                return
            }
        }
           
        
        self.userRef.updateData([
            UserRef.listOrder.rawValue: FieldValue.arrayUnion([ref.documentID])
        ])
        manager.lists.append(Lists(listName: listName, listImage: listImage, id: ref.documentID))
        manager.user.listOrder.append(ref.documentID)
    }
    
    //wannaListを追加
    func addWanna(musicName: String, artistName: String, musicImage: String, completionHandler: @escaping (Any) -> Void) {
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
        if let listID = manager.lists[indexPath.row].id {
            listImageRef = storageRef.child("images/user/\(String(describing: userID))/list/\(listID).jpeg")
            let storagePath = "gs://karalog-39e53.appspot.com/images/user/\(String(describing: userID))/list/\(listID).jpeg"
            listImageRef = storage.reference(forURL: storagePath)
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
                        
                        self.listImageRef.delete { error in
                            if let error {
                                print("Error delete list image:", error)
                            }
                        }
                        completionHandler(true)
                    }
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
