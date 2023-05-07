//
//  AddMusicViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import Alamofire

class AddMusicViewController: UIViewController {
    
    var musicName = ""
    var artistName = ""
    var musicImage: Data!
    
    var selectedMenuType = modelMenuType.未選択
    
    var alertCtl: UIAlertController!
    // 編集中のtextViewを保持する変数
    var _activeTextView: UITextView? = nil
    
    @IBOutlet var musicTF: UITextField!
    @IBOutlet var artistTF: UITextField!
    @IBOutlet var scoreTF: UITextField!
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var keySlider: UISlider!
    @IBOutlet var modelBtn: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var addBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextField()
        setupSlider()
        
        configureMenuButton()
        
        setupKeyLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTimingKeyboard()
        
    }
    
    //キーボード以外をタップ時キーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if textView.isFirstResponder {
            self.textView.resignFirstResponder()
        }else if scoreTF.isFirstResponder {
            self.scoreTF.resignFirstResponder()
        }else if musicTF.isFirstResponder {
            musicTF.resignFirstResponder()
        }else if artistTF.isFirstResponder {
            artistTF.resignFirstResponder()
        }
        
    }
    

    
    
    func setupTextField() {
        musicTF.delegate = self
        artistTF.delegate = self
        musicTF.text = musicName
        artistTF.text = artistName
    }
    
    func setupSlider() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        self.keySlider.addGestureRecognizer(tapGestureRecognizer)
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
        notification.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification,object: nil)
    }
    
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
        
        let sliderValue = round(sender.value)
        keyLabel.text = String(Int(sliderValue))
        if keyLabel.text == "-0.0"{
            keyLabel.text = "0.0"
        }
        keySlider.setValue(sliderValue, animated: false)
    }
    
    @IBAction func tapAddBtn(_ sender: Any) {
        
        if Double(scoreTF.text!) != nil {
            let df = DateFormatter()
            df.dateFormat = "yy年MM月dd日HH:mm"
            df.timeZone = TimeZone.current
            let time = df.string(from: Date())
            FirebaseAPI.shared.addMusic(musicName: musicTF.text!, artistName: artistTF.text!, musicImage: musicImage, time: time, score: Double(scoreTF.text!)!, key: Int(keyLabel.text!)!, model: selectedMenuType.rawValue, comment: textView.text!)
            
            //2画面前に戻る
            let screenIndex = navigationController!.viewControllers.count - 3
            self.navigationController?.popToViewController(navigationController!.viewControllers[screenIndex], animated: true)
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
    
    
    
    

    
    //sliderの開始点を自由にする
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {

        let pointTapped: CGPoint = gestureRecognizer.location(in: keySlider)

        let widthOfSlider: CGFloat = keySlider.frame.size.width
        let newValue = pointTapped.x * CGFloat(keySlider.maximumValue - keySlider.minimumValue) / widthOfSlider - CGFloat(keySlider.maximumValue)
        keySlider.setValue(round(Float(newValue)), animated: false)
        slider(keySlider)
    }
    
    //textViewを開いたときにViewを上にずらして隠れないようにする
    // キーボード表示通知の際の処理
    @objc func keyboardWillShow(_ notification: Notification) {
        // 編集中のtextViewを取得
        _activeTextView = textView
        guard let textView = _activeTextView else { return }
        
        // キーボード、画面全体、textFieldのsizeを取得
        let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        guard let keyboardHeight = rect?.size.height else { return }
        let mainBoundsSize = UIScreen.main.bounds.size
        let textViewHeight = textView.frame.height
        
        let textViewPositionY = textView.frame.origin.y + textViewHeight + 10.0
        let keyboardPositionY = mainBoundsSize.height - keyboardHeight
            
        if keyboardPositionY <= textViewPositionY {
            let duration: TimeInterval? = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            UIView.animate(withDuration: duration!) {
            self.view.transform = CGAffineTransform(translationX: 0, y: keyboardPositionY - textViewPositionY)
            }
        }
    }
    
    // キーボード非表示通知の際の処理
    @objc func keyboardWillHide(_ notification: Notification) {
        let duration: TimeInterval? = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!) {
            self.view.transform = CGAffineTransform.identity
        }
    }

    // textViewがタップされた際に呼ばれる
    func textFieldShouldBeginEditing(_ textView: UITextView) -> Bool {
        // 編集中のtextFieldを保持する
        _activeTextView = textView
        return true
    }
    
}

extension AddMusicViewController: UITextFieldDelegate {
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
