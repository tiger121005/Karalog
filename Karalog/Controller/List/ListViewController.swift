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
    var cvList: [MusicList] = []
    var imageList: [UIImage] = []
    
    var judgeSort: String = Sort.late.rawValue
    var allSelected: Bool = false
    var idList: [String] = []
    
    var selectedID: String = ""
    var musicName: String = ""
    var artistName: String = ""
    var musicImage: String!
    let sortList: [String] = ["追加順(遅)", "追加順(早)", "スコア順(高)", "スコア順(低)", "曲名順(早)", "曲名順(遅)", "アーティスト順(早)", "アーティスト順(遅)"]
    
    
    //MARK: - UI objects
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var editBtn: UIBarButtonItem!
    @IBOutlet var addBtn: UIBarButtonItem!
    var selectBtn: UIBarButtonItem!
    var doneBtn: UIBarButtonItem!
    var allSelectBtn: UIBarButtonItem!
    var addAlert: UIAlertController!
    
    
    //MARK: - View Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
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
        switch Segue(rawValue: segue.identifier) {
        case .addListMusic:
            let nextView = segue.destination as! AddListMusicViewController
            if listID == "favorite" {
                nextView.fromFav = true
            } else {
                nextView.fromFav = false
                nextView.listID = listID
            }
            
        case .musicDetail:
            let nextView = segue.destination as! MusicDetailViewController
            nextView.musicID = selectedID
            nextView.musicName = musicName
            nextView.artistName = artistName
            nextView.musicImage = musicImage
            
        case .addWanna:
            let nextView = segue.destination as! GetMusicViewController
            nextView.fromList = true
            
        case .addDetail:
            let nextView = segue.destination as! AddDetailViewController
            
            nextView.fromWanna = true
            nextView.musicName = musicName
            nextView.artistName = artistName
            nextView.musicImage = musicImage
            nextView.wannaID = selectedID
            
        case .addToList:
            let nextView = segue.destination as! AddToListViewController
            idList = []
            if let list = collectionView.indexPathsForSelectedItems {
                let indexPathList = list.sorted{ $1.row < $0.row}
                for i in indexPathList {
                    if let id = cvList[i.row].id {
                        idList.append(id)
                    }
                }
            } else {
                idList = [selectedID]
            }
            nextView.idList = idList
            
        default:
            break
        }
        
    }
    
    
    //MARK: - Setup
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "MusicCell", bundle: nil), forCellWithReuseIdentifier: "musicCell")
        
        //セクションの高さ
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        collectionView.collectionViewLayout = layout
        
        collectionView.allowsMultipleSelectionDuringEditing = true
        collectionView.keyboardDismissMode = .onDrag
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    
    func setupBarButtonItem() {
        let delete = UIAction(title: "削除", image: UIImage.trash, handler: { [self]_ in
            if self.collectionView.indexPathsForSelectedItems != nil {
                let indexPathList = self.collectionView.indexPathsForSelectedItems!.sorted{ $1.row < $0.row}
                let alert = UIAlertController(title: "削除", message: String(indexPathList.count) + "個の曲のデータをリストから削除します", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    
                }
                let delete = UIAlertAction(title: "削除", style: .destructive) { [self] (action) in
                    idList = []
                    for i in indexPathList {
                        idList.append(cvList[i.row].id!)
                        cvList.remove(at: i.row)
                        imageList.remove(at: i.row)
                    }
                    for id in idList {
                        if listID == "favorite" {
                            musicFB.favoriteUpdate(id: id, favorite: true, completionHandler: { _ in })
                        }else if listID == "wanna" {
                            listFB.deleteWanna(wannaID: id)
                        }else{
                            musicFB.deleteMusicFromList(selectedID: id, listID: listID, completionHandler: {_ in })
                        }
                    }
                    
                    collectionView.deleteItems(at: indexPathList)
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
        if listID != "wanna" {
            let addToList = UIAction(title: "リストに追加", image: UIImage.folder, handler: { [self]_ in
                segue(identifier: .addToList)
            })
            let selectMenu = UIMenu(title: "", children: [delete, addToList])
            selectBtn = UIBarButtonItem(title: "", image: UIImage.ellipsisCircle.withConfiguration(UIImage.SymbolConfiguration(weight:
                    .bold)), menu: selectMenu)
        } else {
            let selectMenu = UIMenu(title: "", children: [delete])
            selectBtn = UIBarButtonItem(title: "", image: UIImage.ellipsisCircle.withConfiguration(UIImage.SymbolConfiguration(weight:
                    .bold)), menu: selectMenu)
        }
        
        addBtn.image = UIImage.plus.withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
        editBtn.image = UIImage.ellipsisCircle.withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
        
        allSelectBtn = UIBarButtonItem(title: "全て選択", style: .plain, target: self, action: #selector(tapAllSelectBtn(_:)))
        
        doneBtn = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(tapDoneBtn(_:)))
        
        self.navigationItem.rightBarButtonItems = [editBtn, addBtn, selectBtn]
        self.navigationItem.leftBarButtonItems = [doneBtn, allSelectBtn]
        self.navigationItem.leftItemsSupplementBackButton = true
        
        selectBtn.isHidden = true
        doneBtn.isHidden = true
        allSelectBtn.isHidden = true
        
        title = listName
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:  " ", style:  .plain, target: nil, action: nil)
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
            Task {
                if judgeSort != Sort.late.rawValue {
                    judgeSort = Sort.late.rawValue
                    let list = await utility.sort(sortKind: judgeSort, updateList: cvList)
                    self.cvList = list
                    await reloadData()
                    
                    
                }else{
                    judgeSort = Sort.early.rawValue
                    let list = await utility.sort(sortKind: judgeSort, updateList: cvList)
                    self.cvList = list
                    await reloadData()
                }
                
                
                UserDefaultsKey.judgeSort.set(value: judgeSort)
                self.createMenu()
            }
        }),
                        UIAction(title: "スコア", handler: { [self] _ in
            Task {
                if judgeSort != Sort.scoreHigh.rawValue{
                    judgeSort = Sort.scoreHigh.rawValue
                    let list = await utility.sort(sortKind: judgeSort, updateList: cvList)
                    self.cvList = list
                    await reloadData()
                    
                    
                }else{
                    judgeSort = Sort.scoreLow.rawValue
                    let list = await utility.sort(sortKind: judgeSort, updateList: cvList)
                    self.cvList = list
                    await reloadData()
                    
                    
                }
                UserDefaultsKey.judgeSort.set(value: judgeSort)
                self.createMenu()
            }
        }),
                        UIAction(title: "曲名", handler: { [self] _ in
            Task {
                if judgeSort != Sort.musicDown.rawValue{
                    judgeSort = Sort.musicDown.rawValue
                    let list = await utility.sort(sortKind: judgeSort, updateList: cvList)
                    self.cvList = list
                    await reloadData()
                    
                    
                }else{
                    judgeSort = Sort.musicUp.rawValue
                    let list = await utility.sort(sortKind: judgeSort, updateList: cvList)
                    self.cvList = list
                    await reloadData()
                    
                }
                UserDefaultsKey.judgeSort.set(value: judgeSort)
                self.createMenu()
            }
        }),
                        UIAction(title: "アーティスト", handler: { [self] _ in
            Task {
                if judgeSort != Sort.artistDown.rawValue{
                    judgeSort = Sort.artistDown.rawValue
                    let list = await utility.sort(sortKind: judgeSort, updateList: cvList)
                    self.cvList = list
                    await reloadData()
                    
                    
                }else{
                    judgeSort = Sort.artistUp.rawValue
                    let list = await utility.sort(sortKind: judgeSort, updateList: cvList)
                    self.cvList = list
                    await reloadData()
                    
                    
                    
                }
                UserDefaultsKey.judgeSort.set(value: judgeSort)
                self.createMenu()
            }
        })]
        
        let sorts = UIMenu(title: "並び替え（" + judgeSort + ")", children: subItems)
        
        //editBtn.showsMenuAsPrimaryAction = true
        editBtn.menu = UIMenu(title: "", children: [items, sorts])
    }
    
    func setData() {
        Task {
            cvList = []
            originalList = []
            
            
            if listID == "favorite" {
                cvList = manager.musicList.filter {$0.favorite == true}
                originalList = cvList
            } else if listID == "wanna" {
                guard let wannaList = await listFB.getWanna() else { return }
                self.originalList = wannaList
                self.cvList = self.originalList
            } else {
                cvList = manager.musicList.filter {$0.lists.contains(listID)}
                originalList = cvList
            }
            await reloadData()
        }
    }
    
    func getImage() async {
        imageList = []
        let list = self.cvList
        var updatedList: [MusicList] = []
        if list.count != 0 {
            for i in 0..<list.count {
                if let image = await UIImage.fromUrl(url: list[i].musicImage) {
                    imageList.append(image)
                    updatedList.append(list[i])
                }
            }
            cvList = updatedList
        }
    }
    
    func reloadData() async {
        await getImage()
        collectionView.reloadData()
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
            segue(identifier: .addWanna)
        } else {
            segue(identifier: .addListMusic)
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
        self.collectionView.endEditing(true)
        self.selectBtn.isHidden = true
        self.doneBtn.isHidden = true
        self.allSelectBtn.isHidden = true
        
        let indexPathList = self.collectionView.indexPathsForSelectedItems!.sorted{ $1.row < $0.row }
        for i in indexPathList {
            self.collectionView.deselectItem(at: i, animated: false)
        }
    }
    
    @objc func tapAllSelectBtn(_ sender: UIBarButtonItem) {
        
        if allSelected {
            for i in 0..<cvList.count {
                self.collectionView.deselectItem(at: IndexPath(row: i, section: 0), animated: false)
            }
            allSelectBtn.title = "全て選択"
            allSelected = false
            
        }else{
            for i in 0..<cvList.count {
                self.collectionView.selectItem(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: [])
            }
            allSelectBtn.title = "全て解除"
            allSelected = true
        }
        
    }
    
}


