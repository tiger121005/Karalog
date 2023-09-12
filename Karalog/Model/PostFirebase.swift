//
//  PostFirebase.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/09/10.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore

let postFB = PostFirebase.shared


//MARK: PostFirebase

class PostFirebase: ObservableObject {
    
    static let shared = PostFirebase()
    let db = Firestore.firestore()
    var userRef: DocumentReference!
    var userID: String!
    var shareRef: CollectionReference!
    //share画面
    var postDocuments: [QueryDocumentSnapshot] = []
    //selectedPost画面
    var userPostDocuments: [QueryDocumentSnapshot] = []
    
    let getLimit = 6
    
    func setupPostFB(userID: String) {
        self.userID = userID
        shareRef = db.collection("share")
        
    }
    
    
    //MARK: - Get
    
    //検索条件に応じて投稿を取得する
    func getPost(first: Bool, music: String, artist: String, category: [String]) async throws -> [Post]{
        return await withCheckedContinuation { continuation in
            if first {
                if music != "" {
                    if artist != "" {
                        if !category.isEmpty {//all
                            self.shareRef
                                .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
                                    }
                                    
                                }
                        } else {//music,artist
                            self.shareRef
                                .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
                                    }
                                }
                        }
                    } else if !category.isEmpty {//music, category
                        self.shareRef
                            .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                            .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: self.getLimit)
                            .getDocuments { (collection, err) in
                                if let list = self.convertCollection(collection: collection, err: err) {
                                    continuation.resume(returning: list)
                                } else {
                                    print("Error getting post: ", String(describing: err))
                                    continuation.resume(throwing: err as! Never)
                                }
                            }
                        
                    } else {//music
                        self.shareRef
                            .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: self.getLimit)
                            .getDocuments { (collection, err) in
                                if let list = self.convertCollection(collection: collection, err: err) {
                                    continuation.resume(returning: list)
                                } else {
                                    print("Error getting post: ", String(describing: err))
                                    continuation.resume(throwing: err as! Never)
                                }
                            }
                    }
                } else {
                    if artist != "" {
                        if !category.isEmpty {//artist,category
                            self.shareRef
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
                                    }
                                }
                        } else {//artist
                            self.shareRef
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
                                    }
                                }
                        }
                    } else if !category.isEmpty {//category
                        self.shareRef
                            .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: self.getLimit)
                            .getDocuments { (collection, err) in
                                if let list = self.convertCollection(collection: collection, err: err) {
                                    continuation.resume(returning: list)
                                } else {
                                    print("Error getting post: ", String(describing: err))
                                    continuation.resume(throwing: err as! Never)
                                }
                            }
                    } else {//no
                        self.shareRef
                            .order(by: ShareRef.time.rawValue, descending: true)
                            .limit(to: self.getLimit)
                            .getDocuments { (collection, err) in
                                if let list = self.convertCollection(collection: collection, err: err) {
                                    continuation.resume(returning: list)
                                } else {
                                    print("Error getting post: ", String(describing: err))
                                    continuation.resume(throwing: err as! Never)
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
                        if !category.isEmpty { //all
                            self.shareRef
                                .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
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
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
                                    }
                                }
                        }
                    } else {
                        if !category.isEmpty { //music,category
                            self.shareRef
                                .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
                                    }
                                }
                        } else { //music
                            self.shareRef
                                .whereField(ShareRef.musicName.rawValue, isEqualTo: music)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
                                    }
                                }
                        }
                    }
                } else {
                    if artist != "" {
                        if !category.isEmpty { //artist,category
                            self.shareRef
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
                                    }
                                }
                        } else { //artist
                            self.shareRef
                                .whereField(ShareRef.artistName.rawValue, isEqualTo: artist)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
                                    }
                                }
                        }
                    } else {
                        if !category.isEmpty { //category
                            self.shareRef
                                .whereField(ShareRef.category.rawValue, arrayContainsAny: category)
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument)
                                .limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
                                    }
                                }
                        } else { //no
                            self.shareRef
                                .order(by: ShareRef.time.rawValue, descending: true)
                                .start(afterDocument: _lastDocument).limit(to: self.getLimit)
                                .getDocuments { (collection, err) in
                                    if let list = self.convertCollection(collection: collection, err: err) {
                                        continuation.resume(returning: list)
                                    } else {
                                        print("Error getting post: ", String(describing: err))
                                        continuation.resume(throwing: err as! Never)
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
            guard let user = await userFB.getUserInformation(id: p.userID) else {
                print("continueeee")
                continue
            }
            var _post = p
            _post.userID = user.name
            var show = user.showAll
            if manager.user.follow.contains(where: {$0 == p.userID}) {
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
            guard let user = await userFB.getUserInformation(id: a.userID) else { continue }
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
    
    
    //MARK: - Add
    
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
    
    
    //MARK: - Update
    
    //投稿のいいねボタンが押された時に呼び出される
    func goodUpdate(id: String, good: Bool) {
        if  good {
            let num = manager.user.goodList.firstIndex(of: id)!
            manager.user.goodList.remove(at: num)
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
            manager.user.goodList.append(id)
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
    
    
    //MARK: - Setup
    
    func convertCollection(collection:  QuerySnapshot?, err: Error?) -> [Post]? {
        if let err {
            print("Error getting post:\(err)")
            return nil
        }else{
            var list: [Post] = []
            for document in collection!.documents {
                
                do{
                    list.append(try document.data(as: Post.self))
                }catch{
                    print(error)
                }
                
            }
            self.postDocuments = collection!.documents
            return list
        }
    }
    
}
