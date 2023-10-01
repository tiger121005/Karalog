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
    var cvList: [MusicList] = []
    
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
    
    @IBOutlet var collectionView: UICollectionView!
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
        setupCollectionView()
        setupSearchBar()
        setupBarItem()
        createMenu()
        get()
        title = "HOME"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
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
        
        switch Segue(rawValue: segue.identifier) {
            
        case .addToList:
            let nextView = segue.destination as! AddToListViewController
            idList = []
            guard let items = collectionView.indexPathsForSelectedItems else {
                idList = [musicID]
                return
            }
            let indexPathList = items.sorted{ $1.row < $0.row}
            for i in indexPathList {
                idList.append(cvList[i.row].id!)
            }
            
            nextView.idList = idList
            
        case .musicDetail:
            let nextView = segue.destination as! MusicDetailViewController
            nextView.musicName = musicName
            nextView.artistName = artistName
            nextView.musicID = musicID
            nextView.musicImage = musicImage
            
        default:
            break
        }
        
    
    }
    
    // ステータスバーを黒く
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    //MARK: - Setup
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "MusicCell", bundle: nil), forCellWithReuseIdentifier: "musicCell")
        //セクションの高さ
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        collectionView.collectionViewLayout = layout
       
        collectionView.allowsMultipleSelectionDuringEditing = true
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        refreshCtl.attributedTitle = NSAttributedString(string: "再読み込み中")
        collectionView.addSubview(refreshCtl)
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        
    }
    
    func setupBarItem() {
        let delete = UIAction(title: "削除", image: UIImage.trash, handler: { [self]_ in
            if self.collectionView.indexPathsForSelectedItems != nil {
                let indexPathList = self.collectionView.indexPathsForSelectedItems!.sorted{ $1.row < $0.row}
                let alert = UIAlertController(title: "削除", message: String(indexPathList.count) + "個の曲のデータを削除します", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    
                }
                let delete = UIAlertAction(title: "削除", style: .destructive) { [self] (action) in
                    idList = []
                    for i in indexPathList {
                        idList.append(cvList[i.row].id!)
                    }
                    for i in 0...indexPathList.count - 1 {
                        musicFB.deleteMusic(id: idList[i], completionHandler: {_ in
                            self.cvList.remove(at: indexPathList[i].row)
                            self.collectionView.reloadData()
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
            if self.collectionView.indexPathsForSelectedItems != nil {
                segue(identifier: .addToList)
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
        doneBtn = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(tapDoneBtn(_:)))
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
                
                self.collectionView.inputViewController?.setEditing(true, animated: true)
                
                self.collectionView.allowsMultipleSelection = true
                self.collectionView.isEditing = true
                
                if self.searchBar.isFirstResponder {
                    self.searchBar.resignFirstResponder()
                }
                
                self.idList = []
            })
        ])
        
        let subItems = [UIAction(title: "追加順", handler: { [self] _ in
            if judgeSort != Sort.追加順（遅）.rawValue {
                judgeSort = Sort.追加順（遅）.rawValue
                function.sort(sortKind: judgeSort, updateList: cvList, completionHandler: {list in
                    self.cvList = list
                    self.collectionView.reloadData()
                })
                
            }else{
                judgeSort = Sort.追加順（早）.rawValue
                function.sort(sortKind: judgeSort, updateList: cvList, completionHandler: {list in
                    self.cvList = list
                    self.collectionView.reloadData()
                })
                
            }
            UserDefaultsKey.judgeSort.set(value: judgeSort)
            self.createMenu()
        }),
                        UIAction(title: "スコア", handler: { [self] _ in
            if judgeSort != Sort.得点（高）.rawValue{
                judgeSort = Sort.得点（高）.rawValue
                function.sort(sortKind: judgeSort, updateList: cvList, completionHandler: {list in
                    self.cvList = list
                    self.collectionView.reloadData()
                })
                
            }else{
                judgeSort = Sort.得点（低）.rawValue
                function.sort(sortKind: judgeSort, updateList: cvList, completionHandler: {list in
                    self.cvList = list
                    self.collectionView.reloadData()
                })
                
            }
            UserDefaultsKey.judgeSort.set(value: judgeSort)
            self.createMenu()
        }),
                        UIAction(title: "曲名", handler: { [self] _ in
            if judgeSort != Sort.曲名順（降）.rawValue{
                judgeSort = Sort.曲名順（降）.rawValue
                function.sort(sortKind: judgeSort, updateList: cvList, completionHandler: {list in
                    self.cvList = list
                    self.collectionView.reloadData()
                })
                
            }else{
                judgeSort = Sort.曲名順（昇）.rawValue
                function.sort(sortKind: judgeSort, updateList: cvList, completionHandler: {list in
                    self.cvList = list
                    self.collectionView.reloadData()
                })
            }
            UserDefaultsKey.judgeSort.set(value: judgeSort)
            self.createMenu()
        }),
                        UIAction(title: "アーティスト", handler: { [self] _ in
            if judgeSort != Sort.アーティスト順（降）.rawValue{
                judgeSort = Sort.アーティスト順（降）.rawValue
                function.sort(sortKind: judgeSort, updateList: cvList, completionHandler: {list in
                    self.cvList = list
                    self.collectionView.reloadData()
                })
                
            }else{
                judgeSort = Sort.アーティスト順（昇）.rawValue
                function.sort(sortKind: judgeSort, updateList: cvList, completionHandler: {list in
                    self.cvList = list
                    self.collectionView.reloadData()
                })
                

            }
            UserDefaultsKey.judgeSort.set(value: judgeSort)
            self.createMenu()
        })]
        
        let sorts = UIMenu(title: "並び替え（" + judgeSort + ")", children: subItems)
        
        editBtn.menu = UIMenu(title: "", children: [items, sorts])
    }
    
    func get() {
        musicFB.getMusic(completionHandler: { musicList in
            self.cvList = musicList
            function.sort(sortKind: self.judgeSort, updateList: self.cvList, completionHandler: { list in
                self.cvList = list
                
            })
            self.collectionView.reloadData()
        })
        
    }
    
    func setData() {
        function.sort(sortKind: judgeSort, updateList: manager.musicList, completionHandler: {list in
            self.cvList = list
            self.collectionView.reloadData()
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
    
    func segue(identifier: Segue) {
        let id = identifier.rawValue
        self.performSegue(withIdentifier: id, sender: nil)
    }
    
    
    //MARK: - Objective - C
    
    @objc func tapDoneBtn(_ sender: UIBarButtonItem) {
        self.editBtn.isHidden = false
        self.addBtn.isHidden = false
        self.navigationItem.hidesBackButton = false
        
        super.setEditing(false, animated: true)
        self.collectionView.endEditing(true)
        self.selectBtn.isHidden = true
        self.doneBtn.isHidden = true
        self.allSelectBtn.isHidden = true
    }
    
    @objc func tapAllSelectBtn(_ sender: UIBarButtonItem) {
        
        if allSelected {
            for i in 0...cvList.count - 1 {
                self.collectionView.deselectItem(at: IndexPath(row: i, section: 0), animated: false)
            }
            allSelectBtn.title = "全て選択"
            allSelected = false
            
        }else{
            for i in 0...cvList.count - 1 {
                
                self.collectionView.selectItem(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: [])
                
            }
            allSelectBtn.title = "全て解除"
            allSelected = true
        }
        
    }
    
    @objc func reload() {
        musicFB.getMusic() { list in
            self.cvList = list
            self.searchBar.text = ""
            self.refreshCtl.endRefreshing()
        }
    }
    
    @objc func hideAlert() {
        addAlert.dismiss(animated: true)
    }
    
}


//MARK: - UICollectionViewDataSource

extension MusicViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cvList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "musicCell", for: indexPath) as! MusicCell
        
        var list: [MusicList] = []
        var a: [Double] = []
        for i in cvList {
            let b = i.data
            var c: [Double] = []
            c += b.map{$0.score}
            a.append(c.max()!)
        }
        let d = a.indices.sorted{ a[$1] < a[$0]}
        list = d.map{cvList[$0]}
        
        var n: Int!
        if cvList.count < 10 {
            n = 1
        } else if cvList.count < 40 {
            n = Int(ceil(Double(cvList.count / 10)))
        } else {
            n = Int(ceil(Double(cvList.count / 5)))
        }
        let m = n * 3
        let high = list[n - 1].data.map{$0.score}.max()!
        var medium: Double = 0.0
        if cvList.count > 3 {
            medium = list[m - 1].data.map{$0.score}.max()!
        }
        //cellのdelegateを呼び出して、indexに代入。お気に入りボタンに使用
        cell.delegate = self
        cell.indexPath = indexPath
        
        cell.musicLabel?.text = cvList[indexPath.row].musicName
        cell.artistLabel?.text = cvList[indexPath.row].artistName
        let useImage = UIImage(data: cvList[indexPath.row].musicImage)?.withRenderingMode(.alwaysOriginal)
        cell.musicImage?.image = useImage
        
        //最高得点
        let scoreList = cvList[indexPath.row].data.map{$0.score}
        let max = scoreList.max()
        cell.scoreLabel.text = String(format: "%.3f", max!)
        let attributedText = NSMutableAttributedString(string: cell.scoreLabel.text!)
        if max! >= Double(high) {
            if cell.scoreLabel.text!.count == 7 {
                attributedText.addAttributes(
                    [
                        //一部の文字に反映させたい内容
                        .font: UIFont(name: "Futura Bold", size: 18)!, //フォントサイズを変更
                        .foregroundColor: UIColor.imageColor // テキストカラーを変更
                    ],
                    // sampleUILabelの0文字目から９文字目までに変更内容を反映させる
                    range: NSMakeRange(0, 3)
                )
            } else {
                attributedText.addAttributes(
                    [
                        .font: UIFont(name: "Futura Bold", size: 18)!,
                        .foregroundColor: UIColor.imageColor
                    ],
                    range: NSMakeRange(0, 2)
                )
            }
        } else if max! >= Double(medium) && cvList.count > 3 {
            attributedText.addAttributes(
                [
                    .font: UIFont(name: "Futura Bold", size: 16)!,
                    .foregroundColor: UIColor.subImageColor
                ],
                range: NSMakeRange(0, 2)
            )
        } else {
            attributedText.addAttributes(
                [
                    .font: UIFont(name: "Futura Bold", size: 16)!,
                    .foregroundColor: UIColor.lightGray
                ],
                range: NSMakeRange(0, 2)
            )
        }
        cell.scoreLabel.attributedText = attributedText
        
        //お気に入りボタン
        if cvList[indexPath.row].favorite == false {
            cell.favoriteBtn?.setImage(UIImage.star, for: .normal)
        }else if cvList[indexPath.row].favorite == true {
            cell.favoriteBtn?.setImage(UIImage.starFill, for: .normal)
        }
        
        let selectedBgView = UIView()
        selectedBgView.backgroundColor = .darkGray
        cell.selectedBackgroundView = selectedBgView
        
        return cell
    }
}


//MARK: - MusicCellDelegate

extension MusicViewController: MusicCellDelegate {
    func reloadCell(indexPath: IndexPath) {
        if !isEditing {
            selectedID = cvList[indexPath.row].id!
            musicFB.favoriteUpdate(id: selectedID, favorite: cvList[indexPath.row].favorite, completionHandler: {_ in
                self.cvList[indexPath.row].favorite.toggle()
                self.collectionView.reloadData()
            })
        }
    }
}


//MARK: - UICollectionViewDelegate {

extension MusicViewController: UICollectionViewDelegate {
    
    //長押しした時の処理
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt
                        indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        // ②メニューの定義
        let actionProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            
            let addList = UIAction(title: "リストに追加", image: UIImage.folder) {_ in
                self.segue(identifier: .addToList)
            }
            
            let delete = UIAction(title: "削除", image: UIImage.trash, attributes: .destructive) {_ in
                
                //alert
                let alert = UIAlertController(title: "削除", message: "”" + manager.lists[indexPath.row].listName + "”" + "を削除しますか", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                    
                }
                
                let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                    listFB.deleteList(indexPath: indexPath, completionHandler: {_  in
                        self.collectionView.reloadData()
                    })
                    
                }
                alert.addAction(cancel)
                alert.addAction(delete)
                self.present(alert, animated: true, completion: nil)
                
            }
            

            return UIMenu(title: "編集", image: nil, identifier: nil, children: [addList, delete])
        }

        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: actionProvider)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        

        musicID = cvList[indexPath.row].id
        if isEditing == false {
            musicData = cvList[indexPath.row].data
            musicName = cvList[indexPath.row].musicName
            artistName = cvList[indexPath.row].artistName
            musicImage = cvList[indexPath.row].musicImage
            if searchBar.isFirstResponder {
                searchBar.resignFirstResponder()
            }
            segue(identifier: .musicDetail)
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension MusicViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 10
        return CGSize(width: width, height: 90)
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
        cvList = []
        print(searchText)
        if searchText == "" {
            cvList = manager.musicList
        }else{
            for d in manager.musicList {
                if d.musicName.contains(searchText) {
                    cvList.append(d)
                }else if d.artistName.contains(searchText) {
                    cvList.append(d)
                }
            }
        }
        collectionView.reloadData()
    }
    
    //改行したら自動的にキーボードを非表示にする
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