//MARK: - UICollectionViewDataSource

extension ListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cvList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "musicCell", for: indexPath) as! MusicCell
        
        cell.musicLabel?.text = cvList[indexPath.row].musicName
        cell.artistLabel?.text = cvList[indexPath.row].artistName
        cell.musicImage?.image = imageList[indexPath.row]
        
        //最高得点
        if listID != "wanna" {
            var list: [MusicList] = []
            var a: [Double] = []
            for i in cvList {
                let b = i.data
                var c: [Double] = []
                for j in b {
                    c.append(j.score)
                }
                a.append(c.max() ?? 0)
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
            let high = list[n - 1].data.map{$0.score}.max() ?? 0
            var medium: Double = 0.0
            if cvList.count > 3 {
                medium = list[m - 1].data.map{$0.score}.max() ?? 0
            }
            let scoreList = cvList[indexPath.row].data.map{$0.score}
            let max = scoreList.max() ?? 0
            cell.scoreLabel.text = String(format: "%.3f", max)
            let attributedText = NSMutableAttributedString(string: cell.scoreLabel.text!)
            if max >= Double(high) {
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
            } else if max >= Double(medium) && cvList.count > 3 {
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
        } else {
            cell.scoreLabel.isHidden = true
            cell.favoriteBtn.isHidden = true
        }
        
        //お気に入りボタン
        cell.delegate = self
        cell.indexPath = indexPath
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


//MARK: - UICollectionViewDelegate
extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        if listID != "wanna" {
            let addList = UIAction(title: "リストに追加", image: UIImage.folder) {_ in
                self.selectedID = self.cvList[indexPath.row].id!
                self.segue(identifier: .addToList)
            }
            
            let delete = UIAction(title: "削除", image: UIImage.trash) {_ in
                let selectedID = self.cvList[indexPath.row].id
                if self.listID == "favorite" {
                    musicFB.favoriteUpdate(id: selectedID!, favorite: true, completionHandler: {_ in
                        self.cvList.remove(at: indexPath.row)
                        self.collectionView.deleteItems(at: [indexPath])
                    })
                }else if self.listID == "wanna" {
                    listFB.deleteWanna(wannaID: selectedID!)
                    self.cvList.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
                }else{
                    musicFB.deleteMusicFromList(selectedID: selectedID!, listID: self.listID, completionHandler: {_ in
                        self.cvList.remove(at: indexPath.row)
                        self.collectionView.deleteItems(at: [indexPath])
                    })
                }
            }
            
            let menu = UIMenu(title: "選択", image: nil, identifier: nil, options: [], children: [addList, delete])
            let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                menu
            }
            
            return contextMenuConfiguration
        } else {
            let delete = UIAction(title: "削除", image: UIImage.trash) {_ in
                let selectedID = self.cvList[indexPath.row].id
                if self.listID == "favorite" {
                    musicFB.favoriteUpdate(id: selectedID!, favorite: true, completionHandler: {_ in
                        self.cvList.remove(at: indexPath.row)
                        self.collectionView.deleteItems(at: [indexPath])
                    })
                }else if self.listID == "wanna" {
                    listFB.deleteWanna(wannaID: selectedID!)
                    self.cvList.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
                }else{
                    musicFB.deleteMusicFromList(selectedID: selectedID!, listID: self.listID, completionHandler: {_ in
                        self.cvList.remove(at: indexPath.row)
                        self.collectionView.deleteItems(at: [indexPath])
                    })
                }
            }
            
            let menu = UIMenu(title: "選択", image: nil, identifier: nil, options: [], children: [delete])
            let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                menu
            }
            
            return contextMenuConfiguration
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedID = cvList[indexPath.row].id!
        musicName = cvList[indexPath.row].musicName
        artistName = cvList[indexPath.row].artistName
        musicImage = cvList[indexPath.row].musicImage
        if listID == "wanna" && isEditing == false {
            
            segue(identifier: .addDetail)
        } else if isEditing == false{
            
            segue(identifier: .musicDetail)
        }
    }
}


//MARK: - MusicCellDelegate

extension ListViewController: MusicCellDelegate {
    func reloadCell(indexPath: IndexPath) {
        selectedID = cvList[indexPath.row].id!
        musicFB.favoriteUpdate(id: selectedID, favorite: cvList[indexPath.row].favorite, completionHandler: {_ in
            self.cvList[indexPath.row].favorite.toggle()
            self.collectionView.reloadData()
        })
        
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension ListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 20
        return CGSize(width: width, height: 90)
    }
}


//MARK: - UISearchBarDelegate

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Task {
            cvList = []
            if searchText == "" {
                cvList = originalList
            }else{
                for d in originalList {
                    if d.musicName.contains(searchText) {
                        cvList.append(d)
                    }else if d.artistName.contains(searchText) {
                        cvList.append(d)
                    }
                }
            }
            await reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


