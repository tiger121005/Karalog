//
//  ListViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit

class ListViewController: UIViewController {
    
    var listID = ""
    var originalList: [MusicList] = []
    var tvList: [MusicList] = []
    var judgeSort = 0
    var allSelected = false
    var idList: [String] = []
    
    var selectedID = ""
    var musicName = ""
    var artistName = ""
    var musicImage: Data!
    let sortList: [String] = ["追加順(遅)", "追加順(早)", "スコア順(高)", "スコア順(低)", "曲名順(早)", "曲名順(遅)", "アーティスト順(早)", "アーティスト順(遅)"]
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editBtn: UIBarButtonItem!
    @IBOutlet var addBtn: UIBarButtonItem!
    var selectBtn: UIBarButtonItem!
    var doneBtn: UIBarButtonItem!
    var allSelectBtn: UIBarButtonItem!
    
    @IBAction func tapAdd() {
        if listID == "1" {
            performSegue(withIdentifier: "toAddWanna", sender: nil)
        } else {
            performSegue(withIdentifier: "toAddListMusic", sender: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupBarButtonItem()
        createMenu()
        setupSearchBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvList = []
        originalList = []
        
        if listID == "0" {
            tvList = Manager.shared.musicList.filter {$0.favorite == true}
            originalList = tvList
            tableView.reloadData()
        } else if listID == "1" {
            FirebaseAPI.shared.getWanna(completionHandler: {wannaList in
                self.originalList = wannaList
                self.tvList = self.originalList
                self.tableView.reloadData()
            })
        } else {
            tvList = Manager.shared.musicList.filter {$0.lists.contains(listID)}
            originalList = tvList
            tableView.reloadData()
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
            let nextView = segue.destination as! GetMusicViewController
            nextView.fromList = true
        } else if segue.identifier  == "toAddDetail" {
            let nextView = segue.destination as! AddDetailViewController
            
            nextView.fromWanna = true
            nextView.musicName = musicName
            nextView.artistName = artistName
            nextView.musicImage = musicImage
            nextView.wannaID = selectedID
        } else if segue.identifier == "toAddToList" {
            let nextView = segue.destination as! AddToListViewController
            idList = []
            let indexPathList = tableView.indexPathsForSelectedRows!.sorted{ $1.row < $0.row}
            for i in indexPathList {
                idList.append(tvList[i.row].id!)
            }
            nextView.idList = idList
        }
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TableViewCell1", bundle: nil), forCellReuseIdentifier: "tableViewCell1")
        tableView.rowHeight = 70
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.keyboardDismissMode = .onDrag
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    func setupBarButtonItem() {
        let delete = UIAction(title: "削除", image: UIImage(systemName: "trash"), handler: { [self]_ in
            if self.tableView.indexPathsForSelectedRows != nil {
                let indexPathList = self.tableView.indexPathsForSelectedRows!.sorted{ $1.row < $0.row}
                let alert = UIAlertController(title: "削除", message: String(indexPathList.count) + "個の曲のデータをリストから削除します", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    
                }
                let delete = UIAlertAction(title: "削除", style: .destructive) { [self] (action) in
                    idList = []
                    for i in indexPathList {
                        idList.append(tvList[i.row].id!)
                    }
                    if listID == "0" {
                        for i in 0...indexPathList.count - 1 {
                            FirebaseAPI.shared.favoriteUpdate(id: idList[i], favorite: true, completionHandler: {_ in
                                self.tvList.remove(at: indexPathList[i].row)
                            })
                        }
                    }else if listID == "1" {
                        for i in 0...indexPathList.count - 1 {
                            FirebaseAPI.shared.deleteWanna(wannaID: idList[i])
                            self.tvList.remove(at: indexPathList[i].row)
                        }
                    }else{
                        for i in 0...indexPathList.count - 1 {
                            FirebaseAPI.shared.deleteMusicFromList(selectedID: idList[i], listID: listID, completionHandler: {_ in
                                self.tvList.remove(at: indexPathList[i].row)
                                
                            })
                        }
                    }
                    self.tableView.reloadData()
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
        })
        let addToList = UIAction(title: "リストに追加", image: UIImage(systemName: "folder"), handler: { [self]_ in
            performSegue(withIdentifier: "toAddToList", sender: nil)
        })
        let selectMenu = UIMenu(title: "", children: [delete, addToList])
        selectBtn = UIBarButtonItem(title: "", image: UIImage(systemName: "ellipsis.circle"), menu: selectMenu)
        
        allSelectBtn = UIBarButtonItem(title: "全て選択", style: .plain, target: self, action: #selector(tapAllSelectBtn(_:)))
        doneBtn = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(tapDoneBtn(_:)))
        self.navigationItem.rightBarButtonItems = [editBtn, addBtn, selectBtn]
        self.navigationItem.leftBarButtonItems = [doneBtn, allSelectBtn]
        self.navigationItem.leftItemsSupplementBackButton = true
        selectBtn.isHidden = true
        doneBtn.isHidden = true
        allSelectBtn.isHidden = true
    }
    
    
    func createMenu() {
        let items = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "選択", image: UIImage(systemName: "pencil"), handler: { _ in
                self.editBtn.isHidden = true
                self.addBtn.isHidden = true
                self.selectBtn.isHidden = false
                self.doneBtn.isHidden = false
                self.allSelectBtn.isHidden = false
                self.allSelected = false
                self.allSelectBtn.title = "全て選択"
                self.navigationItem.hidesBackButton = true
                
                super.setEditing(true, animated: true)
                self.tableView.setEditing(true, animated: true)
                
                
                self.tableView.allowsMultipleSelection = true
                self.tableView.isEditing = true
                
                if self.searchBar.isFirstResponder {
                    self.searchBar.resignFirstResponder()
                }
                
                self.idList = []
            })
        ])
        let subItems = [UIAction(title: "追加順", handler: { [self] _ in
            if judgeSort != 0 {
                judgeSort = 0
                Function.shared.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort2")
            }else{
                judgeSort = 1
                Function.shared.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort2")
            }
            self.createMenu()
        }),
                        UIAction(title: "スコア", handler: { [self] _ in
            if judgeSort != 2{
                judgeSort = 2
                Function.shared.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort2")
            }else{
                judgeSort = 3
                Function.shared.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort2")
            }
            self.createMenu()
        }),
                        UIAction(title: "曲名", handler: { [self] _ in
            if judgeSort != 4{
                judgeSort = 4
                Function.shared.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort2")
            }else{
                judgeSort = 5
                Function.shared.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort2")
            }
            self.createMenu()
        }),
                        UIAction(title: "アーティスト", handler: { [self] _ in
            if judgeSort != 6{
                judgeSort = 6
                Function.shared.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort2")
            }else{
                judgeSort = 7
                Function.shared.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort2")
                
            }
            self.createMenu()
        })]
        
        let sorts = UIMenu(title: "並び替え（" + sortList[UserDefaults.standard.integer(forKey: "judgeSort2")] + ")", children: subItems)
        
        //editBtn.showsMenuAsPrimaryAction = true
        editBtn.menu = UIMenu(title: "", children: [items, sorts])
    }
    
    @objc func tapDoneBtn(_ sender: UIBarButtonItem) {
        self.editBtn.isHidden = false
        self.addBtn.isHidden = false
        self.navigationItem.hidesBackButton = false
        
        super.setEditing(false, animated: true)
        self.tableView.setEditing(false, animated: true)
        self.selectBtn.isHidden = true
        self.doneBtn.isHidden = true
        self.allSelectBtn.isHidden = true
    }
    
    @objc func tapAllSelectBtn(_ sender: UIBarButtonItem) {
        
        if allSelected {
            for i in 0...tvList.count - 1 {
                self.tableView.deselectRow(at: IndexPath(row: i, section: 0), animated: false)
            }
            allSelectBtn.title = "全て選択"
            allSelected = false
            
        }else{
            for i in 0...tvList.count - 1 {
                self.tableView.selectRow(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .none)
            }
            allSelectBtn.title = "全て解除"
            allSelected = true
        }
        
    }
    
}

extension ListViewController: UITableViewDataSource {
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "削除", message: "”" + tvList[indexPath.row].musicName + "”" + "を削除します", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                
            }
            let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                let selectedID = self.tvList[indexPath.row].id
                if self.listID == "0" {
                    FirebaseAPI.shared.favoriteUpdate(id: selectedID!, favorite: true, completionHandler: {_ in
                        self.tvList.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    })
                }else if self.listID == "1" {
                    FirebaseAPI.shared.deleteWanna(wannaID: selectedID!)
                    self.tvList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }else{
                    FirebaseAPI.shared.deleteMusicFromList(selectedID: selectedID!, listID: self.listID, completionHandler: {_ in
                        self.tvList.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    })
                }
            }
            
            alert.addAction(cancel)
            alert.addAction(delete)
            present(alert, animated: true, completion: nil)
            
        }
        
    }
}

extension ListViewController: UITableViewDelegate {
    //削除のラベルを変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedID = tvList[indexPath.row].id!
        if listID == "1" && isEditing == false {
            musicName = tvList[indexPath.row].musicName
            artistName = tvList[indexPath.row].artistName
            musicImage = tvList[indexPath.row].musicImage
            performSegue(withIdentifier: "toAddDetail", sender: nil)
        } else if isEditing == false{
            performSegue(withIdentifier: "toMusicDetail", sender: nil)
        }
            
    }
}

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tvList = []
        print(searchText)
        if searchText == "" {
            tvList = originalList
        }else{
            for d in originalList {
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
