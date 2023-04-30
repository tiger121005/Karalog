//
//  AddDetailViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import FirebaseFirestore

class AddDetailViewController: UIViewController, UITextFieldDelegate {

    var musicDoc: DocumentReference! = nil
    var alertCtl: UIAlertController!
    var time: String!
    var fromWanna = false
    var musicName = ""
    var artistName = ""
    var musicImage: Data!
    var id = ""
    
    @IBOutlet var scoreTF: UITextField!
    @IBOutlet var keySlider: UISlider!
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var modelBtn: UIButton!
    @IBOutlet var textView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //UIButtonにUIMenuを設定する
        self.configureMenuButton()
        
        keyLabel.layer.borderColor = CGColor(red: 0.93, green: 0.47, blue: 0.18, alpha: 1.0)
        keyLabel.layer.borderWidth = 2
        keyLabel.layer.cornerRadius = keyLabel.frame.height * 0.5
        keyLabel.clipsToBounds = true
        
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
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let numCount = scoreTF.text else { return }
        
        if numCount.count > 6 {
            scoreTF.text = String(numCount.prefix(6))
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
    
    //sliderの開始点を自由にする
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {

        let pointTapped: CGPoint = gestureRecognizer.location(in: keySlider)

        let widthOfSlider: CGFloat = keySlider.frame.size.width
        let newValue = pointTapped.x * CGFloat(keySlider.maximumValue - keySlider.minimumValue) / widthOfSlider - CGFloat(keySlider.maximumValue)
        keySlider.setValue(round(Float(newValue)), animated: false)
        slider(keySlider)
    }
    
    //機種設定
    enum modelMenuType: String {
        case 未選択 = "未選択"
        case DAM = "DAM"
        case JOYSOUND = "JOYSOUND"
    }
    
    var selectedMenuType = modelMenuType.未選択
    
    private func configureMenuButton() {
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
    
    @IBAction func tapAddBtn() {
        if Double(scoreTF.text!) != nil {
            let df = DateFormatter()
            df.dateFormat = "yy年MM月dd日HH:mm"
            df.timeZone = TimeZone.current
            time = df.string(from: Date())
            let d = [
                "time": time!,
                "score": Double(scoreTF.text!)!,
                "key": Int(keyLabel.text!)!,
                "model": String(selectedMenuType.rawValue),
                "comment": textView.text!] as [String : Any]
            if fromWanna == false {
                musicDoc.updateData([
                    "data": FieldValue.arrayUnion([d])
                ]) { err in
                    if let err = err {
                        print("Error adding data: \(err)")
                    }else{
                        print("data added")
                    }
                }
            } else {
                Firestore.firestore().collection("user").document(UserDefaults.standard.string(forKey: "userID")!).collection("musicList").addDocument(data: [
                    "musicName": musicName,
                    "artistName": artistName,
                    "musicImage": musicImage!,
                    "favorite": false,
                    "data": [d]
                ]) { err in
                    if let err = err {
                        print("Error adding data: \(err)")
                    }else{
                        print("data added")
                    }
                }
                Firestore.firestore().collection("user").document(UserDefaults.standard.string(forKey: "userID")!).collection("wannaList").document(id).delete()
            }
            
//            UserDefaults.standard.set([time, scoreTF.text!, keyLabel.text!, selectedMenuType.rawValue, textView.text!], forKey: "addData")
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
    
    
    //改行したら自動的にキーボードを非表示にする
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        scoreTF.resignFirstResponder()
        return true
    }
    
    //キーボード以外をタップ時キーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.textView.isFirstResponder) {
            self.textView.resignFirstResponder()
        }else if (self.scoreTF.isFirstResponder){
            self.scoreTF.resignFirstResponder()
        }
        
    }
}
