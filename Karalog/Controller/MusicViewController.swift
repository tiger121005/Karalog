//
//  MusicViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import DZNEmptyDataSet


class MusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, TableViewCell1Delegate {
    
    //曲名,アーティスト名が入る
    var musicList: [MusicList] = []
    var tvList: [MusicList] = []
    //sortされている種類を調べる
    var judgeSort = 0
    var allSelected = false
    //選択したセルのid
    var selectedID = ""
    var idList: [String] = []
    
    var musicID: String!
    //次のviewに渡すdata
    var musicName = ""
    var musicData: [MusicData] = []
    let sortList: [String] = ["追加順(遅)", "追加順(早)", "スコア順(高)", "スコア順(低)", "曲名順(早)", "曲名順(遅)", "アーティスト順(早)", "アーティスト順(遅)"]
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editBtn: UIBarButtonItem!
    @IBOutlet var addBtn: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    var selectBtn: UIBarButtonItem!
    var doneBtn: UIBarButtonItem!
    var allSelectBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TableViewCell1", bundle: nil), forCellReuseIdentifier: "tableViewCell1")
        //セクションの高さ
        tableView.rowHeight = 50
        tableView.allowsMultipleSelectionDuringEditing = true
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        searchBar.delegate = self
        tableView.keyboardDismissMode = .onDrag

