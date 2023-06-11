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
    var scaleView = UIStackView()
    
    @IBOutlet var scoreTF: UITextField!
    @IBOutlet var keySlider: UISlider!
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var modelBtn: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var addBtn: UIButton!
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var scrollView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextField()
        configureMenuButton()
        setupKeyLabel()
        getTimingKeyboard()
        setupKeyboard()
        
//        let width = keySlider.frame.width - 31
//        let space = (width / 14) - 1
////        print(width)
////        print(space)
//        for i in -7...7 {
//            let scale = UIView()
//            let sliderPosition = Double(CGFloat(keySlider.frame.minX + keySlider.positionX(at: i)))
//            print(keySlider.frame.minX + keySlider.positionX(at: i))
//            scale.frame = CGRect(x: CGFloat(sliderPosition), y: keySlider.frame.maxY + scroll.frame.minY, width: CGFloat(1), height: CGFloat(4))
//            scale.backgroundColor = UIColor.label
//            view.addSubview(scale)
//            scrollView = view
//        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let view = UIView(frame: CGRect(x: keySlider.frame.minX, y: keySlider.frame.maxY, width: keySlider.frame.width, height: CGFloat(4)))
        view.backgroundColor = UIColor(named: "baseColor")
        scaleView.axis = .horizontal
        scaleView.distribution = .equalSpacing
        scaleView.alignment = .fill
        scaleView.translatesAutoresizingMaskIntoConstraints = false
        
        scaleView.frame = CGRect(x: keySlider.frame.minX, y: keySlider.frame.maxY, width: keySlider.frame.width, height: keySlider.frame.height)
        
        view.addSubview(scaleView)
        
        /// Setup StackView's constraints to its superview
        view.topAnchor.constraint(equalTo: scaleView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: scaleView.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: scaleView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: scaleView.trailingAnchor).isActive = true

        
        for _ in 0...14 {
            let scale = UIView()
            scale.frame.size.width = CGFloat(1)
            scale.frame.size.height = CGFloat(4)
            scale.backgroundColor = .label
            scaleView.addArrangedSubview(scale)
        }
        
        print("viewHeight:", view.frame.height)
        print("viewWidth:", view.frame.width)
        dump(view.subviews)
        scrollView.addSubview(view)
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
        notification.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification,object: nil)
        notification.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
//    func setupScale() {
//        keySlider.thumbRadius
//    }

    @IBAction func editingChanged(_ sender: Any) {
        if Double(scoreTF.text!) ?? 0 >= 100 {
            scoreTF.text = String(Double(scoreTF.text!)! / 10)
        }
        
        guard let scoreValue = scoreTF.text else { return }
        
        let maxLength: Int = 6
        
        // textField内の文字数
        let textFieldNumber = scoreTF.text?.count ?? 0
        
        if textFieldNumber > maxLength {
            scoreTF.text = String(scoreValue.prefix(maxLength))
        }
    }
    
    @IBAction func slider(_ sender: UISlider) {
        
        let preValue = round(sender.value)
        keyLabel.text = String(Int(preValue))
        if keyLabel.text == "-0.0"{
            keyLabel.text = "0.0"
        }
        keySlider.setValue(preValue, animated: false)
        if preValue != sliderValue {
            Function.shared.playImpact(type: .impact(.light))
            sliderValue = preValue
        }
    }
    
    @IBAction func tapAddBtn() {
        if Double(scoreTF.text!) != nil {
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
        guard let keyboardHeight = rect?.size.height else { return }
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaTop = self.view.safeAreaInsets.top
        let safeAreaBottom = self.view.safeAreaInsets.bottom
        let safeAreaHeight = screenHeight - safeAreaBottom - safeAreaTop
        let scrollPosition = scroll.contentOffset.y
        // ナビゲーションバーの高さを取得する
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height ?? CGFloat(44)
        let tabbarHeight = self.tabBarController?.tabBar.frame.size.height ?? CGFloat(48)
        let keyboardPositionY = safeAreaHeight - keyboardHeight - navigationBarHeight
        
        print(keyboardPositionY + scrollPosition)
        print(addBtn.frame.maxY)
        print(safeAreaHeight)
            
        if keyboardPositionY + scrollPosition <= addBtn.frame.maxY {
            scroll.setContentOffset(CGPoint.init(x: 0, y: addBtn.frame.maxY - safeAreaHeight + keyboardPositionY - tabbarHeight), animated: true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaTop = self.view.safeAreaInsets.top
        let safeAreaBottom = self.view.safeAreaInsets.bottom
        let safeAreaHeight = screenHeight - safeAreaBottom - safeAreaTop
        // ナビゲーションバーの高さを取得する
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height ?? CGFloat(0)
        if addBtn.frame.maxY - safeAreaHeight > 0 {
            scroll.setContentOffset(CGPoint.init(x: 0, y: addBtn.frame.maxY - safeAreaHeight), animated: true)
        }else{
            scroll.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        }
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
        guard let numCount = scoreTF.text else { return }
        
        if numCount.count > 6 {
            scoreTF.text = String(numCount.prefix(6))
        }
    }
    
    //改行したら自動的にキーボードを非表示にする
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        scoreTF.resignFirstResponder()
        return true
    }
}
