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
    var userID: String!
    var database = Firestore.firestore()
    var userRef: DocumentReference!
    var shareRef: CollectionReference!
    var musicRef: CollectionReference!
    var listRef: CollectionReference!
    var wannaRef: CollectionReference!
    var postDocuments: [QueryDocumentSnapshot] = []
    var myInformation: User!
    
    let emptyUser = User(name: "", goodList: [], listOrder: [], followLimit: true, showAll: false, follow: [], follower: [], id: "")
    let getLimit = 6
    
    init() {
        UserDefaultsKey.userID.set(value: "imiWSXSa9tNBwNZvCWdjJ0Tw0Gr2")
        userID = UserDefaultsKey.userID.get()
        userRef = database.collection("user").document(userID!)
        shareRef = database.collection("share")
        musicRef = userRef.collection("musicList")
        listRef = userRef.collection("lists")
        wannaRef = userRef.collection("wannaList")
        getUserInformation(id: userID) { user in
            self.myInformation = user
        }
    }
    
    //user情報を取得
    func getUserInformation(id: String) async -> User {
        
        database.collection("user").document(id).getDocument { (document, err) in
            var user: User!
            if let _err = err {
                print("error getting music: \(_err)")
                return(self.emptyUser)
            }else{
                print(9999999, document)
                do{
                    user = try document?.data(as: User.self)
                        print(111111, user)
                }catch{
                    print(error)
                    print(878787878)
                    user = self.emptyUser
                }
                
                return(user)
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
    func getList(completionHandler: @escaping (Any) -> Void) {
        userRef.getDocument() { (document, err) in
            if let _document = document, _document.exists{
                Manager.shared.listOrder = _document.data()![UserRef.listOrder.rawValue] as? [String] ?? []
                print("getting listOrder")
                
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
                        print(Manager.shared.lists)
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
    
    func getGoodList() {
        userRef.getDocument { (document, err) in
            if let _err = err {
                print("Error getting goodList: \(_err)")
            }else{
                if document?.data()![UserRef.goodList.rawValue] != nil {
                    Manager.shared.goodList = document?.data()![UserRef.goodList.rawValue] as! [String]
                }
            }
        }
    }
    
    func getPost(first: Bool, music: String, artist: String, category: [String], completionHandler: @escaping ([Post]) -> Void) {
        
        if first {
            if music != "" {
                if artist != "" {
                    if category != [] {//all
                        shareRef
                            .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                            .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                            .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                            .order(by: ShareRef.musicName.rawValue)
                            .order(by: ShareRef.artistName.rawValue)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: getLimit)
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
                            .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                            .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                            .order(by: ShareRef.musicName.rawValue)
                            .order(by: ShareRef.artistName.rawValue)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: getLimit)
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
                        .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                        .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                        .order(by: ShareRef.musicName.rawValue)
                        .order(by: ShareRef.time.rawValue, descending: true)
                        .limit(to: getLimit)
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
                        .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                        .order(by: ShareRef.musicName.rawValue)
                        .order(by: ShareRef.time.rawValue, descending: true)
                        .limit(to: getLimit)
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
                            .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                            .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                            .order(by: ShareRef.artistName.rawValue)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: getLimit)
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
                            .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                            .order(by: ShareRef.artistName.rawValue)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: getLimit)
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
                        .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                        .order(by: ShareRef.time.rawValue, descending: true)
                        .limit(to: getLimit)
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
                        .order(by: ShareRef.time.rawValue, descending: true)
                        .limit(to: getLimit)
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
                            .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                            .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                            .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                            .order(by: ShareRef.musicName.rawValue)
                            .order(by: ShareRef.artistName.rawValue)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: getLimit)
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
                            .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                            .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                            .order(by: ShareRef.musicName.rawValue)
                            .order(by: ShareRef.artistName.rawValue)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: getLimit)
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
                            .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                            .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                            .order(by: ShareRef.musicName.rawValue)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: getLimit)
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
                            .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                            .order(by: ShareRef.musicName.rawValue)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: getLimit)
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
                            .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                            .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                            .order(by: ShareRef.artistName.rawValue)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: getLimit)
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
                            .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                            .order(by: ShareRef.artistName.rawValue)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: getLimit)
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
                            .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .start(afterDocument: _lastDocument)
                            .limit(to: getLimit)
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
                        shareRef.order(by: ShareRef.time.rawValue, descending: true).start(afterDocument: _lastDocument).limit(to: getLimit).getDocuments { (collection, err) in
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
    
    func searchPost(first: Bool, music: String, artist: String, category: [String], completionHandler: @escaping ([Post]) -> Void) {
        
        getPost(first: first, music: music, artist: artist, category: category) { list in
            var a: [Post] = []
            
            await self.selectPost(post: list) { postOK in
                
                
            }
        }
    }
    
    func selectPost(post: [Post], completionHandler: @escaping ([Post]) -> Void) async {
        var list: [Post] = []
        for await p in post {
            
            var _post = p
            _post.userID = await getUserInformation(id: p.userID).name
            var show = await getUserInformation(id: p.userID).showAll
            if self.myInformation.follow.first(where: {$0 == p.userID}) != nil && show {
                show = true
            } else if p.userID == self.userID && show {
                show = true
            }
            
            if show {
                list.append(p)
            }
            
        }
        completionHandler(list)
    }
    
    func searchUserName(string: String, completionHandler: @escaping ([User]) -> Void) {
        var list: [User] = []
        database.collection("user")
            .whereField(UserRef.name.rawValue, isEqualTo: string)
            .getDocuments { (collection, err) in
                if let _err = err {
                    print("Error getting user: \(_err)")
                } else {
                    for document in collection!.documents {
                        do {
                            list.append(try document.data(as: User.self))
                        } catch {
                            print(error)
                        }
                    }
                }
                completionHandler(list)
            }
    }
    
    //musicListに追加
    func addMusic(musicName: String, artistName: String, musicImage: Data, time: String, score: Double, key: Int, model: String, comment: String, completionHandler: @escaping (Any) -> Void) {
        let detailData = [UserRef.MusicListRef.MusicDataRef.time.rawValue: time,
                          UserRef.MusicListRef.MusicDataRef.score.rawValue: score,
                          UserRef.MusicListRef.MusicDataRef.key.rawValue: key,
                          UserRef.MusicListRef.MusicDataRef.model.rawValue: model,
                          UserRef.MusicListRef.MusicDataRef.comment.rawValue: comment] as [String : Any]
        musicRef.addDocument(data: [
            UserRef.MusicListRef.musicName.rawValue: musicName,
            UserRef.MusicListRef.artistName.rawValue: artistName,
            UserRef.MusicListRef.musicImage.rawValue: musicImage,
            UserRef.MusicListRef.favorite.rawValue: false,
            UserRef.MusicListRef.lists.rawValue: [],
            UserRef.MusicListRef.data.rawValue: [detailData]
        ]) { err in
            if let _err = err {
                print("Error adding music: \(_err)")
            }else{
                print("music added")
                Manager.shared.musicList.append(MusicList(musicName: musicName,
                                                          artistName: artistName,
                                                          musicImage: musicImage,
                                                          favorite: false,
                                                          lists: [],
                                                          data: [MusicData(time: time,
                                                                           score: score,
                                                                           key: key,
                                                                           model: model,
                                                                           comment: comment)],
                                                          id: self.musicRef.document().documentID))
                
                completionHandler(true)
            }
        }
    }
    
    //musicDataを追加
    func addMusicDetail(musicID: String, time: String, score: Double, key: Int, model: String, comment: String) {
        let indexPath = Manager.shared.musicList.firstIndex(where: {$0.id == musicID})!
        let d = [
            UserRef.MusicListRef.MusicDataRef.time.rawValue: time,
            UserRef.MusicListRef.MusicDataRef.score.rawValue: score,
            UserRef.MusicListRef.MusicDataRef.key.rawValue: key,
            UserRef.MusicListRef.MusicDataRef.model.rawValue: model,
            UserRef.MusicListRef.MusicDataRef.comment.rawValue: comment
        ] as [String : Any]
        musicRef.document(musicID).updateData([
            UserRef.MusicListRef.data.rawValue: FieldValue.arrayUnion([d])
        ]) {err in
            if let _err = err {
                print("Error adding detail \(_err)")
            }else{
                print("detail successfully added")
                
            }
        }
        Manager.shared.musicList[indexPath].data.append(MusicData(time: time,
                                                                  score: score,
                                                                  key: key,
                                                                  model: model,
                                                                  comment: comment))
    }
    
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
        Manager.shared.lists.append(Lists(listName: listName, listImage: listImage, id: ref.documentID))
        Manager.shared.listOrder.append(ref.documentID)
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
    
    //listに追加
    func addMusicToList(musicID: String, listID: String) {
        let indexPath = Manager.shared.musicList.firstIndex(where: {$0.id == musicID})!
        musicRef.document(musicID).updateData([
            UserRef.MusicListRef.lists.rawValue: FieldValue.arrayUnion([listID])
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
            ShareRef.musicName.rawValue: musicName,
            ShareRef.artistName.rawValue: artistName,
            ShareRef.musicImage.rawValue: musicImage,
            ShareRef.content.rawValue: content,
            ShareRef.userName.rawValue: UserDefaultsKey.userID.get()!,
            ShareRef.time.rawValue: time,
            ShareRef.goodNumber.rawValue: 0,
            ShareRef.category.rawValue: category])
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
        let d = [UserRef.MusicListRef.MusicDataRef.comment.rawValue: data.comment,
                 UserRef.MusicListRef.MusicDataRef.key.rawValue: data.key,
                 UserRef.MusicListRef.MusicDataRef.model.rawValue: data.model,
                 UserRef.MusicListRef.MusicDataRef.score.rawValue: data.score,
                 UserRef.MusicListRef.MusicDataRef.time.rawValue: data.time] as [String : Any]
        musicRef.document(musicID).updateData([
            UserRef.MusicListRef.data.rawValue: FieldValue.arrayRemove([d])
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
                    UserRef.listOrder.rawValue: FieldValue.arrayRemove([listID])
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
            UserRef.MusicListRef.lists.rawValue: FieldValue.arrayRemove([listID])
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
                UserRef.MusicListRef.favorite.rawValue: false
            ]){ err in
                if let _err = err {
                    print("Error updating favorite: \(_err)")
                } else {
                    print("favorite successfully updated")
                    
                    let num = Manager.shared.musicList.firstIndex(where: {$0.id!.contains(id)})
                    Manager.shared.musicList[num!].favorite = false
                    
                    completionHandler(true)
                }
            }
        } else {
            musicRef.document(id).updateData([
                UserRef.MusicListRef.favorite.rawValue: true
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
            UserRef.listOrder.rawValue: listOrder
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
                UserRef.goodList.rawValue: FieldValue.arrayRemove([id])
                
            ])
            shareRef.document(id).updateData([
                ShareRef.goodNumber.rawValue: FieldValue.increment(Double(-1))
            ]){ err in
                if let _err = err {
                    print("Error updating good: \(_err)")
                }else{
                    
                }
            }
        }else{
            Manager.shared.goodList.append(id)
            userRef.updateData([
                UserRef.goodList.rawValue: FieldValue.arrayUnion([id])
            ])
            shareRef.document(id).updateData([
                ShareRef.goodNumber.rawValue: FieldValue.increment(Double(1))
            ]){ err in
                if let _err = err {
                    print("Error updating good: \(_err)")
                }
            }
        }
    }
    
    func updateUserName(rename: String) {
        userRef.updateData([
            UserRef.name.rawValue: rename
        ]) { err in
            if let _err = err {
                print("Error updating user name: \(_err)")
            }
        }
        
    }
    
    
    enum UserRef: String {
        case goodList = "goodList"
        case listOrder = "listOrder"
        case name = "name"
        case showAll = "showAll"
        case followLimit = "followLimit"
        case follow = "follow"
        case follower = "follower"
        
        enum MusicListRef: String {
            case musicName = "musicName"
            case artistName = "artistName"
            case musicImage = "musicImage"
            case favorite = "favorite"
            case lists = "lists"
            case data = "data"
            
            enum MusicDataRef: String {
                case time = "time"
                case score = "score"
                case key = "key"
                case model = "model"
                case comment = "comment"
            }
        }
        
        enum ListsRef: String {
            case listImage = "listImage"
            case listName = "listName"
        }
        
        enum WannaListRef: String {
            case musicName = "musicName"
            case artistName = "artistName"
            case musicImage = "musicImage"
        }
    }
    
    enum ShareRef: String {
        case time = "time"
        case musicName = "musicName"
        case artistName = "artistName"
        case musicImage = "musicImage"
        case userName = "userName"
        case content = "content"
        case goodNumber = "goodNumber"
        case category = "category"
    }
}
//taiga da-isukidayo-
