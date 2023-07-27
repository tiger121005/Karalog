//
//  AddListMusicViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit

class AddListMusicViewController: UIViewController {
    
    var tvList: [MusicList] = []
    var fromFav = false
    var idList: [String] = []
    var listID = ""
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var addBtn: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        searchBar.delegate = self
        
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TableViewCell1", bundle: nil), forCellReuseIdentifier: "tableViewCell1")
        
        tableView.keyboardDismissMode = .onDrag
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = true
        
        tvList = Manager.shared.musicList
    }
    
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
                    
                }
                if fromFav == false {
                    
                    for i in 0...indexPathList.count - 1 {
                        FirebaseAPI.shared.addMusicToList(musicID: idList[i], listID: listID)
                    }
                } else {
                    for i in 0...indexPathList.count - 1 {
                        FirebaseAPI.shared.favoriteUpdate(id: idList[i], favorite: false, completionHandler: {_ in })
                        
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

}

extension AddListMusicViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択されたセルを取得する
        let selectedCell = tableView.cellForRow(at: indexPath)
        
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 選択が解除されたセルを取得する
        let deselectedCell = tableView.cellForRow(at: indexPath)
        
    }
}

extension AddListMusicViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Manager.shared.musicList.count
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
}

extension AddListMusicViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tvList = []
        if searchText == "" {
            tvList = Manager.shared.musicList
        }else{
            for d in Manager.shared.musicList {
                if d.musicName.contains(searchText) {
                    tvList.append(d)
                }else if d.artistName.contains(searchText) {
                    tvList.append(d)
                }
            }
        }
        tableView.reloadData()
    }
}
