//
//  MusicDetailViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import DZNEmptyDataSet
import FirebaseFirestore

class MusicDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var musicDoc: DocumentReference!
    
    var musicName = ""
    var music: [MusicList] = []
    var musicData: [MusicData] = []
    var musicID = ""
    //次の画面に渡す値
    var time = ""
    var score = ""
    var key = ""
    var model = ""
    var comment = ""
    
    
    @IBOutlet var bestLabel: UILabel!
    
    @IBOutlet var dataTV: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataTV.delegate = self
        dataTV.dataSource = self
        dataTV.rowHeight = 50
        
        self.dataTV.emptyDataSetSource = self
        self.dataTV.emptyDataSetDelegate = self
        
        musicDoc = Firestore.firestore().collection("user").document(UserDefaults.standard.string(forKey: "userID")!).collection("musicList").document(musicID)
        
        navigationItem.title = musicName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()

//        if let mapData = UserDefaults.standard.array(forKey: "addData") {
//            print(mapData)
//            musicData.append(MusicData(time: mapData[0] as! String,
//                                       score: mapData[1] as! Double,
//                                       key: mapData[2] as! Int,
//                                       model: mapData[3] as! String,
//                                       comment: mapData[4] as! String))
//            dataTV.reloadData()
//            UserDefaults.standard.set([], forKey: "addData")
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let nextView = segue.destination as! DetailViewController
            nextView.time = time
            nextView.score = score
            nextView.key = key
            nextView.model = model
            nextView.comment = comment
        }else if segue.identifier == "toAddDetail" {
            let nextView = segue.destination as! AddDetailViewController
            nextView.musicDoc = musicDoc
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        musicData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = String(musicData[indexPath.row].score)//追加の際入力した文字を表示
        cell.detailTextLabel?.text = musicData[indexPath.row].time + "　　　キー:　" + String(musicData[indexPath.row].key) + "　　　機種:　" + musicData[indexPath.row].model
        
        //cell.textLabel?.textAlignment = NSTextAlignment.center//文字位置変更center,right、left
        //cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 20)//文字サイズ、フォント変更
        //cell.textLabel?.textColor = UIColor.black//文字の色変更
        //cell.detailTextLabel?.textColor = UIColor.black
        return cell
    }

    //tableViewが空の時(テキスト)
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "曲の詳細データがありません")
    }
    
    let mic: UIImage = UIImage(systemName: "music.mic.circle.fill")!
    
    //tableViewが空の時(画像)
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return mic.resized(toWidth: 250)
    }
    //セルが選択されたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        time = musicData[indexPath.row].time
        score = String(musicData[indexPath.row].score)
        key = String(musicData[indexPath.row].key)
        model = musicData[indexPath.row].model
        comment = musicData[indexPath.row].comment
        performSegue(withIdentifier: "toDetail", sender: nil)
         tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "削除", message: "データを削除します" , preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                
            }
            let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                self.musicData.remove(at: indexPath.row)
                self.musicDoc.updateData([
                    "data": self.musicDoc!])
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.selectBest()
                tableView.reloadData()
                
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

    func selectBest() {
        print(musicData)
        var scoreList: [Double] = []
        for data in musicData {
            scoreList.append(data.score)
        }
        
        bestLabel.text = String(scoreList.max()!)
    }
    
    func getData() {
        musicDoc.getDocument() { (document, err) in
            if let err = err {
                print("error getting music: \(err)")
            }else{
                self.musicData = []
                self.music = []
                do{
                    self.music.append(try document!.data(as: MusicList.self))
                    self.musicData = self.music[0].data
                }
                catch{
                    print(error)
                }
                self.dataTV.reloadData()
                self.selectBest()
            }
        }
    }
}