        let delete = UIAction(title: "削除", image: UIImage(systemName: "trash"), handler: { [self]_ in
            if self.tableView.indexPathsForSelectedRows != nil {
                let indexPathList = self.tableView.indexPathsForSelectedRows!.sorted{ $1.row < $0.row}
                let alert = UIAlertController(title: "削除", message: String(indexPathList.count) + "個の曲のデータを削除します", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    
                }
                let delete = UIAlertAction(title: "削除", style: .destructive) { [self] (action) in
                    idList = []
                    for i in indexPathList {
                        idList.append(tvList[i.row].id!)
                        print("😂")
                    }
                    for i in 0...indexPathList.count - 1 {
                        FirebaseAPI.shared.deleteMusic(id: idList[i], completionHandler: {_ in
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
        let addToList = UIAction(title: "リストに追加", image: UIImage(systemName: "folder"), handler: { [self]_ in
            performSegue(withIdentifier: "toAddToList", sender: nil)
        })
        let selectMenu = UIMenu(title: "", children: [delete, addToList])
        selectBtn = UIBarButtonItem(title: "選択", menu: selectMenu)
        
        allSelectBtn = UIBarButtonItem(title: "全て選択", style: .plain, target: self, action: #selector(tapAllSelectBtn(_:)))
        doneBtn = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(tapCancelBtn(_:)))
        self.navigationItem.rightBarButtonItems = [doneBtn, editBtn, addBtn]
        self.navigationItem.leftBarButtonItems = [allSelectBtn, selectBtn]
        selectBtn.isHidden = true
        doneBtn.isHidden = true
        allSelectBtn.isHidden = true
        
        let userID = UserDefaults.standard.string(forKey: "userID")
        print(userID!, "is logined")
        
        createMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        get()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddToList" {
            let nextView = segue.destination as! AddToListViewController
            print("🇳🇴", idList)
            idList = []
            let indexPathList = tableView.indexPathsForSelectedRows!.sorted{ $1.row < $0.row}
            for i in indexPathList {
                idList.append(tvList[i.row].id!)
                print("😂")
            }
            nextView.idList = idList
            
        }else if segue.identifier == "toSearch" {
            let nextView = segue.destination as! SearchViewController
            
            
        }else if segue.identifier == "toMusicDetail" {
            let nextView = segue.destination as! MusicDetailViewController
            nextView.musicData = musicData
            nextView.musicName = musicName
            nextView.musicID = musicID
            
            
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
    
    
    //セクション数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvList.count
    }
    
    //セクションを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //tableView.bounds.widthはスマホの横幅を取得するメソッド
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell1", for: indexPath) as! TableViewCell1
        
        //cellのdelegateを呼び出して、indexに代入。お気に入りボタンに使用
        cell.delegate = self
        cell.indexPath = indexPath
        
        cell.musicLabel?.text = tvList[indexPath.row].musicName
        cell.artistLabel?.text = tvList[indexPath.row].artistName
        let useImage = UIImage(data: tvList[indexPath.row].musicImage)?.withRenderingMode(.alwaysOriginal)
        cell.musicImage?.image = useImage
        
        if tvList[indexPath.row].favorite == false {
            cell.favoriteBtn?.setImage(UIImage(systemName: "star"), for: .normal)
        }else if tvList[indexPath.row].favorite == true {
            cell.favoriteBtn?.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        musicID = tvList[indexPath.row].id
        if isEditing == true {
            
        }else{
            musicData = tvList[indexPath.row].data
            musicName = tvList[indexPath.row].musicName
            musicID = tvList[indexPath.row].id
            print(idList)
            if searchBar.isFirstResponder {
                searchBar.resignFirstResponder()
            }
            performSegue(withIdentifier: "toMusicDetail", sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    //削除機能
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "削除", message: "”" + tvList[indexPath.row].musicName + "”" + "を削除します", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                
            }
            let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                self.selectedID = self.tvList[indexPath.row].id!
                FirebaseAPI.shared.deleteMusic(id: self.selectedID, completionHandler: {_ in
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
    
    //削除のラベルを変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    func reloadCell(indexPath: IndexPath) {
        selectedID = tvList[indexPath.row].id!
        FirebaseAPI.shared.favoriteUpdate(id: selectedID, favorite: tvList[indexPath.row].favorite, completionHandler: {_ in
            self.tvList[indexPath.row].favorite.toggle()
            self.tableView.reloadData()
        })
        
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "曲のデータがありません")
    }
    let mic: UIImage = UIImage(systemName: "music.mic.circle.fill")!
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return mic.resized(toWidth: 250)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tvList = []
        print(searchText)
        if searchText == "" {
            tvList = musicList
        }else{
            for d in musicList {
                if d.musicName.contains(searchText) {
                    tvList.append(d)
                }else if d.artistName.contains(searchText) {
                    tvList.append(d)
                }
            }
        }
        tableView.reloadData()
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
                sort(sortKind: judgeSort)
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort")
            }else{
                judgeSort = 1
                sort(sortKind: judgeSort)
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort")
            }
            self.createMenu()
        }),
                        UIAction(title: "スコア", handler: { [self] _ in
            if judgeSort != 2{
                judgeSort = 2
                sort(sortKind: judgeSort)
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort")
            }else{
                judgeSort = 3
                sort(sortKind: judgeSort)
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort")
            }
            self.createMenu()
        }),
                        UIAction(title: "曲名", handler: { [self] _ in
            if judgeSort != 4{
                judgeSort = 4
                sort(sortKind: judgeSort)
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort")
            }else{
                judgeSort = 5
                sort(sortKind: judgeSort)
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort")
            }
            self.createMenu()
        }),
                        UIAction(title: "アーティスト", handler: { [self] _ in
            if judgeSort != 6{
                judgeSort = 6
                sort(sortKind: judgeSort)
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort")
            }else{
                judgeSort = 7
                sort(sortKind: judgeSort)
                UserDefaults.standard.set(judgeSort, forKey: "judgeSort")
                
            }
            self.createMenu()
        })]
        
        let sorts = UIMenu(title: "並び替え（" + sortList[UserDefaults.standard.integer(forKey: "judgeSort")] + ")", children: subItems)
        
        //editBtn.showsMenuAsPrimaryAction = true
        editBtn.menu = UIMenu(title: "", children: [items, sorts])
    }
    
    
    
    @objc func tapCancelBtn(_ sender: UIBarButtonItem) {
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
            print("🇯🇵", idList)
        }else{
            for i in 0...tvList.count - 1 {
                self.tableView.selectRow(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .none)
            }
            allSelectBtn.title = "全て解除"
            allSelected = true
            print("🇳🇫", idList)
        }
        
    }
    
    func get() {
        FirebaseAPI.shared.getMusic(completionHandler: { musicList in
            self.tvList = musicList
            self.tableView.reloadData()
        })
    }
    
    func sort(sortKind: Int) {

        switch sortKind {
        //日付（遅い）
        case 0:
            var a: [Date] = []
            for i in tvList {
                let b = i.data
                var c: [Date] = []
                for j in b {
                    c.append(dateFromString(string: j.time, format: "yy年MM月dd日HH:mm"))
                }
                a.append(c.min()!)
                

            }
            let d = a.indices.sorted{ a[$1] < a[$0]}
            tvList = d.map {self.tvList[$0]}
            print(0)

            //日付け（早い）
        case 1:
            var a: [Date] = []
            for i in tvList {
                let b = i.data
                var c: [Date] = []
                for j in b {
                    c.append(dateFromString(string: j.time, format: "yy年MM月dd日HH:mm"))
                }
                a.append(c.min()!)

            }
            let d = a.indices.sorted{ a[$0] < a[$1]}
            tvList = d.map{self.tvList[$0]}
            print(1)

            //得点（高い）
        case 2:
            var a: [Double] = []
            for i in tvList {
                let b = i.data
                var c: [Double] = []
                for j in b {
                    c.append(j.score)
                }
                a.append(c.max()!)
            }
            let d = a.indices.sorted{ a[$1] < a[$0]}
            tvList = d.map{self.tvList[$0]}
            print(2)

            //得点（低い）
        case 3:
            var a: [Double] = []
            for i in tvList {
                let b = i.data
                var c: [Double] = []
                for j in b {
                    c.append(j.score)
                }
                a.append(c.max()!)
            }
            let d = a.indices.sorted{ a[$0] < a[$1]}
            tvList = d.map{self.tvList[$0]}
            print(3)

            //五十音(早い）
        case 4: tvList.sort(by: {$0.musicName < $1.musicName})
            print(4)

            //五十音(遅い）
        case 5: tvList.sort(by: {$1.musicName < $0.musicName})
            print(5)

            //アーティスト（早い）
        case 6: tvList.sort(by: {($0.artistName, $0.musicName) < ($1.artistName, $1.musicName)})
            print(6)

            //アーティスト（遅い）
        case 7: tvList.sort(by: {($1.artistName, $0.musicName) < ($0.artistName, $1.musicName)})
            print(7)

        default: print("error sort")
        }
        tableView.reloadData()
    }
    
    
    func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    //改行したら自動的にキーボードを非表示にする
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
}
