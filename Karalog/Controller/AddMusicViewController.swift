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
    var sliderValue: Float = 0
    var selectedMenuType = modelMenuType.未選択
    var alertCtl: UIAlertController!
    var callView = true
    var scaleList: [UIView] = []
    
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var musicTF: UITextField!
    @IBOutlet var artistTF: UITextField!
    @IBOutlet var scoreTF: UITextField!
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var modelBtn: CustomButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var addBtn: CustomButton!
    @IBOutlet var customSlider: CustomSliderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextField()
        configureMenuButton()
        setupKeyLabel()
        setupKeyboard()
        getTimingKeyboard()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if callView {
            scaleList = []
            for i in 0...14 {
                print(customSlider.slider.bounds.width)
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
        musicTF.delegate = self
        artistTF.delegate = self
        musicTF.text = musicName
        artistTF.text = artistName
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
        notification.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
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
    
    @IBAction func tapAddBtn(_ sender: Any) {
        
        if Double(scoreTF.text!) != nil {
            let df = DateFormatter()
            df.dateFormat = "yy年MM月dd日HH:mm"
            df.timeZone = TimeZone.current
            let time = df.string(from: Date())
            FirebaseAPI.shared.addMusic(musicName: musicTF.text!, artistName: artistTF.text!, musicImage: musicImage, time: time, score: Double(scoreTF.text!)!, key: Int(keyLabel.text!)!, model: selectedMenuType.rawValue, comment: textView.text!, completionHandler: {_ in
                //2画面前に戻る
                let screenIndex = self.navigationController!.viewControllers.count - 3
                self.navigationController?.popToViewController(self.navigationController!.viewControllers[screenIndex], animated: true)
            })
            
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
        guard let _keyboardHeight = rect?.size.height else { return }
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaTop = self.view.safeAreaInsets.top
        let safeAreaBottom = self.view.safeAreaInsets.bottom
        let safeAreaHeight = screenHeight - safeAreaBottom - safeAreaTop
        let scrollPosition = scroll.contentOffset.y
        // ナビゲーションバーの高さを取得する
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height ?? CGFloat(44)
        let tabbarHeight = self.tabBarController?.tabBar.frame.size.height ?? CGFloat(48)
        let keyboardPositionY = safeAreaHeight - _keyboardHeight - navigationBarHeight
        
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
        if addBtn.frame.maxY - safeAreaHeight > 0 && callView == false {
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
        }else if musicTF.isFirstResponder {
            musicTF.resignFirstResponder()
        }else if artistTF.isFirstResponder {
            artistTF.resignFirstResponder()
        }
    }

}

extension AddMusicViewController: UITextFieldDelegate {
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
