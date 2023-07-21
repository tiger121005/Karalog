//
//  FirebaseAPI.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/04/30.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class FirebaseAPI: ObservableObject {
    
    static let shared = FirebaseAPI()
    var userID = UserDefaults.standard.string(forKey: "userID")
    var userRef: DocumentReference!
    var shareRef: CollectionReference!
    var musicRef: CollectionReference!
    var listRef: CollectionReference!
    var wannaRef: CollectionReference!
    var postDocuments: [QueryDocumentSnapshot] = []
    
    init() {
        
        userRef = Firestore.firestore().collection("user").document(userID!)
        shareRef = Firestore.firestore().collection("share")
        musicRef = userRef.collection("musicList")
        listRef = userRef.collection("lists")
        wannaRef = userRef.collection("wannaList")
        getUserName()
    }
    
    //userNameを取得
    func getUserName() {
        userRef.getDocument() { (document, err) in
            if let _err = err {
                print("Error getting userName: \(_err)")
            }else{
                UserDefaults.standard.set(document?.data()!["name"] as! String, forKey: "userName")
            }
        }
    }
    
    func createGoodList() {
        userRef.setData([
            "goodList": []
        ]) {err in
            if let _err = err {
                print("Error adding goodList: \(_err)")
            }
            
        }
    }
    
    //musicListを取得
    func getMusic(completionHandler: @escaping ([MusicList]) -> Void) {
        
        musicRef.getDocuments { (collection, err) in
            if let _err = err {
                print("error getting music: \(_err)")
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
    
    //listsを取得
    func getlist(completionHandler: @escaping (Any) -> Void) {
        userRef.getDocument() { (document, err) in
            if let _document = document, _document.exists{
                Manager.shared.listOrder = _document.data()!["listOrder"] as? [String] ?? []
                print("getting listOrder")
                
            } else {
                print("Error getting listOrder")
            }
            
            self.listRef.getDocuments() { (collection, err) in
                if let _err = err {
                    print("error getting list: \(_err)")
                    
                }else{
                    print("getting list")
                    Manager.shared.lists = []
                    for document in collection!.documents {
                        do{
                            Manager.shared.lists.append(try document.data(as: Lists.self))
                        }catch{
                            print(error)
                        }
                    }
                    var preList: [Lists] = []
                    for i in Manager.shared.listOrder {
                        preList.append(Manager.shared.lists.first(where: {$0.id!.contains(i)})!)
                    }
                    Manager.shared.lists = Material.shared.initialListData
                    Manager.shared.lists += preList
                    completionHandler(true)
                }
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
                    let name = document["musicName"] as! String
                    let artist = document["artistName"] as! String
                    let image = document["musicImage"] as! Data
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
    
    func getGoodList() {
        userRef.getDocument { (document, err) in
            if let _err = err {
                print("Error getting goodList: \(_err)")
            }else{
                if document?.data()!["goodList"] != nil {
                    Manager.shared.goodList = document?.data()!["goodList"] as! [String]
                }
            }
        }
    }
    
    func searchPost(first: Bool, music: String, artist: String, category: [String], completionHandler: @escaping ([Post]) -> Void) {
        
        if first {
            if music != "" {
                if artist != "" {
                    if category != [] {//all
                        shareRef
                            .whereField("musicName", isEqualTo: music)
                            .whereField("artistName", isEqualTo: artist)
                            .whereField("category", arrayContainsAny: category)
                            .order(by: "musicName")
                            .order(by: "artistName")
                            .order(by: "time", descending: true)
                            .limit(to: 10)
                            .getDocuments { (collection, err) in
                                var list: [Post] = []
                                if let _err = err {
                                    print("Error getting post: \(String(describing: _err))")
                                    completionHandler([])
                                }else{
                                    
                                    for document in collection!.documents {
                                        do{
                                            list.append(try document.data(as: Post.self))
                                        }catch{
                                            print(error)
                                        }
                                        
                                    }
                                    self.postDocuments = collection!.documents
                                    completionHandler(list)
                                }
                            }
                    } else {//music,artist
                        shareRef
                            .whereField("musicName", isEqualTo: music)
                            .whereField("artistName", isEqualTo: artist)
                            .order(by: "musicName")
                            .order(by: "artistName")
                            .order(by: "time", descending: true)
                            .limit(to: 10)
                            .getDocuments { (collection, err) in
                                var list: [Post] = []
                                if let _err = err {
                                    print("Error getting post: \(String(describing: _err))")
                                    completionHandler([])
                                }else{
                                    
                                    for document in collection!.documents {
                                        do{
                                            list.append(try document.data(as: Post.self))
                                        }catch{
                                            print(error)
                                        }
                                        
                                    }
                                    self.postDocuments = collection!.documents
                                    completionHandler(list)
                                }
                            }
                    }
                } else if category != [] {//music, category
                    shareRef
                        .whereField("musicName", isEqualTo: music)
                        .whereField("category", arrayContainsAny: category)
                        .order(by: "musicName")
                        .order(by: "time", descending: true)
                        .limit(to: 10)
                        .getDocuments { (collection, err) in
                            var list: [Post] = []
                            if let _err = err {
                                print("Error getting post: \(String(describing: _err))")
                                completionHandler([])
                            }else{
                                
                                for document in collection!.documents {
                                    do{
                                        list.append(try document.data(as: Post.self))
                                    }catch{
                                        print(error)
                                    }
                                    
                                }
                                self.postDocuments = collection!.documents
                                completionHandler(list)
                            }
                        }
                    
                } else {//music
                    shareRef
                        .whereField("musicName", isEqualTo: music)
                        .order(by: "musicName")
                        .order(by: "time", descending: true)
                        .limit(to: 10)
                        .getDocuments { (collection, err) in
                            var list: [Post] = []
                            if let _err = err {
                                print("Error getting post: \(String(describing: _err))")
                                completionHandler([])
                            }else{
                                
                                for document in collection!.documents {
                                    do{
                                        list.append(try document.data(as: Post.self))
                                    }catch{
                                        print(error)
                                    }
                                
                                }
                                self.postDocuments = collection!.documents
                                completionHandler(list)
                            }
                        }
                }
            } else {
                if artist != "" {
                    if category != [] {//artist,category
                        shareRef
                            .whereField("artistName", isEqualTo: artist)
                            .whereField("category", arrayContainsAny: category)
                            .order(by: "artistName")
                            .order(by: "time", descending: true)
                            .limit(to: 10)
                            .getDocuments { (collection, err) in
                                var list: [Post] = []
                                if let _err = err {
                                    print("Error getting post: \(String(describing: _err))")
                                    completionHandler([])
                                }else{
                                    
                                    for document in collection!.documents {
                                        do{
                                            list.append(try document.data(as: Post.self))
                                        }catch{
                                            print(error)
                                        }
                                        
                                    }
                                    
                                    self.postDocuments = collection!.documents
                                    completionHandler(list)
                                    
                                    
                                }
                            }
                    } else {//artist
                        shareRef
                            .whereField("artistName", isEqualTo: artist)
                            .order(by: "artistName")
                            .order(by: "time", descending: true)
                            .limit(to: 10)
                            .getDocuments { (collection, err) in
                                var list: [Post] = []
                                if let _err = err {
                                    print("Error getting post: \(String(describing: _err))")
                                    completionHandler([])
                                }else{
                                    
                                    for document in collection!.documents {
                                        do{
                                            list.append(try document.data(as: Post.self))
                                        }catch{
                                            print(error)
                                        }
                                        
                                    }
                                    
                                    self.postDocuments = collection!.documents
                                    completionHandler(list)
                                    
                                    
                                }
                            }
                    }
                } else if category != [] {//category
                    shareRef
                        .whereField("category", arrayContainsAny: category)
                        .order(by: "time", descending: true)
                        .limit(to: 10)
                        .getDocuments { (collection, err) in
                            var list: [Post] = []
                            if let _err = err {
                                print("Error getting post: \(String(describing: _err))")
                                completionHandler([])
                            }else{
                                
                                for document in collection!.documents {
                                    do{
                                        list.append(try document.data(as: Post.self))
                                    }catch{
                                        print(error)
                                    }
                                    
                                }
                                
                                self.postDocuments = collection!.documents
                                completionHandler(list)
                                
                                
                            }
                        }
                } else {//no
                    shareRef
                        .order(by: "time", descending: true)
                        .limit(to: 10)
                        .getDocuments { (collection, err) in
                        var list: [Post] = []
                        if let _err = err {
                            print("Error getting post: \(String(describing: _err))")
                            completionHandler([])
                        }else{
                            for document in collection!.documents {
                                do{
                                    list.append(try document.data(as: Post.self))
                                }catch{
                                    print(error)
                                }
                                
                            }
                            
                            self.postDocuments = collection!.documents
                            completionHandler(list)
                        }
                    }
                }
            }
            
        } else {
            guard let _lastDocument = postDocuments.last else {
                return
            }
            if music != "" {
                if artist != "" {
                    if category != [] { //all
                        shareRef
                            .whereField("music", isEqualTo: music)
                            .whereField("artist", isEqualTo: artist)
                            .whereField("category", arrayContainsAny: category)
                            .order(by: "music")
                            .order(by: "artist")
                            .order(by: "category")
                            .order(by: "time", descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: 10)
                            .getDocuments { (collection, err) in
                            var list: [Post] = []
                            if let _err = err{
                                print("Error getting post:\(_err)")
                                completionHandler([])
                            }else{
                                for document in collection!.documents {
                                    
                                    do{
                                        list.append(try document.data(as: Post.self))
                                    }catch{
                                        print(error)
                                    }
                                }
                                self.postDocuments = collection!.documents
                                completionHandler(list)
                            }
                        }
                    } else { //music,artist
                        shareRef
                            .whereField("musicName", isEqualTo: music)
                            .whereField("artistName", isEqualTo: artist)
                            .order(by: "musicName")
                            .order(by: "artistName")
                            .order(by: "time", descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: 10)
                            .getDocuments { (collection, err) in
                            var list: [Post] = []
                            if let _err = err{
                                print("Error getting post:\(_err)")
                                completionHandler([])
                            }else{
                                for document in collection!.documents {
                                    
                                    do{
                                        list.append(try document.data(as: Post.self))
                                    }catch{
                                        print(error)
                                    }
                                }
                                self.postDocuments = collection!.documents
                                completionHandler(list)
                            }
                        }
                    }
                } else {
                    if category != [] { //music,category
                        shareRef
                            .whereField("musicName", isEqualTo: music)
                            .whereField("category", arrayContainsAny: category)
                            .order(by: "musicName")
                            .order(by: "time", descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: 10)
                            .getDocuments { (collection, err) in
                            var list: [Post] = []
                            if let _err = err{
                                print("Error getting post:\(_err)")
                                completionHandler([])
                            }else{
                                for document in collection!.documents {
                                    
                                    do{
                                        list.append(try document.data(as: Post.self))
                                    }catch{
                                        print(error)
                                    }
                                }
                                self.postDocuments = collection!.documents
                                completionHandler(list)
                            }
                        }
                    } else { //music
                        shareRef
                            .whereField("musicName", isEqualTo: music)
                            .order(by: "musicName")
                            .order(by: "time", descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: 10)
                            .getDocuments { (collection, err) in
                            var list: [Post] = []
                            if let _err = err{
                                print("Error getting post:\(_err)")
                                completionHandler([])
                            }else{
                                for document in collection!.documents {
                                    
                                    do{
                                        list.append(try document.data(as: Post.self))
                                    }catch{
                                        print(error)
                                    }
                                }
                                self.postDocuments = collection!.documents
                                completionHandler(list)
                            }
                        }
                    }
                }
            } else {
                if artist != "" {
                    if category != [] { //artist,category
                        shareRef
                            .whereField("artistName", isEqualTo: artist)
                            .whereField("category", arrayContainsAny: category)
                            .order(by: "artistName")
                            .order(by: "time", descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: 10)
                            .getDocuments { (collection, err) in
                            var list: [Post] = []
                            if let _err = err{
                                print("Error getting post:\(_err)")
                                completionHandler([])
                            }else{
                                for document in collection!.documents {
                                    
                                    do{
                                        list.append(try document.data(as: Post.self))
                                    }catch{
                                        print(error)
                                    }
                                }
                                self.postDocuments = collection!.documents
                                completionHandler(list)
                            }
                        }
                    } else { //artist
                        shareRef
                            .whereField("artistName", isEqualTo: artist)
                            .order(by: "artistName")
                            .order(by: "time", descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: 10)
                            .getDocuments { (collection, err) in
                            var list: [Post] = []
                            if let _err = err{
                                print("Error getting post:\(_err)")
                                completionHandler([])
                            }else{
                                for document in collection!.documents {
                                    
                                    do{
                                        list.append(try document.data(as: Post.self))
                                    }catch{
                                        print(error)
                                    }
                                }
                                self.postDocuments = collection!.documents
                                completionHandler(list)
                            }
                        }
                    }
                } else {
                    if category != [] { //category
                        shareRef
                            .whereField("category", arrayContainsAny: category)
                            .order(by: "time", descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: 10)
                            .getDocuments { (collection, err) in
                            var list: [Post] = []
                            if let _err = err{
                                print("Error getting post:\(_err)")
                                completionHandler([])
                            }else{
                                for document in collection!.documents {
                                    
                                    do{
                                        list.append(try document.data(as: Post.self))
                                    }catch{
                                        print(error)
                                    }
                                }
                                self.postDocuments = collection!.documents
                                completionHandler(list)
                            }
                        }
                    } else { //no
                        shareRef.order(by: "time", descending: true).start(afterDocument: _lastDocument).limit(to: 10).getDocuments { (collection, err) in
                            var list: [Post] = []
                            if let _err = err{
                                print("Error getting post:\(_err)")
                                completionHandler([])
                            }else{
                                for document in collection!.documents {
                                    
                                    do{
                                        list.append(try document.data(as: Post.self))
                                    }catch{
                                        print(error)
                                    }
                                }
                                self.postDocuments = collection!.documents
                                completionHandler(list)
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    //musicListに追加
    func addMusic(musicName: String, artistName: String, musicImage: Data, time: String, score: Double, key: Int, model: String, comment: String, completionHandler: @escaping (Any) -> Void) {
        let detailData = ["time": time, "score": score, "key": key, "model": model, "comment": comment] as [String : Any]
        musicRef.addDocument(data: [
            "musicName": musicName,
            "artistName": artistName,
            "musicImage": musicImage,
            "favorite": false,
            "lists": [],
            "data": [detailData]
        ]) { err in
            if let _err = err {
                print("Error adding music: \(_err)")
            }else{
                print("music added")
                Manager.shared.musicList.append(MusicList(musicName: musicName, artistName: artistName, musicImage: musicImage, favorite: false, lists: [], data: [MusicData(time: time, score: score, key: key, model: model, comment: comment)]))
                
                completionHandler(true)
            }
        }
    }
    
    //musicDataを追加
    func addMusicDetail(musicID: String, time: String, score: Double, key: Int, model: String, comment: String) {
        let indexPath = Manager.shared.musicList.firstIndex(where: {$0.id == musicID})!
        let d = [
            "time": time,
            "score": score,
            "key": key,
            "model": model,
            "comment": comment
        ] as [String : Any]
        musicRef.document(musicID).updateData([
            "data": FieldValue.arrayUnion([d])
        ]) {err in
            if let _err = err {
                print("Error adding detail \(_err)")
            }else{
                print("detail successfully added")
                
            }
        }
        Manager.shared.musicList[indexPath].data.append(MusicData(time: time, score: score, key: key, model: model, comment: comment))
    }
    
    //listを追加
    func addList(listName: String, listImage: Data) {
        let ref = listRef.addDocument(data: [
            "listName": listName,
            "listImage": listImage
        ]){err in
            if let _err = err {
                print("Error adding list: \(_err)")
            }else{
                print("list successfully added")
                
            }
            
        }
        userRef.updateData([
            "listOrder": FieldValue.arrayUnion([ref.documentID])
        ])
        Manager.shared.lists.append(Lists(listName: listName, listImage: listImage, id: ref.documentID))
        Manager.shared.listOrder.append(ref.documentID)
    }
    
    //wannaListを追加
    func addWanna(musicName: String, artistName: String, musicImage: Data) {
        wannaRef.addDocument(data: [
            "musicName": musicName,
            "artistName": artistName,
            "musicImage": musicImage
        ]) {err in
            if let _err = err {
                print("Error adding music: \(_err)")
            }else{
                print("music successfully added")
            }
        }
    }
    
    //listに追加
    func addMusicToList(musicID: String, listID: String) {
        let indexPath = Manager.shared.musicList.firstIndex(where: {$0.id == musicID})!
        musicRef.document(musicID).updateData([
            "lists": FieldValue.arrayUnion([listID])
        ]) { err in
            if let _err = err {
                print("Error adding music \(_err)")
            }else{
                print("musicAdded")
                Manager.shared.musicList[indexPath].lists.append(listID)
            }
        }
    }
    
    func post(musicName: String, artistName: String, musicImage: Data, content: String, category: [String]) {
        let time = Timestamp(date: Date())
        shareRef.addDocument(data: [
            "musicName": musicName,
            "artistName": artistName,
            "musicImage": musicImage,
            "content": content,
            "userName": UserDefaults.standard.string(forKey: "userName")!,
            "time": time,
            "goodNumber": 0,
            "goodSelf": false,
            "category": category])
    }
    
    
    
    
    //musicListを削除
    func deleteMusic(id: String, completionHandler: @escaping (Any) -> Void) {
        musicRef.document(id).delete() { err in
            if let _err = err {
                print("error deleting music: \(_err)")
            }else{
                print("music successfully deleted")
                Manager.shared.musicList.removeAll(where: {$0.id == id})
                completionHandler(true)
            }
            
        }
    }
    
    //musicDataを削除
    func deleteMusicDetail(musicID: String, data: MusicData, completionHandler: @escaping (Any) -> Void) {
        let indexPath = Manager.shared.musicList.firstIndex(where: {$0.id == musicID})!
        let d = ["comment": data.comment,
                 "key": data.key,
                 "model": data.model,
                 "score": data.score,
                 "time": data.time] as [String : Any]
        musicRef.document(musicID).updateData([
            "data": FieldValue.arrayRemove([d])
        ]){err in
            if let _err = err {
                print("Error deleting detail: \(_err)")
            }else{
                print("detail successfully deleted")
                
                Manager.shared.musicList[indexPath].data.removeAll(where: {$0.time == data.time})
                completionHandler(true)
            }
        }
    }
    
    //listを削除
    func deleteList(indexPath: IndexPath, completionHandler: @escaping (Any) -> Void) {
        let listID = Manager.shared.lists[indexPath.row].id!
        listRef.document(listID).delete() { err in
            if let _err = err {
                print("error removing music: \(_err)")
            }else{
                print("music successfully removed")
                self.userRef.updateData([
                    "listOrder": FieldValue.arrayRemove([listID])
                ]){err in
                    if let _err = err {
                        print("Error deleting music order: \(_err)")
                    }else{
                        print("music order successfully deleted")
                        Manager.shared.lists.remove(at: indexPath.row)
                        
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
    
    //listからmusicを削除
    func deleteMusicFromList(selectedID: String, listID: String, completionHandler: @escaping (Any) -> Void) {
        musicRef.document(selectedID).updateData([
            "lists": FieldValue.arrayRemove([listID])
        ]) { err in
            if let _err = err {
                print("Error updating favorite: \(_err)")
            } else {
                print("favorite successfully updated")
                
                let num = Manager.shared.musicList.firstIndex(where: {$0.id!.contains(selectedID)})
                Manager.shared.musicList.remove(at: num!)
                
                completionHandler(true)
            }
        }
    }
    
    //favoriteを更新
    func favoriteUpdate(id: String, favorite: Bool, completionHandler: @escaping (Any) -> Void) {
        if favorite {
            musicRef.document(id).updateData([
                "favorite": false
            ]){ err in
                if let _err = err {
                    print("Error updating favorite: \(err)")
                } else {
                    print("favorite successfully updated")
                    
                    let num = Manager.shared.musicList.firstIndex(where: {$0.id!.contains(id)})
                    Manager.shared.musicList[num!].favorite = false
                    
                    completionHandler(true)
                }
            }
        } else {
            musicRef.document(id).updateData([
                "favorite": true
            ]){ err in
                if let _err = err {
                    print("Error updating favorite: \(_err)")
                } else {
                    print("favorite successfully updated")
                    
                    let num = Manager.shared.musicList.firstIndex(where: {$0.id!.contains(id)})
                    Manager.shared.musicList[num!].favorite = true
                    
                    completionHandler(true)
                }
            }
        }
    }
    
    //listOrderを更新
    func listOrderUpdate(listOrder: [String]) {
        userRef.updateData([
            "listOrder": listOrder
        ]) {err in
            if let _err = err {
                print("Error updating list order: \(_err)")
            }else{
                print("list order successfully updated")
                Manager.shared.listOrder = listOrder
            }
        }
    }
    
    func goodUpdate(id: String, good: Bool) {
        if  good {
            let num = Manager.shared.goodList.firstIndex(of: id)!
            Manager.shared.goodList.remove(at: num)
            userRef.updateData([
                "goodList": FieldValue.arrayRemove([id])
                
            ])
            shareRef.document(id).updateData([
                "goodNumber": FieldValue.increment(Double(-1))
            ]){ err in
                if let _err = err {
                    print("Error updating good: \(_err)")
                }else{
                    
                }
            }
        }else{
            Manager.shared.goodList.append(id)
            userRef.updateData([
                "goodList": FieldValue.arrayUnion([id])
            ])
            shareRef.document(id).updateData([
                "goodNumber": FieldValue.increment(Double(1))
            ]){ err in
                if let _err = err {
                    print("Error updating good: \(_err)")
                }else{
                    
                }
            }
        }
    }
    
}
