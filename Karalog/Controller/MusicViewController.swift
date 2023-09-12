//
//  MusicViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import DZNEmptyDataSet

var fromAdd = false


// MARK: MusicViewController

class MusicViewController: UIViewController {
    
    //曲名,アーティスト名が入る
    var tvList: [MusicList] = []
    
    //sortされている種類を調べる
    var judgeSort: String!
    var allSelected: Bool = false
    //選択したセルのid
    var selectedID: String = ""
    var idList: [String] = []
    
    var musicID: String!
    //次のviewに渡すdata
    var musicName: String = ""
    var artistName: String = ""
    var musicData: [MusicData] = []
    var musicImage: Data!
    let sortList: [String] = ["追加順(遅)", "追加順(早)", "スコア順(高)", "スコア順(低)", "曲名順(早)", "曲名順(遅)", "アーティスト順(早)", "アーティスト順(遅)"]
    
    
    //MARK: - UI objects
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editBtn: UIBarButtonItem!
    @IBOutlet var addBtn: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    var selectBtn: UIBarButtonItem!
    var doneBtn: UIBarButtonItem!
    var allSelectBtn: UIBarButtonItem!
    let refreshCtl = UIRefreshControl()
    var addAlert: UIAlertController!
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        judgeSort = UserDefaultsKey.judgeSort.get() ?? Sort.追加順（遅）.rawValue
        setupTableView()
        setupSearchBar()
        setupBarItem()
        createMenu()
        get()
        title = "HOME"
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
        if segue.identifier == "toAddToList" {
            let nextView = segue.destination as! AddToListViewController
            idList = []
            if tableView.indexPathsForSelectedRows != nil {
                let indexPathList = tableView.indexPathsForSelectedRows!.sorted{ $1.row < $0.row}
                for i in indexPathList {
                    idList.append(tvList[i.row].id!)
                }
            } else {
                idList = [musicID]
            }
            nextView.idList = idList
        }else if segue.identifier == "toMusicDetail" {
            let nextView = segue.destination as! MusicDetailViewController
            nextView.musicName = musicName
            nextView.artistName = artistName
            nextView.musicID = musicID
            nextView.musicImage = musicImage
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
    
    // ステータスバーを黒く
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    //MARK: - Setup
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TableViewCell1", bundle: nil), forCellReuseIdentifier: "tableViewCell1")
        //セクションの高さ
        tableView.rowHeight = 70
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.keyboardDismissMode = .onDrag
        
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        refreshCtl.attributedTitle = NSAttributedString(string: "再読み込み中")
        tableView.addSubview(refreshCtl)
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        
    }
    
