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
import Combine

let firebase = FirebaseAPI.shared

class FirebaseAPI: ObservableObject {
    
    static let shared = FirebaseAPI()
    var userID: String!
    var db = Firestore.firestore()
    var userRef: DocumentReference!
    var shareRef: CollectionReference!
    var musicRef: CollectionReference!
    var listRef: CollectionReference!
    var wannaRef: CollectionReference!
    var postDocuments: [QueryDocumentSnapshot] = []
    var userPostDocuments: [QueryDocumentSnapshot] = []
    
    let emptyUser = User(name: "", goodList: [], listOrder: [], showAll: false, follow: [], follower: [], request: [], notice: [])
    let getLimit = 6
    
    func setFirebase(userID: String) {
        self.userID = userID
        userRef = db.collection("user").document(userID)
        shareRef = db.collection("share")
        musicRef = userRef.collection("musicList")
        listRef = userRef.collection("lists")
        wannaRef = userRef.collection("wannaList")
        
    }
    
    //user情報を取得
    func getUserInformation(id: String) async -> User? {
        await withCheckedContinuation { continuation in
            db.collection("user").document(id).getDocument { (document, err) in
                if let _err = err {
                    print("Error getting user information: \(_err)")
                    continuation.resume(returning: nil)
                } else {
                    if let document, document.exists {
                        do {
                            let user = try document.data(as: User.self)
                            continuation.resume(returning: user)
                        } catch {
                            continuation.resume(returning: nil)
                            print("Error getting user information: \(err)")
                        }
                    } else {
                        continuation.resume(returning: nil)
                        print("Error getting user information: \(err)")
                    }
                }
            }
        }
    }
    
