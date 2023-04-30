//
//  AddListMusicViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class AddListMusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var musicRef: CollectionReference!
    var tvList: [SimpleMusic] = []
    var fromFav = false
    var idList: [String] = []
    var listID = ""
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searcBar: UISearchBar!
    @IBOutlet var addBtn: UIBarButtonItem!
    
    @IBAction func add() {
        if self.tableView.indexPathsForSelectedRows != nil {
            let indexPathList = self.tableView.indexPathsForSelectedRows!.sorted{ $1.row < $0.row}
            
            let alert = UIAlertController(title: "追加", message: String(indexPathList.count) + "個の曲のデータを追加します", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                
            }
            let delete = UIAlertAction(title: "追加", style: .default) { [self] (action) in
                idList = []
                for i in indexPathList {
                    idList.append(tvList[i.row].id!)
                    print("😂")
                }
                if fromFav == false {
                    for i in 0...indexPathList.count - 1 {
                        self.musicRef.document(idList[i]).updateData([
                            "lists": FieldValue.arrayUnion([listID])
                        ])
                    }
                } else {
                    for i in 0...indexPathList.count - 1 {
                        self.musicRef.document(idList[i]).updateData([
                            "favorite": true
                        ])
                    }
                }
                
            }
            alert.addAction(cancel)
            alert.addAction(delete)
            present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "データなし", message: "データが選択されていません", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel) { (action) in
                
            }
            alert.addAction(ok)
            present(alert, animated: true)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TableViewCell1", bundle: nil), forCellReuseIdentifier: "tableViewCell1")
        
        tableView.keyboardDismissMode = .onDrag
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = true
        
        
        
        musicRef = Firestore.firestore().collection("user").document(UserDefaults.standard.string(forKey: "userID")!).collection("musicList")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvList = []
        
        musicRef.getDocuments { (collection, error) in
            if let error = error {
                print("Error getting music: \(error)")
            } else {
                for document in collection!.documents {
                    let name = document["musicName"] as! String
                    let artist = document["artistName"] as! String
                    let image = document["musicImage"] as! Data
                    let id = document.documentID
                    
                    self.tvList.append(SimpleMusic(musicName: name, artistName: artist, musicImage: image, id: id))
                }
                self.tableView.reloadData()
            }
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tvList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell1", for: indexPath) as! TableViewCell1
        
        cell.musicLabel?.text = tvList[indexPath.row].musicName
        cell.artistLabel?.text = tvList[indexPath.row].artistName
        let useImage = UIImage(data: tvList[indexPath.row].musicImage)?.withRenderingMode(.alwaysOriginal)
        cell.musicImage?.image = useImage
        
        cell.favoriteBtn.isHidden = true
        cell.selectionStyle = .default
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択されたセルを取得する
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        print(selectedCell)
    }

    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 選択が解除されたセルを取得する
        let deselectedCell = tableView.cellForRow(at: indexPath)
        print(deselectedCell)
        
        
    }

    
}
