//
//  MusicDetailViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import SwiftUI
import DZNEmptyDataSet

class MusicDetailViewController: UIViewController {
    
    var musicName = ""
    var artistName = ""
    var musicImage: Data!
    var music: [MusicList] = []
    var tvList: [MusicData] = []
    var musicID = ""
    var max: Double = 0.0
    var min: Double = 0.0
    //次の画面に渡す値
    var time = ""
    var score = ""
    var key = ""
    var model = ""
    var comment = ""
    
    @IBOutlet var bestLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var graphView: UIView!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        navigationItem.title = musicName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
        setupGraphAndLabel()
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
            nextView.musicName = musicName
            nextView.artistName = artistName
            nextView.musicImage = musicImage
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
        
        
    }
    
    func getData() {
        tvList = Manager.shared.musicList.first(where: {$0.id == musicID})!.data
        selectBest()
        print(Manager.shared.musicList.first(where: {$0.id == musicID})!.data)
        
        tableView.reloadData()
    }
    
    func setupGraphAndLabel() {
        var a: [SampleData] = []
        print(44444444444, tvList.map{$0.time})
        var start = true
        
        for i in tvList {
            let date = xTitle(data: i.time)
            if start == false {
                if date == a[0].date {
                    if i.score >= a[0].score {
                        a[0] = SampleData(date: date, score: i.score)
                    }
                } else {
                    a.insert(SampleData(date: xTitle(data: i.time), score: i.score), at: 0)
                }
            } else {
                a.append(SampleData(date: date, score: i.score))
                start = false
            }
        }
        
        a.reverse()
        
        let scoreList = a.map{$0.score}
        max = scoreList.max()!
        bestLabel.text = String(format: "%.3f", max)
        min = scoreList.min()!
        
        let vc: UIHostingController = UIHostingController(rootView: LineMarkView(sampleData: a, max: max, min: min))
        
        self.addChild(vc)
        graphView.addSubview(vc.view)
        vc.didMove(toParent: self)
        // UIView内で表示されているSwiftUIビューの位置とサイズなどを調整
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: graphView.topAnchor, constant: 0).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: graphView.bottomAnchor, constant: 0).isActive = true
        vc.view.leftAnchor.constraint(equalTo: graphView.leftAnchor, constant: 0).isActive = true
        vc.view.rightAnchor.constraint(equalTo: graphView.rightAnchor, constant: 0).isActive = true
    }
    
    func xTitle(data: String) -> String {
        
        let d = Function.shared.dateFromString(string: data, format: "yy年MM月dd日HH:mm")
        let s = Function.shared.stringFromDate(date: d, format: "MM/dd")
        return s
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
