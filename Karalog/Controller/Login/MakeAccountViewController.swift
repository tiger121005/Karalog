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


//MARK: - MakeAccountViewController

class MakeAccountViewController: UIViewController {
    
    let db = Firestore.firestore()
    var getImage = false
    
    
    
    // MARK: - UI objects
    
    @IBOutlet var mailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var nameTF: UITextField!
    @IBOutlet var lookPasswordBtn: UIButton!
    @IBOutlet var signUpBtn: CustomButton!
    
    var activityIndicatorView = UIActivityIndicatorView()
    

    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTF()
        makeIndicator()
    }

    
    
    
    //MARK: - Setup
    
    func makeIndicator() {
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .imageColor

        view.addSubview(activityIndicatorView)
    }
    
    func setupTF() {
        mailTF.delegate = self
        passwordTF.delegate = self
        nameTF.delegate = self
        passwordTF.isSecureTextEntry = true
        passwordTF.textContentType = .password
    }
    
    
    func set(uid: String, name: String) {
        activityIndicatorView.startAnimating()
        UserDefaultsKey.userID.set(value: uid)
        self.db.collection("user").document(uid).setData([
            "name": name,
            "goodList": [],
            "listOrder": [],
            "showAll": false,
            "follow": [],
            "follower": [],
            "request": [],
            "notice": [],
            "getImage": getImage
        ], completion: { err in
            if let _err = err {
                print("cannot create account")
                self.activityIndicatorView.stopAnimating()
                let dialog = UIAlertController(title: "新規登録失敗", message: _err.localizedDescription, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
            }else{
                print("creating account succeeded")
                let nextView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tutorialViewController") as! UIPageViewController
                nextView.modalPresentationStyle = .fullScreen
                utility.login(first: true, user: User(name: name, goodList: [], listOrder: [], showAll: false, follow: [], follower: [], request: [], notice: [], getImage: self.getImage, id: uid)) {_ in
                    
                    self.present(nextView, animated: true, completion: nil)
                    self.activityIndicatorView.stopAnimating()
                }
                    
            }
        })
    }
    
    // MARK: UI interaction
    
    @IBAction func lookPassword() {
        if passwordTF.isSecureTextEntry {
            lookPasswordBtn.setImage(UIImage.eye, for: .normal)
        }else{
            lookPasswordBtn.setImage(UIImage.eyeSlash, for: .normal)
        }
        passwordTF.isSecureTextEntry.toggle()
    }
    
    @IBAction func createAccount() {
        
        guard let _mail = mailTF.text else { return }
        guard let password = passwordTF.text else { return }
        guard let name = nameTF.text else { return }
        let alert = UIAlertController(title: "画像の送信", message: "画像認識向上のため撮影した採点画面の画像を送信することを許可しますか（後で変更可能です）", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "しない", style: .cancel) { (action) in
            self.getImage = false
            
            Auth.auth().createUser(withEmail: _mail, password: password, completion: { (result, error) in
                if let _user = result?.user {
                    self.set(uid: _user.uid, name: name)
                    
                }else{
                    print("cannot create acount")
                    let dialog = UIAlertController(title: "新規登録失敗", message: error?.localizedDescription, preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(dialog, animated: true, completion: nil)
                }
            })
        }
        let delete = UIAlertAction(title: "許可する", style: .default) { (action) in
            self.getImage = true
            
            Auth.auth().createUser(withEmail: _mail, password: password, completion: { (result, error) in
                if let _user = result?.user {
                    self.set(uid: _user.uid, name: name)
                    
                }else{
                    print("cannot create acount")
                    let dialog = UIAlertController(title: "新規登録失敗", message: error?.localizedDescription, preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(dialog, animated: true, completion: nil)
                }
            })
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
        
        
        
    }
    

}


//MARK: - UITextFieldDelegate

extension MakeAccountViewController: UITextFieldDelegate {
    
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