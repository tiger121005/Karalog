//
//  AddDetailViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit

class AddDetailViewController: UIViewController {

    var alertCtl: UIAlertController!
    var time: String!
    var fromWanna = false
    var musicName = ""
    var artistName = ""
    var musicImage: Data!
    var musicID = ""
    var wannaID = ""
    var selectedMenuType = modelMenuType.未選択
    var sliderValue: Float = 0
    var callView = true
    var scaleList: [UIView] = []
    var post = false
    var category: [String] = []
    var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet var scoreTF: UITextField!
    @IBOutlet var customSlider: CustomSliderView!
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var modelBtn: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var addBtn: CustomButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var checkBox: UIView!
    @IBOutlet var categoryView: UIView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextField()
        configureMenuButton()
        setupKeyLabel()
        getTimingKeyboard()
        setupKeyboard()
        setupCategoryView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if callView {
            scaleList = []
            for i in 0...14 {
                let view = UIView(frame: CGRect(x: CGFloat((customSlider.slider.bounds.width - 31) * CGFloat(i) / 14) + 12.5, y: customSlider.slider.frame.maxY, width: 6, height: 6))
                
                if i <= 7 {
                    view.backgroundColor = UIColor(named: "imageColor")
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
    
    func setupTextField() {
        scoreTF.delegate = self
    }
    
    func configureMenuButton() {
        var actions = [UIMenuElement]()
        // HIGH
        actions.append(UIAction(title: modelMenuType.未選択.rawValue, image: nil, state: self.selectedMenuType == modelMenuType.未選択 ? .on : .off,
                                handler: { (_) in
                                    self.selectedMenuType = .未選択
                                    // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
                                    self.configureMenuButton()
                                }))
        // MID
        actions.append(UIAction(title: modelMenuType.DAM.rawValue, image: nil, state: self.selectedMenuType == modelMenuType.DAM ? .on : .off,
                                handler: { (_) in
                                    self.selectedMenuType = .DAM
                                    // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
                                    self.configureMenuButton()
                                }))
        // LOW
        actions.append(UIAction(title: modelMenuType.JOYSOUND.rawValue, image: nil, state: self.selectedMenuType == modelMenuType.JOYSOUND ? .on : .off,
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
        keyLabel.clipsToBounds = true
    }
    
    func getTimingKeyboard() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupKeyboard() {
         tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.isEnabled = false
    }
    
    func setupCategoryView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        categoryView.isHidden = true
    }
    
    func setupCategory() {
        categoryLabel.numberOfLines = 0
        if let _indexPathList = self.tableView.indexPathsForSelectedRows {
            var text = ""
            var newLine = false
            for i in _indexPathList {
                if newLine {
                    text += "\n#" + Material.shared.categoryList[i.row]
                    category.append(Material.shared.categoryList[i.row])
                }else {
                    text = "#" + Material.shared.categoryList[i.row]
                    newLine = true
                    category = [Material.shared.categoryList[i.row]]
                    
                }
            }
            categoryLabel.text = text
        } else {
            categoryLabel.text = ""
            category = []
        }
    }
    
    

    @IBAction func editingChanged(_ sender: Any) {
        if Double(scoreTF.text!) ?? 0 >= 100 {
            scoreTF.text = String(Double(scoreTF.text!)! / 10)
        }
        
        guard let _scoreValue = scoreTF.text else { return }
        
        let maxLength: Int = 6
        
        // textField内の文字数
        let textFieldNumber = scoreTF.text?.count ?? 0
        
        if textFieldNumber > maxLength {
            scoreTF.text = String(_scoreValue.prefix(maxLength))
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
            Function.shared.playImpact(type: .impact(.light))
            sliderValue = preValue
            for i in 0...scaleList.count - 1 {
                if i  <= Int(sliderValue) + 7 {
                    scaleList[i].backgroundColor = UIColor(named: "imageColor")
                } else {
                    scaleList[i].backgroundColor = UIColor.label
                }
            }
        }
    }
    
    @IBAction func tapAddBtn() {
        if Double(scoreTF.text!) != nil {
            if post {
                let content = "得点:　\(scoreTF.text!)\nキー:　\(keyLabel.text!)\n機種:　\(selectedMenuType.rawValue)\nコメント:　\(textView.text!)"
                FirebaseAPI.shared.post(musicName: musicName, artistName: artistName, musicImage: musicImage, content: content, category: category)
            }
            let df = DateFormatter()
            df.dateFormat = "yy年MM月dd日HH:mm"
            df.timeZone = TimeZone.current
            time = df.string(from: Date())
            
            if fromWanna {
                FirebaseAPI.shared.addMusic(musicName: musicName, artistName: artistName, musicImage: musicImage, time: time!, score: Double(scoreTF.text!)!, key: Int(keyLabel.text!)!, model: String(selectedMenuType.rawValue), comment: textView.text, completionHandler: {_ in})
                
                FirebaseAPI.shared.deleteWanna(wannaID: wannaID)
            }else{
                FirebaseAPI.shared.addMusicDetail(musicID: musicID, time: time, score: Double(scoreTF.text!)!, key: Int(keyLabel.text!)!, model: String(selectedMenuType.rawValue), comment: textView.text)
            }
            self.navigationController?.popViewController(animated: true)
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
        post.toggle()
        categoryView.isHidden.toggle()
    }
    
    //機種設定
    enum modelMenuType: String {
        case 未選択 = "未選択"
        case DAM = "DAM"
        case JOYSOUND = "JOYSOUND"
    }
    
    //textViewを開いたときにViewを上にずらして隠れないようにする
    // キーボード表示通知の際の処理
    @objc func keyboardWillShow(_ notification: Notification) {
        // キーボード、画面全体、textFieldのsizeを取得
        let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        guard let _keyboardHeight = rect?.size.height else { return }
        
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaTop = self.view.safeAreaInsets.top
        let safeAreaBottom = self.view.safeAreaInsets.bottom
        let safeAreaHeight = screenHeight - safeAreaBottom - safeAreaTop
        let scrollPosition = scrollView.contentOffset.y
        let keyboardPositionY = safeAreaHeight + safeAreaBottom - _keyboardHeight
        print(keyboardPositionY)
            
        if keyboardPositionY + scrollPosition <= textView.frame.maxY && textView.isFirstResponder {
            scrollView.setContentOffset(CGPoint.init(x: 0, y: textView.frame.maxY - keyboardPositionY + 10), animated: true)
        }
        
        tapGesture.isEnabled = true
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
//        let screenHeight = UIScreen.main.bounds.height
//        let safeAreaTop = self.view.safeAreaInsets.top
//        let safeAreaBottom = self.view.safeAreaInsets.bottom
//        let safeAreaHeight = screenHeight - safeAreaBottom - safeAreaTop
//        // ナビゲーションバーの高さを取得する
//        if checkBox.frame.maxY - screenHeight > 0 {
//            scrollView.setContentOffset(CGPoint.init(x: 0, y: checkBox.frame.maxY - screenHeight), animated: true)
//        }else{
//            scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
//        }
        tapGesture.isEnabled = false
    }
    
    @objc func closeKeyboard(_ sender : UITapGestureRecognizer) {
        if textView.isFirstResponder {
            self.textView.resignFirstResponder()
        }else if scoreTF.isFirstResponder {
            self.scoreTF.resignFirstResponder()
        }
    }
}

extension AddDetailViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let _numCount = scoreTF.text else { return }
        
        if _numCount.count > 6 {
            scoreTF.text = String(_numCount.prefix(6))
        }
    }
    
    //改行したら自動的にキーボードを非表示にする
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        scoreTF.resignFirstResponder()
        return true
    }
}

extension AddDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if tableView.indexPathsForSelectedRows!.count <= 5 {
            cell?.accessoryType = .checkmark
            setupCategory()
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
        setupCategory()
    }
}

extension AddDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Material.shared.categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = Material.shared.categoryList[indexPath.row]
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
