//
//  AddDetailViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit


//MARK: - AddDetailViewController

class AddDetailViewController: UIViewController {

    var alertCtl: UIAlertController!
    var time: String!
    var fromWanna: Bool = false
    var musicName: String = ""
    var artistName: String = ""
    var musicImage: String!
    var musicID: String = ""
    var wannaID: String = ""
    var selectedMenuType = ModelMenuType.未選択
    var sliderValue: Float = 0
    var callView: Bool = true
    var scaleList: [UIView] = []
    var postEnable: Bool = false
    var category: [String] = []
    
    
    //MARK: - UI objects
    
    @IBOutlet var scoreTF: UITextField!
    @IBOutlet var customSlider: CustomSliderView!
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var modelBtn: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var addBtn: CustomButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var postBox: PostBox!
    @IBOutlet var categoryView: UIView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupModelButton()
        setupKeyLabel()
        setupTableView()
        setupCategoryView()
        setupView()
        title = "記録を追加"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSlider()
    }
    
    
    //MARK: - Setup
    
    func setupView() {
        textView.layer.cornerRadius = 5
        textView.layer.cornerCurve = .continuous
        
    }
    
    func setupModelButton() {
        modelBtn.layer.cornerRadius = modelBtn.frame.height * 0.5
        modelBtn.layer.cornerCurve = .continuous
        modelBtn.layer.borderColor = UIColor.imageColor.cgColor
        modelBtn.layer.borderWidth = 2
        modelBtn.tintColor = UIColor.imageColor
        modelBtn.backgroundColor = .clear
        modelBtn.layer.shadowColor = UIColor.imageColor.cgColor
        modelBtn.layer.shadowOpacity = 0.8
        modelBtn.layer.shadowRadius = 3
        modelBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
        configureMenuButton()
    }
    
    func configureMenuButton() {
        var actions = [UIMenuElement]()
        // HIGH
        actions.append(UIAction(title: ModelMenuType.未選択.rawValue, image: nil, state: self.selectedMenuType == ModelMenuType.未選択 ? .on : .off,
                                handler: { (_) in
                                    self.selectedMenuType = .未選択
                                    // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
                                    self.configureMenuButton()
                                }))
        // MID
        actions.append(UIAction(title: ModelMenuType.DAM.rawValue, image: nil, state: self.selectedMenuType == ModelMenuType.DAM ? .on : .off,
                                handler: { (_) in
                                    self.selectedMenuType = .DAM
                                    // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
                                    self.configureMenuButton()
                                }))
        // LOW
        actions.append(UIAction(title: ModelMenuType.JOYSOUND.rawValue, image: nil, state: self.selectedMenuType == ModelMenuType.JOYSOUND ? .on : .off,
                                handler: { (_) in
                                    self.selectedMenuType = .JOYSOUND
                                    // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
                                    self.configureMenuButton()
                                }))

        // UIButtonにUIMenuを設定
        modelBtn.menu = UIMenu(title: "", options: .displayInline, children: actions)
        // こちらを書かないと表示できない場合があるので注意
        modelBtn.showsMenuAsPrimaryAction = true
        // ボタンの表示を変更
        modelBtn.setTitle(self.selectedMenuType.rawValue, for: .normal)
    }
    
    func setupKeyLabel() {
        keyLabel.layer.borderColor = CGColor(red: 0.93, green: 0.47, blue: 0.18, alpha: 1.0)
        keyLabel.layer.borderWidth = 2
        keyLabel.layer.cornerRadius = keyLabel.frame.height * 0.5
        keyLabel.layer.cornerCurve = .continuous
        keyLabel.layer.shadowColor = UIColor.imageColor.cgColor
        keyLabel.layer.shadowOpacity = 0.8
        keyLabel.layer.shadowRadius = 3
        keyLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.layer.cornerRadius = 5
        tableView.layer.cornerCurve = .continuous
    }
    
    func setupCategoryView() {
        
        categoryView.isHidden = true
        categoryLabel.layer.cornerRadius = 5
        categoryLabel.layer.cornerCurve = .continuous
        categoryLabel.layer.masksToBounds = true
    }
    
    func setCategory() {
        categoryLabel.numberOfLines = 0
        if let _indexPathList = self.tableView.indexPathsForSelectedRows {
            var text: String = ""
            var newLine: Bool = false
            for i in _indexPathList {
                if newLine {
                    text += "\n#" + material.categoryList[i.row]
                    category.append(material.categoryList[i.row])
                }else {
                    text = "#" + material.categoryList[i.row]
                    newLine = true
                    category = [material.categoryList[i.row]]
                    
                }
            }
            categoryLabel.text = text
        } else {
            categoryLabel.text = ""
            category = []
        }
    }
    
    func setupSlider() {
        if callView {
            scaleList = []
            for i in 0...14 {
                let view = UIView(frame: CGRect(x: CGFloat((customSlider.slider.bounds.width - 31) * CGFloat(i) / 14) + 12.5, y: customSlider.slider.frame.maxY, width: 6, height: 6))
                
                if i <= 7 {
                    view.backgroundColor = UIColor.imageColor
                } else {
                    view.backgroundColor = UIColor.label
                }
                view.layer.cornerRadius = 3
                
                customSlider.slider.addSubview(view)
                
                customSlider.bringSubviewToFront(customSlider.slider)
                
                scaleList.append(view)
            }
            callView = false
        }
    }
    
    func post() {
        if postEnable {
            let content = "得点:　\(scoreTF.text!)\nキー:　\(keyLabel.text!)\n機種:　\(selectedMenuType.rawValue)\nコメント:　\(textView.text!)"
            postFB.post(musicName: musicName, artistName: artistName, musicImage: musicImage, content: content, category: category)
        }
    }
    
    func add() {
        
        let df = DateFormatter()
        df.dateFormat = "yy年MM月dd日HH:mm"
        df.timeZone = TimeZone.current
        let time = df.string(from: Date())
        
        let filterMusic = manager.musicList.filter {$0.musicName == musicName && $0.artistName == artistName}
        if !filterMusic.isEmpty {
            guard let id = filterMusic.first?.id else {
                let alert = UIAlertController(title: "エラー", message: "エラーが発生しました", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
                return
            }
            musicFB.addMusicDetail(musicID: id, time: time, score: Double(scoreTF.text!)!, key: Int(keyLabel.text!)!, model: selectedMenuType.rawValue, comment: textView.text!)
        } else {
            musicFB.addMusic(musicName: musicName, artistName: artistName, musicImage: musicImage, time: time, score: Double(scoreTF.text!)!, key: Int(keyLabel.text!)!, model: selectedMenuType.rawValue, comment: textView.text!, completionHandler: {_ in
                
            })
            
        }
        
        if fromWanna {
            listFB.deleteWanna(wannaID: wannaID)
        }
    }
    
    
    //MARK: - UI interaction

    @IBAction func editingChanged(_ sender: Any) {
        
        
        guard let _scoreValue = scoreTF.text else { return }
        
        if Double(_scoreValue) ?? 0.0 > 100 {
            scoreTF.text = String(Double(scoreTF.text!)! / 10)
        }
        // textField内の文字数
        let textFieldNumber = _scoreValue.count
        
        if textFieldNumber > 6 && Double(_scoreValue) ?? 0.0 != 100 {
            scoreTF.text = String(_scoreValue.prefix(6))
        } else if _scoreValue == "100.0000" {
            scoreTF.text = String(_scoreValue.prefix(7))
        }
    }
    
    @IBAction func slider(_ sender: UISlider) {
        
        let preValue = round(sender.value)
        keyLabel.text = String(Int(preValue))
        if keyLabel.text == "-0.0"{
            keyLabel.text = "0.0"
        }
        customSlider.slider.setValue(preValue, animated: false)
        if preValue != sliderValue {
            function.playImpact(type: .impact(.light))
            sliderValue = preValue
            for i in 0..<scaleList.count {
                if i  <= Int(sliderValue) + 7 {
                    scaleList[i].backgroundColor = UIColor.imageColor
                } else {
                    scaleList[i].backgroundColor = UIColor.label
                }
            }
        }
    }
    
    @IBAction func tapAddBtn() {
        if Double(scoreTF.text!) != nil {
            
            post()
            add()
            
            navigationController?.popViewController(animated: true)
        }else{
            func alert(title: String, message: String) {
                alertCtl = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertCtl.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertCtl, animated: true)
            }
            alert(title: "入力ミス", message: "値がうまく入力されていません")
        }
    }
    
    @IBAction func tapCheckBox() {
        postEnable.toggle()
        categoryView.isHidden.toggle()
    }
    
}


//MARK: - UITableViewDelegate

extension AddDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if tableView.indexPathsForSelectedRows!.count <= 5 {
            cell?.accessoryType = .checkmark
            setCategory()
        }else{
            func alert(title: String, message: String) {
                alertCtl = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertCtl.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertCtl, animated: true)
            }
            alert(title: "入力ミス", message: "選択できるのは5個までです")
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .none
        setCategory()
    }
}


//MARK: - UITableViewDataSource

extension AddDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return material.categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = material.categoryList[indexPath.row]
        cell.selectionStyle = .none
        // セルの状態を確認しチェック状態を反映する
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        if selectedIndexPaths != nil && (selectedIndexPaths?.contains(indexPath))! {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
