//
//  AddListMusicViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit


//MARK: - AddListMusicViewController

class AddListMusicViewController: UIViewController {
    
    var cvList: [MusicList] = []
    var imageList: [UIImage] = []
    
    var fromFav: Bool = false
    var idList: [String] = []
    var listID: String = ""
    
    
    //MARK: - UI objects
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var addBtn: UIBarButtonItem!
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        searchBar.delegate = self
        title = "リストに追加"
    }
    
    
    //MARK: - Setup
    
    func setupCollectionView() {
        Task {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(UINib(nibName: "MusicCell", bundle: nil), forCellWithReuseIdentifier: "musicCell")
            
            //セクションの高さ
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
            collectionView.collectionViewLayout = layout
            
            collectionView.keyboardDismissMode = .onDrag
            collectionView.allowsMultipleSelection = true
            collectionView.allowsMultipleSelectionDuringEditing = true
            collectionView.isEditing = true
            
            cvList = manager.musicList
            let list = self.cvList
            for i in 0..<list.count {
                
                guard let image = await UIImage.fromUrl(url: list[i].musicImage) else {
                    cvList.remove(at: i)
                    continue
                }
                imageList.append(image)
            }
            collectionView.reloadData()
        }
    }
    
    
    //MARK: - UI interaction
    
    @IBAction func add() {
        if self.collectionView.indexPathsForSelectedItems != nil {
            let indexPathList = self.collectionView.indexPathsForSelectedItems!.sorted{ $1.row < $0.row}
            
            let alert = UIAlertController(title: "追加", message: String(indexPathList.count) + "個の曲のデータを追加します", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                
            }
            let delete = UIAlertAction(title: "追加", style: .default) { [self] (action) in
                idList = []
                for i in indexPathList {
                    idList.append(cvList[i.row].id!)
                    
                }
                if fromFav == false {
                    
                    for i in 0..<indexPathList.count {
                        musicFB.addMusicToList(musicID: idList[i], listID: listID, completionHandler: {_ in})
                    }
                } else {
                    for i in 0..<indexPathList.count {
                        musicFB.favoriteUpdate(id: idList[i], favorite: false, completionHandler: {_ in })
                        
                    }
                }
                fromAddListMusic = true
                navigationController?.popViewController(animated: true)
                
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


//MARK: - UICollectionViewDataSource
extension AddListMusicViewController: UICollectionViewDataSource {
    
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
            for j in b {
                c.append(j.score)
            }
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
        let high = list[n - 1].data.map{$0.score}.max() ?? 0
        var medium: Double = 0.0
        if cvList.count > 3 {
            medium = list[m - 1].data.map{$0.score}.max() ?? 0
        }
        
        cell.musicLabel?.text = cvList[indexPath.row].musicName
        cell.artistLabel?.text = cvList[indexPath.row].artistName
        cell.musicImage?.image = imageList[indexPath.row]
        
        
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
        
        cell.favoriteBtn.isHidden = true
        
        let selectedBgView = UIView()
        selectedBgView.backgroundColor = .darkGray
        cell.selectedBackgroundView = selectedBgView
        
        return cell
    }
    
    
}


//MARK: - UICollectionViewDelegate
extension AddListMusicViewController: UICollectionViewDelegate {
    func collectionView(_ tableView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension AddListMusicViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 20
        return CGSize(width: width, height: 90)
    }
}


//MARK: - UISearchBarDelegate

extension AddListMusicViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        cvList = []
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
