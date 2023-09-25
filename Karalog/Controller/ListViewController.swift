//
//  ListViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit

var fromAddListMusic = false


//MARK: - ListViewController

class ListViewController: UIViewController {
    
    var listID: String = ""
    var listName: String = ""
    var originalList: [MusicList] = []
    var tvList: [MusicList] = []
    var judgeSort: String = Sort.追加順（遅）.rawValue
    var allSelected: Bool = false
    var idList: [String] = []
    
    var selectedID: String = ""
    var musicName: String = ""
    var artistName: String = ""
    var musicImage: Data!
    let sortList: [String] = ["追加順(遅)", "追加順(早)", "スコア順(高)", "スコア順(低)", "曲名順(早)", "曲名順(遅)", "アーティスト順(早)", "アーティスト順(遅)"]
    
    
    //MARK: - UI objects
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editBtn: UIBarButtonItem!
    @IBOutlet var addBtn: UIBarButtonItem!
    var selectBtn: UIBarButtonItem!
    var doneBtn: UIBarButtonItem!
    var allSelectBtn: UIBarButtonItem!
    var addAlert: UIAlertController!
    
    
    //MARK: - View Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupBarButtonItem()
        createMenu()
        setupSearchBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showMessage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddListMusic" {
            let nextView = segue.destination as! AddListMusicViewController
            if listID == "favorite" {
                nextView.fromFav = true
            } else {
                nextView.fromFav = false
                nextView.listID = listID
            }
        } else if segue.identifier == "toMusicDetail" {
            let nextView = segue.destination as! MusicDetailViewController
            nextView.musicID = selectedID
            nextView.musicName = musicName
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
    
    
    //MARK: - Setup
    
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
        let delete = UIAction(title: "削除", image: UIImage.trash, handler: { [self]_ in
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
                    if listID == "favorite" {
                        for i in 0...indexPathList.count - 1 {
                            musicFB.favoriteUpdate(id: idList[i], favorite: true, completionHandler: {_ in
                                self.tvList.remove(at: indexPathList[i].row)
                            })
                        }
                    }else if listID == "wanna" {
                        for i in 0...indexPathList.count - 1 {
                            listFB.deleteWanna(wannaID: idList[i])
                            self.tvList.remove(at: indexPathList[i].row)
                        }
                    }else{
                        for i in 0...indexPathList.count - 1 {
                            musicFB.deleteMusicFromList(selectedID: idList[i], listID: listID, completionHandler: {_ in
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
        let addToList = UIAction(title: "リストに追加", image: UIImage.folder, handler: { [self]_ in
            performSegue(withIdentifier: "toAddToList", sender: nil)
        })
        let selectMenu = UIMenu(title: "", children: [delete, addToList])
        selectBtn = UIBarButtonItem(title: "", image: UIImage.ellipsisCircle, menu: selectMenu)
        
        allSelectBtn = UIBarButtonItem(title: "全て選択", style: .plain, target: self, action: #selector(tapAllSelectBtn(_:)))
        doneBtn = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(tapDoneBtn(_:)))
        self.navigationItem.rightBarButtonItems = [editBtn, addBtn, selectBtn]
        self.navigationItem.leftBarButtonItems = [doneBtn, allSelectBtn]
        self.navigationItem.leftItemsSupplementBackButton = true
        selectBtn.isHidden = true
        doneBtn.isHidden = true
        allSelectBtn.isHidden = true
        
        title = listName
    }
    
    
    func createMenu() {
        let items = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "選択", image: UIImage.pencil, handler: { _ in
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
            if judgeSort != Sort.追加順（遅）.rawValue {
                judgeSort = Sort.追加順（遅）.rawValue
                function.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaultsKey.judgeSort.set(value: judgeSort)
            }else{
                judgeSort = Sort.追加順（遅）.rawValue
                function.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaultsKey.judgeSort.set(value: judgeSort)
            }
            self.createMenu()
        }),
                        UIAction(title: "スコア", handler: { [self] _ in
            if judgeSort != Sort.得点（高）.rawValue {
                judgeSort = Sort.得点（高）.rawValue
                function.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaultsKey.judgeSort.set(value: judgeSort)
            }else{
                judgeSort = Sort.得点（低）.rawValue
                function.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaultsKey.judgeSort.set(value: judgeSort)
            }
            self.createMenu()
        }),
                        UIAction(title: "曲名", handler: { [self] _ in
            if judgeSort != Sort.曲名順（降）.rawValue{
                judgeSort = Sort.曲名順（降）.rawValue
                function.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaultsKey.judgeSort.set(value: judgeSort)
            }else{
                judgeSort = Sort.曲名順（昇）.rawValue
                function.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaultsKey.judgeSort.set(value: judgeSort)
            }
            self.createMenu()
        }),
                        UIAction(title: "アーティスト", handler: { [self] _ in
            if judgeSort != Sort.アーティスト順（降）.rawValue {
                judgeSort = Sort.アーティスト順（降）.rawValue
                function.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaultsKey.judgeSort.set(value: judgeSort)
            }else{
                judgeSort = Sort.アーティスト順（昇）.rawValue
                function.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaultsKey.judgeSort.set(value: judgeSort)

            }
            self.createMenu()
        })]
        
        let sorts = UIMenu(title: "並び替え（" + judgeSort + ")", children: subItems)
        
        //editBtn.showsMenuAsPrimaryAction = true
        editBtn.menu = UIMenu(title: "", children: [items, sorts])
    }
    
    func setData() {
        tvList = []
        originalList = []
        
        if listID == "favorite" {
            tvList = manager.musicList.filter {$0.favorite == true}
            originalList = tvList
            tableView.reloadData()
        } else if listID == "wanna" {
            listFB.getWanna(completionHandler: {wannaList in
                self.originalList = wannaList
                self.tvList = self.originalList
                self.tableView.reloadData()
            })
        } else {
            tvList = manager.musicList.filter {$0.lists.contains(listID)}
            originalList = tvList
            tableView.reloadData()
        }
    }
    
    func showMessage() {
        
        if fromAddListMusic {
            addAlert = UIAlertController(title: "追加しました", message: "", preferredStyle: .alert)
            present(addAlert, animated: true, completion: nil)
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideAlert), userInfo: nil, repeats: false)
            fromAddListMusic = false
        }
    }
    
    
    //MARK: - UI interaction
    
    @IBAction func tapAdd() {
        if listID == "wanna" {
            performSegue(withIdentifier: "toAddWanna", sender: nil)
        } else {
            performSegue(withIdentifier: "toAddListMusic", sender: nil)
        }
    }
    
    
    //MARK: - Objective - C
    
    @objc func hideAlert() {
        addAlert.dismiss(animated: true)
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


//MARK: - UITableViewDataSource

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
        
        if listID != "1" {
            var list: [MusicList] = []
            var a: [Double] = []
            for i in tvList {
                let b = i.data
                var c: [Double] = []
                for j in b {
                    c.append(j.score)
                }
                a.append(c.max() ?? 0)
            }
            let d = a.indices.sorted{ a[$1] < a[$0]}
            list = d.map{tvList[$0]}
            
            var n: Int!
            if tvList.count < 10 {
                n = 1
            } else if tvList.count < 40 {
                n = Int(ceil(Double(tvList.count / 10)))
            } else {
                n = Int(ceil(Double(tvList.count / 5)))
            }
            let m = n * 3
            let high = list[n - 1].data.map{$0.score}.max() ?? 0
            var medium: Double = 0.0
            if tvList.count > 3 {
                medium = list[m - 1].data.map{$0.score}.max() ?? 0
            }
            let scoreList = tvList[indexPath.row].data.map{$0.score}
            let max = scoreList.max() ?? 0
            cell.scoreLabel.text = String(format: "%.3f", max)
            if max >= Double(high) {
                cell.scoreLabel.textColor = UIColor.imageColor
                cell.scoreLabel.font = UIFont.boldSystemFont(ofSize: 14)
            } else if max >= Double(medium) && tvList.count > 3 {
                cell.scoreLabel.textColor = UIColor.subImageColor
                cell.scoreLabel.font = UIFont.boldSystemFont(ofSize: 13)
            } else {
                cell.scoreLabel.textColor = UIColor.secondaryLabel
                cell.scoreLabel.font = UIFont.boldSystemFont(ofSize: 12)
            }
        } else {
            cell.scoreLabel.isHidden = true
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "削除", message: "”" + tvList[indexPath.row].musicName + "”" + "を削除します", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                
            }
            let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                let selectedID = self.tvList[indexPath.row].id
                if self.listID == "favorite" {
                    musicFB.favoriteUpdate(id: selectedID!, favorite: true, completionHandler: {_ in
                        self.tvList.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    })
                }else if self.listID == "wanna" {
                    listFB.deleteWanna(wannaID: selectedID!)
                    self.tvList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }else{
                    musicFB.deleteMusicFromList(selectedID: selectedID!, listID: self.listID, completionHandler: {_ in
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


//MARK: - UITableVIewDelegate

extension ListViewController: UITableViewDelegate {
    //削除のラベルを変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedID = tvList[indexPath.row].id!
        musicName = tvList[indexPath.row].musicName
        if listID == "1" && isEditing == false {
            artistName = tvList[indexPath.row].artistName
            musicImage = tvList[indexPath.row].musicImage
            performSegue(withIdentifier: "toAddDetail", sender: nil)
        } else if isEditing == false{
            
            performSegue(withIdentifier: "toMusicDetail", sender: nil)
        }
            
    }
}


//MARK: - UISearchBarDelegate

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tvList = []
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