    //musicListを取得
    func getMusic(completionHandler: @escaping ([MusicList]) -> Void) {
        
        musicRef.getDocuments { (collection, err) in
            if let _err = err {
                print("Error getting music: \(_err)")
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
    
    //他のユーザーの記録した曲を追加する
    func getAnotherMusic(id: String) async -> [MusicList] {
        await withCheckedContinuation { continuation in
            db.collection("user").document(id).collection("musicList").getDocuments { (collection, err) in
                if let _err = err {
                    print("Error getting another music: \(_err)")
                    continuation.resume(returning: [])
                } else {
                    var list: [MusicList] = []
                    for document in collection!.documents {
                        do {
                            list.append(try document.data(as: MusicList.self))
                        } catch {
                            print(error)
                        }
                    }
                    continuation.resume(returning: list)
                }
            }
        }
    }
    
    //listsを取得
    func getList(completionHandler: @escaping (Any) -> Void) {
        userRef.getDocument() { (document, err) in
            if let _document = document, _document.exists{
                do {
                    let user = try _document.data(as: User.self)
                    Manager.shared.user.listOrder = user.listOrder
                } catch {
                    return
                }
                
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
                        for i in Manager.shared.user.listOrder {
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
    
    //検索条件に応じて投稿を取得する
    func getPost(first: Bool, music: String, artist: String, category: [String]) async throws -> [Post]{
        return await withCheckedContinuation { continuation in
            var list: [Post] = []
            if first {
                if music != "" {
                    if artist != "" {
                        if category != [] {//all
                            self.shareRef
                                .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    
                                    if let _err = err {
                                        print("Error getting post: \(String(describing: _err))")
                                        continuation.resume(throwing: _err as! Never)
                                        
                                    }else{
                                        for document in collection!.documents {
                                            do{
                                                list.append(try document.data(as: Post.self))
                                            }catch{
                                                print(error)
                                            }
                                            
                                        }
                                        self.postDocuments = collection!.documents
                                        continuation.resume(returning: list)
                                    }
                                    
                                }
                        } else {//music,artist
                            self.shareRef
                                .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    
                                    if let _err = err {
                                        print("Error getting post: \(String(describing: _err))")
                                        continuation.resume(throwing: _err as! Never)
                                    }else{
                                        
                                        for document in collection!.documents {
                                            do{
                                                list.append(try document.data(as: Post.self))
                                            }catch{
                                                print(error)
                                            }
                                            
                                        }
                                        self.postDocuments = collection!.documents
                                        continuation.resume(returning: list)
                                    }
                                }
                        }
                    } else if category != [] {//music, category
                        self.shareRef
                            .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                            .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: self.getLimit)
                            .getDocuments { (collection, err) in
                                if let _err = err {
                                    print("Error getting post: \(String(describing: _err))")
                                    continuation.resume(throwing: _err as! Never)
                                }else{
                                    
                                    for document in collection!.documents {
                                        do{
                                            list.append(try document.data(as: Post.self))
                                        }catch{
                                            print(error)
                                        }
                                        
                                    }
                                    self.postDocuments = collection!.documents
                                    continuation.resume(returning: list)
                                }
                            }
                        
                    } else {//music
                        self.shareRef
                            .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: self.getLimit)
                            .getDocuments { (collection, err) in
                                if let _err = err {
                                    print("Error getting post: \(String(describing: _err))")
                                    continuation.resume(throwing: _err as! Never)
                                }else{
                                    
                                    for document in collection!.documents {
                                        do{
                                            list.append(try document.data(as: Post.self))
                                        }catch{
                                            print(error)
                                        }
                                        
                                    }
                                    self.postDocuments = collection!.documents
                                    continuation.resume(returning: list)
                                }
                            }
                    }
                } else {
                    if artist != "" {
                        if category != [] {//artist,category
                            self.shareRef
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let _err = err {
                                        print("Error getting post: \(String(describing: _err))")
                                        continuation.resume(throwing: _err as! Never)
                                    }else{
                                        
                                        for document in collection!.documents {
                                            do{
                                                list.append(try document.data(as: Post.self))
                                            }catch{
                                                print(error)
                                            }
                                            
                                        }
                                        
                                        self.postDocuments = collection!.documents
                                        continuation.resume(returning: list)
                                        
                                    }
                                }
                        } else {//artist
                            self.shareRef
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let _err = err {
                                        print("Error getting post: \(String(describing: _err))")
                                        continuation.resume(throwing: _err as! Never)
                                    }else{
                                        
                                        for document in collection!.documents {
                                            do{
                                                list.append(try document.data(as: Post.self))
                                            }catch{
                                                print(error)
                                            }
                                            
                                        }
                                        
                                        self.postDocuments = collection!.documents
                                        continuation.resume(returning: list)
                                        
                                    }
                                }
                        }
                    } else if category != [] {//category
                        self.shareRef
                            .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: self.getLimit)
                            .getDocuments { (collection, err) in
                                if let _err = err {
                                    print("Error getting post: \(String(describing: _err))")
                                    continuation.resume(throwing: _err as! Never)
                                }else{
                                    
                                    for document in collection!.documents {
                                        do{
                                            list.append(try document.data(as: Post.self))
                                        }catch{
                                            print(error)
                                        }
                                        
                                    }
                                    
                                    self.postDocuments = collection!.documents
                                    continuation.resume(returning: list)
                                }
                            }
                    } else {//no
                        self.shareRef
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: self.getLimit)
                            .getDocuments { (collection, err) in
                                if let _err = err {
                                    print("Error getting post: \(String(describing: _err))")
                                    continuation.resume(throwing: _err as! Never)
                                }else{
                                    for document in collection!.documents {
                                        do{
                                            list.append(try document.data(as: Post.self))
                                        }catch{
                                            print(error)
                                        }
                                        
                                    }
                                    
                                    self.postDocuments = collection!.documents
                                    continuation.resume(returning: list)
                                }
                            }
                    }
                }
                
            } else {
                guard let _lastDocument = self.postDocuments.last else {
                    continuation.resume(returning: [])
                    return
                }
                if music != "" {
                    if artist != "" {
                        if category != [] { //all
                            self.shareRef
                                .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let _err = err{
                                        print("Error getting post:\(_err)")
                                        continuation.resume(throwing: _err as! Never)
                                    }else{
                                        for document in collection!.documents {
                                            
                                            do{
                                                list.append(try document.data(as: Post.self))
                                            }catch{
                                                print(error)
                                            }
                                        }
                                        self.postDocuments = collection!.documents
                                        continuation.resume(returning: list)
                                    }
                                }
                        } else { //music,artist
                            self.shareRef
                                .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let _err = err{
                                        print("Error getting post:\(_err)")
                                        continuation.resume(throwing: _err as! Never)
                                    }else{
                                        for document in collection!.documents {
                                            
                                            do{
                                                list.append(try document.data(as: Post.self))
                                            }catch{
                                                print(error)
                                            }
                                        }
                                        self.postDocuments = collection!.documents
                                        continuation.resume(returning: list)
                                    }
                                }
                        }
                    } else {
                        if category != [] { //music,category
                            self.shareRef
                                .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let _err = err{
                                        print("Error getting post:\(_err)")
                                        continuation.resume(throwing: _err as! Never)
                                    }else{
                                        for document in collection!.documents {
                                            
                                            do{
                                                list.append(try document.data(as: Post.self))
                                            }catch{
                                                print(error)
                                            }
                                        }
                                        self.postDocuments = collection!.documents
                                        continuation.resume(returning: list)
                                    }
                                }
                        } else { //music
                            self.shareRef
                                .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let _err = err{
                                        print("Error getting post:\(_err)")
                                        continuation.resume(throwing: _err as! Never)
                                    }else{
                                        for document in collection!.documents {
                                            
                                            do{
                                                list.append(try document.data(as: Post.self))
                                            }catch{
                                                print(error)
                                            }
                                        }
                                        self.postDocuments = collection!.documents
                                        continuation.resume(returning: list)
                                    }
                                }
                        }
                    }
                } else {
                    if artist != "" {
                        if category != [] { //artist,category
                            self.shareRef
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let _err = err{
                                        print("Error getting post:\(_err)")
                                        continuation.resume(throwing: _err as! Never)
                                    }else{
                                        for document in collection!.documents {
                                            
                                            do{
                                                list.append(try document.data(as: Post.self))
                                            }catch{
                                                print(error)
                                            }
                                        }
                                        self.postDocuments = collection!.documents
                                        continuation.resume(returning: list)
                                        
                                    }
                                }
                        } else { //artist
                            self.shareRef
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let _err = err{
                                        print("Error getting post:\(_err)")
                                        continuation.resume(throwing: _err as! Never)
                                    }else{
                                        for document in collection!.documents {
                                            
                                            do{
                                                list.append(try document.data(as: Post.self))
                                            }catch{
                                                print(error)
                                            }
                                        }
                                        self.postDocuments = collection!.documents
                                        continuation.resume(returning: list)
                                    }
                                }
                        }
                    } else {
                        if category != [] { //category
                            self.shareRef
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let _err = err{
                                        print("Error getting post:\(_err)")
                                        continuation.resume(throwing: _err as! Never)
                                    }else{
                                        for document in collection!.documents {
                                            
                                            do{
                                                list.append(try document.data(as: Post.self))
                                            }catch{
                                                print(error)
                                            }
                                        }
                                        self.postDocuments = collection!.documents
                                        continuation.resume(returning: list)
                                    }
                                }
                        } else { //no
                            self.shareRef
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument).limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                if let _err = err{
                                    print("Error getting post:\(_err)")
                                    continuation.resume(throwing: _err as! Never)
                                }else{
                                    for document in collection!.documents {
                                        
                                        do{
                                            list.append(try document.data(as: Post.self))
                                        }catch{
                                            print(error)
                                        }
                                        
                                    }
                                    self.postDocuments = collection!.documents
                                    continuation.resume(returning: list)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //shareViewCtlで呼び出される
    func searchPost(first: Bool, music: String, artist: String, category: [String]) async -> [Post] {
        
        return await withTaskGroup(of: [Post].self) { group in
            group.addTask {
                var list: [Post] = []
                do {
                    let gotList = try await self.getPost(first: first, music: music, artist: artist, category: category)
                    if gotList.count == 0 {
                        return[]
                    }
                    list.append(contentsOf: await self.selectPost(post: gotList))
                } catch {
                    print("Error getting post")
                }
                while list.count <= 5 {
                    do {

                        let gotList = try await self.getPost(first: false, music: music, artist: artist, category: category)

                        if gotList.count == 0 {
                            return list
                        }

                        list.append(contentsOf: await self.selectPost(post: gotList))

                    } catch {
                        print("Error getting post")

                    }
                }
                return list
            }

            var l: [Post] = []
            for await post in group {
                l.append(contentsOf: post)
            }
            return l
        }
    }
    
    //撮ってきた投稿の中から非表示の設定になっている投稿を弾き、userNameを取得する
    func selectPost(post: [Post]) async -> [Post] {
        var list: [Post] = []
        for p in post {
            print("here")
            guard let user = await getUserInformation(id: p.userID) else {
                print("continueeee")
                continue
            }
            var _post = p
            _post.userID = user.name
            var show = user.showAll
            if Manager.shared.user.follow.first(where: {$0 == p.userID}) != nil {
                show = true
            } else if p.userID == self.userID {
                show = true
            }
            
            if show {
                list.append(_post)
            }
            
        }
        
        return list
        
    }
    
    //一人のユーザーの投稿を検索する
    func searchUserPost(first: Bool, id: String, name: String, completionHandler: @escaping ([Post]) -> Void) {
        var list: [Post] = []
        if first {
            shareRef
                .whereField(ShareRef.userID.rawValue, isEqualTo: id)
                .order(by: ShareRef.time.rawValue, descending: true)
                .limit(to: self.getLimit)
                .getDocuments { (collection, err) in
                    if let _err = err {
                        print("Error getiing user post: \(_err)")
                        completionHandler([])
                    } else {
                        for document in collection!.documents {
                            
                            do{
                                var a = try document.data(as: Post.self)
                                a.userID = name
                                list.append(a)
                            }catch{
                                print(error)
                            }
                            
                        }
                        
                        self.userPostDocuments = collection!.documents
                        completionHandler(list)
                    }
                }
        } else {
            guard let _lastDocument = self.userPostDocuments.last else {
                completionHandler([])
                return
            }
            shareRef
                .whereField(ShareRef.userID.rawValue, isEqualTo: id)
                .order(by: ShareRef.time.rawValue, descending: true)
                .limit(to: self.getLimit)
                .start(afterDocument: _lastDocument)
                .getDocuments { (collection, err) in
                    if let _err = err {
                        print("Error getiing user post: \(_err)")
                        completionHandler([])
                    } else {
                        for document in collection!.documents {
                            
                            do{
                                var a = try document.data(as: Post.self)
                                a.userID = name
                                list.append(a)
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
    
    //いいねした投稿を検索する
    func searchGoodList(goodList: Array<String>.SubSequence) async -> [Post] {
        var list: [Post] = []
        
        for g in goodList {
            guard var a = await getOnePost(id: g) else { continue }
            guard let user = await getUserInformation(id: a.userID) else { continue }
            a.userID = user.name
            list.append(a)
        }
        
        return list
    }
    
    //一つ、documentIDがわかっている投稿を取得する
    func getOnePost(id: String) async -> Post? {
        await withCheckedContinuation { continuation in
            shareRef.document(id).getDocument { (document, err) in
                if let _err = err {
                    print("Error getting post: \(_err)")
                    continuation.resume(returning: nil)
                } else {
                    do {
                        let d = try document?.data(as: Post.self)
                        continuation.resume(returning: d)
                    } catch {
                        print(err!)
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
    
    //他のユーザーを検索する時に呼び出される
    func searchUserName(string: String, completionHandler: @escaping ([User]) -> Void) {
        var list: [User] = []
        db.collection("user")
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
        let ref = musicRef.addDocument(data: [
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
                
                
                completionHandler(true)
            }
        }
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
                                                  id: ref.documentID))
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
        Manager.shared.user.listOrder.append(ref.documentID)
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
            ShareRef.userID.rawValue: UserDefaultsKey.userID.get()!,
            ShareRef.time.rawValue: time,
            ShareRef.goodNumber.rawValue: 0,
            ShareRef.category.rawValue: category
        ]) { err in
            if let _err = err {
                print("Error adding music: \(_err)")
            }
        }
    }
    
    //フォローした時
    func follow(followUser: String, followedUser: String) {
        db.collection("user").document(followUser).updateData([
            UserRef.follow.rawValue: FieldValue.arrayUnion([followedUser])
        ]) { err in
            if let _err = err {
                print("Error follow: \(_err)")
            }
        }
        
        db.collection("user").document(followedUser).updateData([
            UserRef.follower.rawValue: FieldValue.arrayUnion([followUser])
        ]) { err in
            if let _err = err {
                print("Error follow: \(_err)")
            }
        }
        if followUser == userID {
            Manager.shared.user.follower.append(followedUser)
        } else {
            Manager.shared.user.follow.append(followUser)
        }
    }
    
    func sendRequest(receiveUser: String) {
        userRef.updateData([
            UserRef.request.rawValue: FieldValue.arrayUnion([receiveUser])
        ]) { err in
            if let _err = err {
                print("Error add request: \(_err)")
            }
        }
        
        let notice = [
            UserRef.NoticeRef.title.rawValue: "フォローリクエスト",
            UserRef.NoticeRef.content.rawValue: "\(Manager.shared.user.name)さん（ユーザーID: \(String(userID))）からフォローリクエストが届きました",
            UserRef.NoticeRef.seen.rawValue: false,
            UserRef.NoticeRef.from.rawValue: userID
            
        ] as [String : Any]
        db.collection("user").document(receiveUser).updateData([
            UserRef.notice.rawValue: FieldValue.arrayUnion([notice])
        ]) { err in
            if let _err = err {
                print("Error send request: \(_err)")
            }
        }
        
        Manager.shared.user.request.append(receiveUser)
        
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
    
    //フォローをはずした時
    func deleteFollow(followedUser: String, indexPathRow: Int) {
        userRef.updateData([
            UserRef.follow.rawValue: FieldValue.arrayRemove([followedUser])
        ]) { err in
            if let _err = err {
                print("Error remove follow: \(_err)")
            }
        }
        
        db.collection("user").document(followedUser).updateData([
            UserRef.follower.rawValue: FieldValue.arrayRemove([userID])
        ]) { err in
            if let _err = err {
                print("Error remove follow: \(_err)")
            }
        }
        
        Manager.shared.user.follow.remove(at: indexPathRow)
    }
    
    func deleteRequest(notice: Notice) {
        let a = [UserRef.NoticeRef.title.rawValue: notice.title,
                 UserRef.NoticeRef.content.rawValue: notice.content,
                 UserRef.NoticeRef.seen.rawValue: notice.seen,
                 UserRef.NoticeRef.from.rawValue: notice.from] as [String : Any]
        userRef.updateData([
            UserRef.notice.rawValue: FieldValue.arrayRemove([a])
        ]) { err in
            if let _err = err {
                print("Error remove notification: \(_err)")
            }
        }
        
        db.collection("user").document(notice.from).updateData([
            UserRef.request.rawValue: FieldValue.arrayRemove([userID])
        ]) { err in
            if let _err = err {
                print("Error remove request: \(_err)")
            }
        }
        
        
    }
    
    func cancelRequest(notice: Notice, receiveUser: String) {
        let a = [UserRef.NoticeRef.title.rawValue: notice.title,
                 UserRef.NoticeRef.content.rawValue: notice.content,
                 UserRef.NoticeRef.seen.rawValue: notice.seen,
                 UserRef.NoticeRef.from.rawValue: notice.from] as [String : Any]
        db.collection("user").document(receiveUser).updateData([
            UserRef.notice.rawValue: FieldValue.arrayRemove([a])
        ]) { err in
            if let _err = err {
                print("Error remove notification: \(_err)")
            }
        }
        
        userRef.updateData([
            UserRef.request.rawValue: FieldValue.arrayRemove([receiveUser])
        ]) { err in
            if let _err = err {
                print("Error remove request: \(_err)")
            }
        }
        
        let i = Manager.shared.user.request.firstIndex(where: {$0 == receiveUser})!
        Manager.shared.user.request.remove(at: i)
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
                Manager.shared.user.listOrder = listOrder
            }
        }
    }
    
    //投稿のいいねボタンが押された時に呼び出される
    func goodUpdate(id: String, good: Bool) {
        if  good {
            let num = Manager.shared.user.goodList.firstIndex(of: id)!
            Manager.shared.user.goodList.remove(at: num)
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
            Manager.shared.user.goodList.append(id)
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
    
    //ユーザー名の変更
    func updateUserName(rename: String) {
        userRef.updateData([
            UserRef.name.rawValue: rename
        ]) { err in
            if let _err = err {
                print("Error updating user name: \(_err)")
            }
        }
        
    }
    
    //公開制限の変更
    func updateShowAll(id: String, newBool: Bool) {
        userRef.updateData([
            UserRef.showAll.rawValue: newBool
        ]) { err in
            if let _err = err {
                print("Error updating user showAll: \(_err)")
            }
        }
    }
    
    
    
    enum UserRef: String {
        case goodList = "goodList"
        case listOrder = "listOrder"
        case name = "name"
        case showAll = "showAll"
        case follow = "follow"
        case follower = "follower"
        case request = "request"
        case notice = "notice"
        
        enum NoticeRef: String {
            case title = "title"
            case content = "content"
            case seen = "seen"
            case from = "from"
        }
        
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
        case userID = "userID"
        case content = "content"
        case goodNumber = "goodNumber"
        case category = "category"
    }
}
//taiga da-isukidayo-
