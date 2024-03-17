//
//  GetMusicViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/05/25.
//

import UIKit
import Alamofire
import Dispatch


//MARK: - GetMusicViewContoller

class GetMusicViewController: UIViewController {
    
    var musicName: String!
    var artistName: String!
    var musicImage: String!
    
    //itunesの情報を取得
    let decoder: JSONDecoder = JSONDecoder()
    var musicInfoModel: [MusicInfoModel] = []
    var imageList: [UIImage] = []
    
    var fromList: Bool = false
    var resultingText: String = ""
    
    
    //MARK: - UI objects
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupSearchBar()
        
        title = "SEARCH"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch Segue(rawValue: segue.identifier) {
        case .post:
            let nextView = segue.destination as! PostViewController
            nextView.musicName = musicName
            nextView.artistName = artistName
            nextView.musicImage = musicImage
            
        default:
            break
            
        }
    }
    
    
    //MARK: - Setup
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CollectionViewCell2", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell2")
        
        collectionView.keyboardDismissMode = .onDrag
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }
    
    func getMusicArticles(text: String) async -> [MusicInfoModel]? {
        await withCheckedContinuation{ continuation in
            //日本語をパソコン言語になおす
            let parameters = ["term": text, "country": "jp", "limit": "14"]
            //termが検索キーワード　countryが国　limitが数の上限
            //parameterを使ってsearch以降の文を書いている
            AF.request("https://itunes.apple.com/search", parameters: parameters).responseJSON { response in
                //if文みたいなやつ,この場合response.resultがsuccessの時とfailureの時で場合分けをしている
                switch response.result {
                case .success:
                    //doはエラーが出なかった場合 catchはエラーが出たとき
                    do {
                        guard let data = response.data else { return }
                        let iTunesData: ITunesData = try self.decoder.decode(ITunesData.self, from: data)
                        
                        continuation.resume(returning: iTunesData.results)
                        
                    } catch {
                        print("デコードに失敗しました")
                        continuation.resume(returning: nil)
                    }
                case .failure(let error):
                    print("error", error)
                    continuation.resume(returning: nil)
                }
            }
        }
    }
  
}


//MARK: - UICollectionVeiwDelegate

extension GetMusicViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if fromList {
            listFB.addWanna(musicName: musicInfoModel[indexPath.row].trackName,
                                        artistName: musicInfoModel[indexPath.row].artistName,
                            musicImage: musicInfoModel[indexPath.row].artworkUrl100, completionHandler: {_ in
                self.fromList = false
                self.navigationController?.popViewController(animated: true)
            })
            
            
            
        } else {
            musicName = musicInfoModel[indexPath.row].trackName
            artistName = musicInfoModel[indexPath.row].artistName
            musicImage = musicInfoModel[indexPath.row].artworkUrl100
            
            segue(identifier: .post)
        }
    }
}


//MARK: - UICollectionViewDataSource

extension GetMusicViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        musicInfoModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCollectionCell2", for: indexPath) as! CollectionViewCell2
        
        cell.musicLabel?.text = String(musicInfoModel[indexPath.row].trackName)
        cell.artistLabel?.text = String(musicInfoModel[indexPath.row].artistName)
        
        cell.image?.image = imageList[indexPath.row]
            
        
        
        let selectedBgView = UIView()
        selectedBgView.backgroundColor = .gray
        cell.selectedBackgroundView = selectedBgView
        
        return cell
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension GetMusicViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 200)
    }
}


//MARK: - UISearchBarDelegate

extension GetMusicViewController: UISearchBarDelegate {
    //searchBarに値が入力されるごとに呼び出される変数
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Task {
            if searchText == "" {
                musicInfoModel = []
                imageList = []
                collectionView.reloadData()
                return
            }
            guard let results = await getMusicArticles(text: searchText) else { return }
            musicInfoModel = results
            let list = musicInfoModel
            imageList = []
            if musicInfoModel.count != 0 {
                for i in 0..<musicInfoModel.count {
                    guard let image = await UIImage.fromUrl(url: list[i].artworkUrl100) else {
                        musicInfoModel.remove(at: i)
                        return
                    }
                    imageList.append(image)
                }
                collectionView.reloadData()
            }
            
        }
    }
    //改行したら自動的にキーボードを非表示にする
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