    func setupBarItem() {
        let delete = UIAction(title: "削除", image: UIImage.trash, handler: { [self]_ in
            if self.tableView.indexPathsForSelectedRows != nil {
                let indexPathList = self.tableView.indexPathsForSelectedRows!.sorted{ $1.row < $0.row}
                let alert = UIAlertController(title: "削除", message: String(indexPathList.count) + "個の曲のデータを削除します", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    
                }
                let delete = UIAlertAction(title: "削除", style: .destructive) { [self] (action) in
                    idList = []
                    for i in indexPathList {
                        idList.append(tvList[i.row].id!)
                    }
                    for i in 0...indexPathList.count - 1 {
                        musicFB.deleteMusic(id: idList[i], completionHandler: {_ in
                            self.tvList.remove(at: indexPathList[i].row)
                            self.tableView.reloadData()
                        })
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
        })
        let addToList = UIAction(title: "リストに追加", image: UIImage.folder, handler: { [self]_ in
            if self.tableView.indexPathForSelectedRow != nil {
                performSegue(withIdentifier: "toAddToList", sender: nil)
            }else{
                let alert = UIAlertController(title: "データなし", message: "データが選択されていません", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel) { (action) in
                    
                }
                alert.addAction(ok)
                present(alert, animated: true)
            }
        })
        let selectMenu = UIMenu(title: "", children: [delete, addToList])
        selectBtn = UIBarButtonItem(title: "", image: UIImage.ellipsisCircle, menu: selectMenu)
        
        allSelectBtn = UIBarButtonItem(title: "全て選択", style: .plain, target: self, action: #selector(tapAllSelectBtn(_:)))
        doneBtn = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(tapDoneBtn(_:)))
        self.navigationItem.rightBarButtonItems = [editBtn, addBtn, selectBtn]
        self.navigationItem.leftBarButtonItems = [doneBtn, allSelectBtn]
        selectBtn.isHidden = true
        doneBtn.isHidden = true
        allSelectBtn.isHidden = true
        
        
        
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
                judgeSort = Sort.追加順（早）.rawValue
                function.sort(sortKind: judgeSort, updateList: tvList, completionHandler: {list in
                    self.tvList = list
                    self.tableView.reloadData()
                })
                UserDefaultsKey.judgeSort.set(value: judgeSort)
            }
            self.createMenu()
        }),
                        UIAction(title: "スコア", handler: { [self] _ in
            if judgeSort != Sort.得点（高）.rawValue{
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
            if judgeSort != Sort.アーティスト順（降）.rawValue{
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
        
        editBtn.menu = UIMenu(title: "", children: [items, sorts])
    }
    
    func get() {
        print("\(manager.user.id) is login!")
        musicFB.getMusic(completionHandler: { musicList in
            self.tvList = musicList
            function.sort(sortKind: self.judgeSort, updateList: self.tvList, completionHandler: { list in
                self.tvList = list
                
            })
            self.tableView.reloadData()
        })
        
    }
    
    func setData() {
        function.sort(sortKind: judgeSort, updateList: manager.musicList, completionHandler: {list in
            self.tvList = list
            self.tableView.reloadData()
        })
    }
    
    func showMessage() {
        print("fromAdd: ", fromAdd)
        if fromAdd {
            addAlert = UIAlertController(title: "追加しました", message: "", preferredStyle: .alert)
            present(addAlert, animated: true, completion: nil)
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideAlert), userInfo: nil, repeats: false)
            fromAdd = false
        }
    }
    
    
    //MARK: - Objective - C
    
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
    
    @objc func reload() {
        musicFB.getMusic() { list in
            self.tvList = list
            self.searchBar.text = ""
            self.refreshCtl.endRefreshing()
        }
    }
    
    @objc func hideAlert() {
        addAlert.dismiss(animated: true)
    }
    
}


//MARK: - UITableViewDataSource

extension MusicViewController: UITableViewDataSource {
    //セクション数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvList.count
    }
    
    //セルを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //tableView.bounds.widthはスマホの横幅を取得するメソッド
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell1", for: indexPath) as! TableViewCell1
        
        var list: [MusicList] = []
        var a: [Double] = []
        for i in tvList {
            let b = i.data
            var c: [Double] = []
            c += b.map{$0.score}
            a.append(c.max()!)
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
        let high = list[n - 1].data.map{$0.score}.max()!
        var medium: Double = 0.0
        if tvList.count > 3 {
            medium = list[m - 1].data.map{$0.score}.max()!
        }
        //cellのdelegateを呼び出して、indexに代入。お気に入りボタンに使用
        cell.delegate = self
        cell.indexPath = indexPath
        
        cell.musicLabel?.text = tvList[indexPath.row].musicName
        cell.artistLabel?.text = tvList[indexPath.row].artistName
        let useImage = UIImage(data: tvList[indexPath.row].musicImage)?.withRenderingMode(.alwaysOriginal)
        cell.musicImage?.image = useImage
        
        //最高得点
        let scoreList = tvList[indexPath.row].data.map{$0.score}
        let max = scoreList.max()
        cell.scoreLabel.text = String(format: "%.3f", max!)
        if max! >= Double(high) {
            cell.scoreLabel.textColor = UIColor.imageColor
            cell.scoreLabel.font = UIFont.boldSystemFont(ofSize: 14)
        } else if max! >= Double(medium) && tvList.count > 3 {
            cell.scoreLabel.textColor = UIColor.subImageColor
            cell.scoreLabel.font = UIFont.boldSystemFont(ofSize: 13)
        } else {
            cell.scoreLabel.textColor = .gray
            cell.scoreLabel.font = UIFont.boldSystemFont(ofSize: 12)
        }
        
        //お気に入りボタン
        if tvList[indexPath.row].favorite == false {
            cell.favoriteBtn?.setImage(UIImage.star, for: .normal)
        }else if tvList[indexPath.row].favorite == true {
            cell.favoriteBtn?.setImage(UIImage.starFill, for: .normal)
        }
        
        cell.backgroundColor = .clear
        
        var selectedBgView = UIView()
        selectedBgView.backgroundColor = .gray
        cell.selectedBackgroundView = selectedBgView
        
        return cell
    }
    
    //削除機能
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "削除", message: "”" + tvList[indexPath.row].musicName + "”" + "を削除します", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                
            }
            let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                self.selectedID = self.tvList[indexPath.row].id!
                musicFB.deleteMusic(id: self.selectedID, completionHandler: {_ in
                    self.tvList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                })
                
                if self.tvList.count == 0 {
                    self.tableView.reloadData()
                }
            }
            alert.addAction(cancel)
            alert.addAction(delete)
            present(alert, animated: true, completion: nil)
        }
    }
}


//MARK: - UITableViewDelegate

extension MusicViewController: UITableViewDelegate {
    
    //削除のラベルを変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        musicID = tvList[indexPath.row].id
        if isEditing == false {
            musicData = tvList[indexPath.row].data
            musicName = tvList[indexPath.row].musicName
            artistName = tvList[indexPath.row].artistName
            musicID = tvList[indexPath.row].id
            musicImage = tvList[indexPath.row].musicImage
            if searchBar.isFirstResponder {
                searchBar.resignFirstResponder()
            }
            performSegue(withIdentifier: "toMusicDetail", sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let addList = UIAction(title: "リストに追加") {_ in
            self.musicID = self.tvList[indexPath.row].id
            self.performSegue(withIdentifier: "toAddToList", sender: nil)
        }
        
        let menu = UIMenu(title: "選択", image: nil, identifier: nil, options: [], children: [addList])
                let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                    menu
                }
                
                return contextMenuConfiguration
    }
    
}


//MARK: - TableViewCell1Delegate

extension MusicViewController: TableViewCell1Delegate {
    func reloadCell(indexPath: IndexPath) {
        selectedID = tvList[indexPath.row].id!
        musicFB.favoriteUpdate(id: selectedID, favorite: tvList[indexPath.row].favorite, completionHandler: {_ in
            self.tvList[indexPath.row].favorite.toggle()
            self.tableView.reloadData()
        })
        
    }
}


//MARK: - DZNEmptyDataSetSource

extension MusicViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "曲のデータがありません")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.KaralogImage.resized(toWidth: 250)
    }
}


//MARK: - DZNEmptyDataSetDelegate

extension MusicViewController: DZNEmptyDataSetDelegate {
    
}


//MARK: - UISearchBarDelegate

extension MusicViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tvList = []
        print(searchText)
        if searchText == "" {
            tvList = manager.musicList
        }else{
            for d in manager.musicList {
                if d.musicName.contains(searchText) {
                    tvList.append(d)
                }else if d.artistName.contains(searchText) {
                    tvList.append(d)
                }
            }
        }
        tableView.reloadData()
    }
    
    //改行したら自動的にキーボードを非表示にする
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
