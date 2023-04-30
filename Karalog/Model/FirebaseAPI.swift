//
//  FirebaseAPI.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/04/30.
//

import Foundation
import FirebaseCore
import FirebaseFirestore


struct FirebaseAPI {
    
    static let shared = FirebaseAPI()
    var userID = UserDefaults.standard.string(forKey: "userID")
    var userRef: DocumentReference!
    var musicRef: CollectionReference!
    var listRef: CollectionReference!
    var wannaRef: CollectionReference!
    
    init() {
        
        userRef = Firestore.firestore().collection("user").document(userID!)
        musicRef = userRef.collection("musicList")
    }
    
    
    func getMusic(completionHandler: @escaping ([MusicList]) -> Void) {
        
        musicRef.getDocuments() { (collection, err) in
            if let err = err {
                print("error getting music: \(err)")
                completionHandler([])
            }else{
                Manager.shared.musicList = []
                for document in collection!.documents {
                    do{
                        Manager.shared.musicList.append(try document.data(as: MusicList.self))
                        
                    }catch{
                        print(error)
                    }
                }
                completionHandler(Manager.shared.musicList)
            }
        }
    }
    
    func getlist(completionHandler: @escaping ([Lists]) -> Void) {
        userRef.getDocument() { (document, err) in
            if let document = document, document.exists{
                Manager.shared.listOrder = document.data()!["listOrder"] as? [String] ?? []
                print("getting listOrder")
            } else {
                print("Error getting listOrder")
            }
        }
        listRef.getDocuments() { (collection, err) in
            if let err = err {
                print("error geting list: \(err)")
                completionHandler([])
            }else{
                Manager.shared.lists = []
                for document in collection!.documents {
                    do{
                        Manager.shared.lists.append(try document.data(as: Lists.self))
                    }catch{
                        print(error)
                    }
                }
                completionHandler(Manager.shared.lists)
            }
        }
    }
    
    func getWanna(completionHandler: @escaping ([MusicList]) -> Void) {
        wannaRef.getDocuments { (collection, err) in
            var list: [MusicList] = []
            if let error = err {
                print("Error getting wanna list: \(String(describing: err))")
                completionHandler([])
            } else {
                for document in collection!.documents {
                    let name = document["musicName"] as! String
                    let artist = document["artistName"] as! String
                    let image = document["musicImage"] as! Data
                    let id = document.documentID
                    list.append(MusicList(musicName: name, artistName: artist, musicImage: image, favorite: false, lists: [], data: [], id: id))
                }
                completionHandler(list)
            }
        }
    }
    
    func addMusic(musicName: String, artistName: String, musicImage: Data, time: String, score: Double, key: Int, model: String, comment: String) {
        let detailData = ["time": time, "score": score, "key": key, "model": model, "comment": comment] as [String : Any]
        musicRef.addDocument(data: [
            "musicName": musicName,
            "artistName": artistName,
            "musicImage": musicImage,
            "favorite": false,
            "data": [detailData]
        ]) { err in
            if let err = err {
                print("Error adding music: \(err)")
            }else{
                print("music added")
            }
        }
    }
    
    func deleteMusic(id: String, completionHandler: @escaping (Any) -> Void) {
        musicRef.document(id).delete() { err in
            if let err = err {
                print("error removing music: \(err)")
            }else{
                print("music successfully removed")
            }
            let num = Manager.shared.musicList.firstIndex(where: {$0.id!.contains(id)})
            Manager.shared.musicList.remove(at: num!)
            
        }
    }
    
    func favoriteUpdate(id: String, favorite: Bool, completionHandler: @escaping (Any) -> Void) {
        if favorite == false {
            musicRef.document(id).updateData([
                "favorite": true
            ]){ err in
                if let err = err {
                    print("Error updating favorite: \(err)")
                } else {
                    print("favorite successfully updated")
                    
                    let num = Manager.shared.musicList.firstIndex(where: {$0.id!.contains(id)})
                    Manager.shared.musicList[num!].favorite = true
                    
                    completionHandler(true)
                }
            }
        } else {
            musicRef.document(id).updateData([
                "favorite": false
            ]){ err in
                if let err = err {
                    print("Error updating favorite: \(err)")
                } else {
                    print("favorite successfully updated")
                    
                    let num = Manager.shared.musicList.firstIndex(where: {$0.id!.contains(id)})
                    Manager.shared.musicList[num!].favorite = false
                   
                    completionHandler(true)
                }
            }
        }
    }
    
    func listUpdate(selectedID: String, listID: String, completionHandler: @escaping (Any) -> Void) {
        musicRef.document(selectedID).updateData([
            "lists": FieldValue.arrayRemove([listID])
        ]) { err in
            if let err = err {
                print("Error updating favorite: \(err)")
            } else {
                print("favorite successfully updated")
                
                let num = Manager.shared.musicList.firstIndex(where: {$0.id!.contains(selectedID)})
                Manager.shared.musicList.remove(at: num!)
                
                completionHandler(true)
            }
        }
    }
}
