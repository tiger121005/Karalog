//
//  ListViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var musicRef: CollectionReference!
    var wannaRef: CollectionReference!
    var listID = ""
    var wannaList: [MusicList] = []
    var tvList: [MusicList] = []
    
    var selectedID = ""
    var musicName = ""
    var artistName = ""
    var musicImage: Data!
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func tapAdd() {
        if listID == "1" {
            performSegue(withIdentifier: "toAddWanna", sender: nil)
        } else {
            performSegue(withIdentifier: "toAddListMusic", sender: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TableViewCell1", bundle: nil), forCellReuseIdentifier: "tableViewCell1")
        tableView.rowHeight = 50
        
        let userDoc = Firestore.firestore().collection("user").document(UserDefaults.standard.string(forKey: "userID")!)
        
        wannaRef = userDoc.collection("wannaList")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvList = []
        
        if listID == "0" {
            self.tvList = Manager.shared.musicList.filter {$0.favorite == true}
            self.tableView.reloadData()
        } else if listID == "1" {
            FirebaseAPI.shared.getWanna(completionHandler: {wannaList in
                self.tvList = wannaList
                self.tableView.reloadData()
            })
        } else {
            self.tvList = Manager.shared.musicList.filter {$0.lists.contains(listID)}
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddListMusic" {
            let nextView = segue.destination as! AddListMusicViewController
            if listID == "0" {
                nextView.fromFav = true
            } else {
                nextView.fromFav = false
                nextView.listID = listID
            }
        } else if segue.identifier == "toMusicDetail" {
            let nextView = segue.destination as! MusicDetailViewController
            nextView.musicID = selectedID
        } else if segue.identifier == "toAddWanna" {
            let nextView = segue.destination as! SearchViewController
            nextView.fromList = true
        } else if segue.identifier  == "toAddDetail" {
            let nextView = segue.destination as! AddDetailViewController
            
            nextView.fromWanna = true
            nextView.musicName = musicName
            nextView.artistName = artistName
            nextView.musicImage = musicImage
            nextView.wannaID = selectedID
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tvList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell1", for: indexPath) as! TableViewCell1
        
        //cellのdelegateを呼び出して、indexに代入。お気に入りボタンに使用
//        cell.delegate = self
//        cell.indexPath = indexPath
        
        cell.musicLabel?.text = tvList[indexPath.row].musicName
        cell.artistLabel?.text = tvList[indexPath.row].artistName
        let useImage = UIImage(data: tvList[indexPath.row].musicImage)?.withRenderingMode(.alwaysOriginal)
        cell.musicImage?.image = useImage
        
        cell.favoriteBtn.isHidden = true
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "削除", message: "”" + tvList[indexPath.row].musicName + "”" + "を削除します", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                
            }
            let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                let selectedID = self.tvList[indexPath.row].id
                FirebaseAPI.shared.listUpdate(selectedID: selectedID!, listID: self.listID, completionHandler: {_ in
                    self.tvList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                })
                
            }
            
            alert.addAction(cancel)
            alert.addAction(delete)
            present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    //削除のラベルを変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedID = tvList[indexPath.row].id!
        if listID != "1" {
            performSegue(withIdentifier: "toMusicDetail", sender: nil)
        } else {
            musicName = tvList[indexPath.row].musicName
            artistName = tvList[indexPath.row].artistName
            musicImage = tvList[indexPath.row].musicImage
            performSegue(withIdentifier: "toAddDetail", sender: nil)
        }
            
    }
    

}
