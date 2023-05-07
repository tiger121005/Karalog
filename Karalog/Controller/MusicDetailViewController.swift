//
//  MusicDetailViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import DZNEmptyDataSet

class MusicDetailViewController: UIViewController {
    
    var musicName = ""
    var music: [MusicList] = []
    var tvList: [MusicData] = []
    var musicID = ""
    //次の画面に渡す値
    var time = ""
    var score = ""
    var key = ""
    var model = ""
    var comment = ""
    
    @IBOutlet var bestLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        navigationItem.title = musicName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
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
            nextView.musicID = musicID
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
    }
    

    func selectBest() {
        
        var scoreList: [Double] = []
        for data in tvList {
            scoreList.append(data.score)
        }
        
        bestLabel.text = String(format: "%.3f", scoreList.max()!)
    }
    
    func getData() {
        tvList = Manager.shared.musicList.first(where: {$0.id == musicID})!.data
        selectBest()
        print(Manager.shared.musicList.first(where: {$0.id == musicID})!.data)
        tableView.reloadData()
    }
}

extension MusicDetailViewController: UITableViewDelegate {
    //セルが選択されたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        time = tvList[indexPath.row].time
        score = String(format: "%.3f", tvList[indexPath.row].score)
        key = String(tvList[indexPath.row].key)
        model = tvList[indexPath.row].model
        comment = tvList[indexPath.row].comment
        performSegue(withIdentifier: "toDetail", sender: nil)
         tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //削除のラベルを変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
}

extension MusicDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tvList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = String(format: "%.3f", tvList[indexPath.row].score)//追加の際入力した文字を表示
        cell.detailTextLabel?.text = tvList[indexPath.row].time + "　　　キー:　" + String(tvList[indexPath.row].key) + "　　　機種:　" + tvList[indexPath.row].model
        
        return cell
    }
    
    //削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if self.tvList.count == 1 {
                let alert = UIAlertController(title: "削除できません", message: "データの数を0にすることはできません", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "削除", message: "データを削除します" , preferredStyle: .alert)
                let cancel = UIAlertAction(title: "キャンセル", style: .default)
                let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                    let a = self.tvList[indexPath.row]
                    self.tvList.remove(at: indexPath.row)
                    FirebaseAPI.shared.deleteMusicDetail(musicID: self.musicID, data: a, completionHandler: {_ in
                        
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.selectBest()
                        
                    })
                    
                    
                }
                alert.addAction(cancel)
                alert.addAction(delete)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension MusicDetailViewController: DZNEmptyDataSetSource {
    //tableViewが空の時(テキスト)
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "曲の詳細データがありません")
    }
    
    //tableViewが空の時(画像)
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return Material.shared.mic.resized(toWidth: 250)
    }
}

extension MusicDetailViewController: DZNEmptyDataSetDelegate {
    
}
