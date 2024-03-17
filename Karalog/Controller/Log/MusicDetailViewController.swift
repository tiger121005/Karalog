//
//  MusicDetailViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import SwiftUI
import DZNEmptyDataSet

var fromAddDetail = false


//MARK: - MusicDetailViewController

class MusicDetailViewController: UIViewController {
    
    var musicName: String = ""
    var artistName: String = ""
    var musicImage: String!
    var music: [MusicList] = []
    var tvList: [MusicData] = []
    var musicID: String = ""
    var max: Double = 0.0
    var min: Double = 0.0
    
    //次の画面に渡す値
    var time: String = ""
    var score: String = ""
    var key: String = ""
    var model: String = ""
    var comment: String = ""
    
    
    //MARK: - UI objects
    
    @IBOutlet var musicImageView: UIImageView!
    @IBOutlet var bestView: UIView!
    @IBOutlet var bestLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var graphView: UIView!
    @IBOutlet var addBtn: UIBarButtonItem!
    var addAlert: UIAlertController!
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBestView()
        setupBarItem()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
        setupGraphAndLabel()
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch Segue(rawValue: segue.identifier) {
        case .detail:
            let nextView = segue.destination as! DetailViewController
            nextView.time = time
            nextView.musicName = musicName
            nextView.artistName = artistName
            nextView.score = score
            nextView.key = key
            nextView.model = model
            nextView.comment = comment
            nextView.musicImage = musicImageView.image
            
        case .addDetail:
            let nextView = segue.destination as! AddDetailViewController
            nextView.musicID = musicID
            nextView.musicName = musicName
            nextView.artistName = artistName
            nextView.musicImage = musicImage
            
        default:
            break
        }
        
    }
    
    
    //MARK: - Setup
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.register(UINib(nibName: "LogCell", bundle: nil), forCellReuseIdentifier: "logCell")
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    func setupBarItem() {
        title = musicName
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:  " ", style:  .plain, target: nil, action: nil)
        addBtn.image = UIImage.plus.withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
    }
    
    func setupBestView() {
        Task {
            let filter = GaussianBlurFilter()
            filter.radius = 5
            filter.setDefaults()
            guard let uiImage = await UIImage.fromUrl(url: musicImage) else { return }
            let ciImage = uiImage.toCIImage()
            filter.inputImage = ciImage
            
            
            if let filteredImage = filter.outputImage {
                
                let context = CIContext(options: nil)
                if let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) {
                    
                    musicImageView.image = UIImage(cgImage: cgImage)
                }
            }
            bestView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            bestView.layer.cornerRadius = bestView.frame.height * 0.5
            bestView.layer.borderWidth = 3
            bestView.layer.borderColor = UIColor.imageColor.cgColor
        }
    }
    
    func getData() {
        tvList = manager.musicList.first(where: {$0.id == musicID})!.data
        tvList.reverse()
        tableView.reloadData()
    }
    
    func setupGraphAndLabel() {
        var a: [SampleData] = []
        var start: Bool = true
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
        
        let scoreList = a.map{$0.score}
        max = scoreList.max()!
        bestLabel.text = String(format: "%.3f", max)
        min = scoreList.min()!
        
        let vc: UIHostingController = UIHostingController(rootView: LineMarkView(sampleData: a, max: max, min: min, maxWidth: UIScreen.main.bounds.width - 1))
        
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
        
        guard let d = utility.dateFromString(string: data, format: "yy年MM月dd日HH:mm") else { return "00年00月00日00:00" }
        let s = utility.stringFromDate(date: d, format: "MM/dd")
        return s
    }
    
    func showMessage() {
        
        if fromAddDetail {
            addAlert = UIAlertController(title: "追加しました", message: "", preferredStyle: .alert)
            present(addAlert, animated: true, completion: nil)
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideAlert), userInfo: nil, repeats: false)
            fromAddDetail = false
        }
    }
    
    
    //MARK: - Objective - C
    
    @objc func hideAlert() {
        addAlert.dismiss(animated: true)
    }
}


//MARK: - UITableViewDelegate

extension MusicDetailViewController: UITableViewDelegate {
    //セルが選択されたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        time = tvList[indexPath.row].time
        score = String(format: "%.3f", tvList[indexPath.row].score)
        key = String(tvList[indexPath.row].key)
        model = tvList[indexPath.row].model
        comment = tvList[indexPath.row].comment
        segue(identifier: .detail)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //削除のラベルを変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
}


//MARK: - UITableViewDataSource

extension MusicDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tvList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath) as! LogCell
        
        cell.scoreLabel?.text = String(format: "%.3f", tvList[indexPath.row].score)//追加の際入力した文字を表示
        cell.scoreLabel?.textColor = .white
        cell.detailLabel?.text = tvList[indexPath.row].time + "　　　キー:　" + String(tvList[indexPath.row].key) + "　　　機種:　" + tvList[indexPath.row].model
        cell.detailLabel?.textColor = .white
        
        
        
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
                    musicFB.deleteMusicDetail(musicID: self.musicID, data: a, completionHandler: {_ in
                        
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.setupGraphAndLabel()
                        
                    })
                    
                    
                }
                alert.addAction(cancel)
                alert.addAction(delete)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}


//MARK: - DZNEmptyDataSource

extension MusicDetailViewController: DZNEmptyDataSetSource {
    //tableViewが空の時(テキスト)
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "曲の詳細データがありません")
    }
    
    //tableViewが空の時(画像)
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.KaralogImage.resized(toWidth: 250)
    }
}


//MARK: - DZNEmptyDataSetDelegate

extension MusicDetailViewController: DZNEmptyDataSetDelegate {
    
}

