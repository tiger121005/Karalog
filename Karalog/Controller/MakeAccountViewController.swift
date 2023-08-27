//
//  MakeAccountViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class MakeAccountViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet var mailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var nameTF: UITextField!
    @IBOutlet var lookPasswordBtn: UIButton!
    @IBOutlet var signUpBtn: CustomButton!
    @IBAction func lookPassword() {
        if passwordTF.isSecureTextEntry == true {
            passwordTF.isSecureTextEntry = false
            lookPasswordBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        }else{
            passwordTF.isSecureTextEntry = true
            lookPasswordBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
    }
    
    @IBAction func createAccount() {
        guard let _mail = mailTF.text else { return }
        guard let password = passwordTF.text else { return }
        guard let name = nameTF.text else { return }
        Auth.auth().createUser(withEmail: _mail, password: password, completion: { (result, error) in
            if let _user = result?.user {
                UserDefaultsKey.userID.set(value: _user.uid)
                self.db.collection("user").document(_user.uid).setData([
                    "name": name,
                    "goodList": [],
                    "listOrder": [],
                    "showAll": false,
                    "follow": [],
                    "follower": [],
                    "request": [],
                    "notice": []
                ], completion: { err in
                    if err != nil {
                        print("cannot create account")
                        let dialog = UIAlertController(title: "新規登録失敗", message: error?.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(dialog, animated: true, completion: nil)
                    }else{
                        print("creating account succeeded")
                        let nextView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
                        nextView.modalPresentationStyle = .fullScreen
                        Function.shared.login(first: true, user: User(name: name, goodList: [], listOrder: [], showAll: false, follow: [], follower: [], request: [], notice: [], id: _user.uid))
                        
                        self.present(nextView, animated: true, completion: nil)
                            
                    }
                })
            }else{
                print("cannot create acount")
                let dialog = UIAlertController(title: "新規登録失敗", message: error?.localizedDescription, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTF.isSecureTextEntry = true
        passwordTF.textContentType = .password
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //キーボード以外がタップされた時にキーボードを閉じる
        if (self.mailTF.isFirstResponder) {
            self.mailTF.resignFirstResponder()
        }else if (self.passwordTF.isFirstResponder) {
            self.passwordTF.resignFirstResponder()
        }else if (self.nameTF.isFirstResponder) {
            self.nameTF.resignFirstResponder()
        }
            
    }
    
    //改行したら自動的にキーボードを非表示にする
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 今フォーカスが当たっているテキストボックスからフォーカスを外す
        textField.resignFirstResponder()
        if textField == mailTF {
            passwordTF.becomeFirstResponder()
        }else if textField == passwordTF {
            nameTF.becomeFirstResponder()
        }
        
        return true
    }
    

}
