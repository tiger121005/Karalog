//
//  LoginViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FacebookLogin

class LoginViewController: UIViewController {
    
    let db = Firestore.firestore()

    @IBOutlet var mailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var lookPasswordBtn: UIButton!
    @IBOutlet var loginBtn: CustomButton!
    @IBOutlet var googleLoginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailTF.delegate = self
        passwordTF.delegate = self
        passwordTF.isSecureTextEntry = true
        passwordTF.textContentType = .none
        
        let handle = Auth.auth().addStateDidChangeListener { auth, user in
            print("🇲🇪", auth)
            print("🇲🇱", user)
        }
        
        if let _token = AccessToken.current,!_token.isExpired {
            // User is logged in, do work such as go to next view controller.
            UserDefaultsKey.userID.set(value: _token.userID)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //キーボード以外がタップされた時にキーボードを閉じる
        if (self.mailTF.isFirstResponder) {
            self.mailTF.resignFirstResponder()
        }else if (self.passwordTF.isFirstResponder) {
            self.passwordTF.resignFirstResponder()
        }
            
    }
    
    //メール
    @IBAction func lookPassword() {
        if passwordTF.isSecureTextEntry == true {
            passwordTF.isSecureTextEntry = false
            lookPasswordBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        }else{
            passwordTF.isSecureTextEntry = true
            lookPasswordBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
    }
    
    
    @IBAction func tapLoginBtn() {
        guard let _mail = mailTF.text else {
            return
        }
        guard let _password = passwordTF.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: _mail, password: _password) { (result, err) in
            if let _user = result?.user {
                Task {
                    Function.shared.login(first: false, user: await FirebaseAPI.shared.getUserInformation(id: _user.uid)!)
                    UserDefaultsKey.judgeSort.set(value: "0")
                    self.performSegue(withIdentifier: "toTabBar", sender: nil)
                }
            }else{
                print("cannot find account:", err!)
                
                let dialog = UIAlertController(title: "アカウントが見つかりませんでした", message: err?.localizedDescription, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
            }
        }
    }
    
    //Google
    @IBAction func didTapSignInButton(_ sender: Any) {
        auth()
    }
    
    
    
    private func auth() {
        guard let _clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: _clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                print("error")
                return
            }
            guard let _user = result?.user, let idToken = _user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: _user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                
                if let _user = result?.user {
                    
                    Task {
                        UserDefaultsKey.userID.set(value: _user.uid)
                        
                        //すでにアカウントがある場合
                        if let _pastUserInformation = await FirebaseAPI.shared.getUserInformation(id: _user.uid) {
                            Function.shared.login(first: false, user: _pastUserInformation)
                            UserDefaultsKey.judgeSort.set(value: "0")
                            self.performSegue(withIdentifier: "toTabBar", sender: nil)
                            return
                        }
                        guard let _name = _user.displayName else {
                            return
                        }
                        
                        //まだアカウントがない時
                        self.db.collection("user").document(_user.uid).setData([
                            "name": _name,
                            "goodList": [],
                            "listOrder": [],
                            "showAll": false,
                            "follow": [],
                            "follower": [],
                            "request": [],
                            "notice": []
                        ]) { err in
                            if let _err = err {
                                print("Error adding userName: \(_err)")
                            }
                        }
                        Function.shared.login(first: true, user: User(name: _name, goodList: [], listOrder: [], showAll: false, follow: [], follower: [], request: [], notice: [], id: _user.uid))
                        
                        
                        
                        
                        self.performSegue(withIdentifier: "toTabBar", sender: nil)
                    }
                }else {
                    print("google login error:", error!)
                }
            }
        }
    }
    private func login(credential: AuthCredential) {
        print("ログイン完了")
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == mailTF {
            passwordTF.becomeFirstResponder()
        }
        return true
    }
}
