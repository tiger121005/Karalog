//
//  MusicFirebase.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/09/10.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore

let musicFB = MusicFirebase.shared


//MARK: - MusicFirebase

class MusicFirebase: ObservableObject {
    static let shared = MusicFirebase()
    
    let db = Firestore.firestore()
    var musicRef: CollectionReference!
    var userID: String!
    
    func setupMusicFB(userID: String) {
        self.userID = userID
        musicRef = db.collection("user").document(userID).collection("musicList")
    }
    
    //MARK: - Get
    
    //musicListを取得
    func getMusic() async -> [MusicList]? {
        await withCheckedContinuation { continuation in
            musicRef.getDocuments { (collection, err) in
                if let err {
                    print("Error getting music: \(err)")
                    continuation.resume(returning: nil)
                }else{
                    manager.musicList = []
                    for document in collection!.documents {
                        do{
                            if let music = try? document.data(as: MusicList.self) {
                                manager.musicList.append(music)
                            }
                            
                        }catch{
                            print(error)
                        }
                    }
                    continuation.resume(returning: manager.musicList)
                }
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
                            if let music = try? document.data(as: MusicList.self) {
                                list.append(music)
                            }
                        } catch {
                            print(error)
                        }
                    }
                    continuation.resume(returning: list)
                }
            }
        }
    }
    
    
    //MARK: - Add
    
    //musicListに追加
    func addMusic(musicName: String, artistName: String, musicImage: String, time: String, score: Double, key: Int, model: String, comment: String, completionHandler: @escaping (Any) -> Void) {
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
        manager.musicList.append(MusicList(musicName: musicName,
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
        let indexPath = manager.musicList.firstIndex(where: {$0.id == musicID})!
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
        manager.musicList[indexPath].data.append(MusicData(time: time,
                                                           score: score,
                                                           key: key,
                                                           model: model,
                                                           comment: comment))
    }
    
    //listに追加
    func addMusicToList(musicID: String, listID: String) {
        let indexPath = manager.musicList.firstIndex(where: {$0.id == musicID})!
        musicRef.document(musicID).updateData([
            UserRef.MusicListRef.lists.rawValue: FieldValue.arrayUnion([listID])
        ]) { err in
            if let _err = err {
                print("Error adding music \(_err)")
            }else{
                print("musicAdded")
                
            }
        }
        manager.musicList[indexPath].lists.append(listID)
    }
    
    
    //MARK: - Delete
    
    //musicを削除
    func deleteMusic(id: String, completionHandler: @escaping (Any) -> Void) {
        musicRef.document(id).delete() { err in
            if let _err = err {
                print("error deleting music: \(_err)")
            }else{
                print("music successfully deleted")
                manager.musicList.removeAll(where: {$0.id == id})
                completionHandler(true)
            }
            
        }
    }
    
    //musicDataを削除
    func deleteMusicDetail(musicID: String, data: MusicData, completionHandler: @escaping (Any) -> Void) {
        let indexPath = manager.musicList.firstIndex(where: {$0.id == musicID})!
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
                
                manager.musicList[indexPath].data.removeAll(where: {$0.time == data.time})
                completionHandler(true)
            }
        }
    }
    
    
    //MARK: - Update
    
    //musicListを更新
    func favoriteUpdate(id: String, favorite: Bool, completionHandler: @escaping (Any) -> Void) {
        if favorite {
            musicRef.document(id).updateData([
                UserRef.MusicListRef.favorite.rawValue: false
            ]){ err in
                if let _err = err {
                    print("Error updating favorite: \(_err)")
                } else {
                    print("favorite successfully updated")
                    
                    let num = manager.musicList.firstIndex(where: {$0.id!.contains(id)})
                    manager.musicList[num!].favorite = false
                    
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
                    
                    let num = manager.musicList.firstIndex(where: {$0.id!.contains(id)})
                    manager.musicList[num!].favorite = true
                    
                    completionHandler(true)
                }
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
                
                let num1 = manager.musicList.firstIndex(where: {$0.id!.contains(selectedID)})
                print("lists", manager.musicList[num1!].lists)
                let num2 = manager.musicList[num1!].lists.firstIndex(where: {$0 == listID})
                manager.musicList[num1!].lists.remove(at: num2!)
                
                completionHandler(true)
            }
        }
    }
    
}
