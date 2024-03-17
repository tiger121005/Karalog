//
//  UserFirebase.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/09/10.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

let userFB = UserFirebase.shared


//MARK: - UserFirebase

class UserFirebase: ObservableObject {
    static let shared = UserFirebase()
    
    let db = Firestore.firestore()
    var userRef: DocumentReference!
    var userID: String!
    
    func setupFirebase(userID: String) {
        setupUserFB(userID: userID)
        musicFB.setupMusicFB(userID: userID)
        listFB.setupListFB(userID: userID)
        postFB.setupPostFB(userID: userID)
    }
    
    func setupUserFB(userID: String) {
        self.userID = userID
        userRef = db.collection("user").document(userID)
    }
    
    
    //MARK: - Get
    
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
                            print("Error getting user information: \(String(describing: err))")
                        }
                    } else {
                        continuation.resume(returning: nil)
                        print("Error getting user information: \(String(describing: err))")
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
                    guard let collection else { return }
                    for document in collection.documents {
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
            manager.user.follow.append(followedUser)
        } else {
            manager.user.follower.append(followUser)
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
            UserRef.NoticeRef.content.rawValue: "\(manager.user.name)さん（ユーザーID: \(String(userID))）からフォローリクエストが届きました",
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
        
        manager.user.request.append(receiveUser)
        
    }
    
    
    //MARK: - Delete
    
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
        
        manager.user.follow.remove(at: indexPathRow)
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
        
        if let userID {
            db.collection("user").document(notice.from).updateData([
                UserRef.request.rawValue: FieldValue.arrayRemove([userID])
            ]) { err in
                if let _err = err {
                    print("Error remove request: \(_err)")
                }
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
        
        if let i = manager.user.request.firstIndex(where: {$0 == receiveUser}) {
            manager.user.request.remove(at: i)
        }
    }
    
    
    //MARK: - Update
    
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
    
    func updateGetImage(id: String, newBool: Bool) {
        userRef.updateData([
            UserRef.getImage.rawValue: newBool
        ]) { err in
            if let _err = err {
                print("Error updating user getImage: \(_err)")
            }
        }
        
        manager.user.getImage = newBool
    }
}

