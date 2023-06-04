//
//  LoginViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FacebookLogin

class LoginViewController: UIViewController {

    //メール
    @IBOutlet var mailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var lookPasswordBtn: UIButton!
    @IBAction func lookPassword() {
        if passwordTF.isSecureTextEntry == true {
            passwordTF.isSecureTextEntry = false
            lookPasswordBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        }else{
            passwordTF.isSecureTextEntry = true
            lookPasswordBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
    }
    
    let db = Firestore.firestore()
    
    @IBOutlet var loginBtn: UIButton!
    @IBAction func tapLoginBtn() {
        let mail = mailTF.text
        let password = passwordTF.text
        
        Auth.auth().signIn(withEmail: mail!, password: password!) { (result, err) in
            if let user = result?.user {
                UserDefaults.standard.set(user.uid, forKey: "userID")
                self.performSegue(withIdentifier: "toTabBar", sender: nil)
            }else{
                print("cannot find account:", err!)
                let dialog = UIAlertController(title: "アカウントが見つかりませんでした", message: err?.localizedDescription, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
            }
        }
    }
    //Google
    @IBOutlet var googleLoginView: UIView!
    
    @IBAction func didTapSignInButton(_ sender: Any) {
        auth()
    }
    
    private func auth() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                print("error")
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                if let user = result?.user {
                    self.db.collection("user").document(user.uid).setData([
                        "name": user.displayName!])
                    UserDefaults.standard.set(user.uid, forKey: "userID")
                    self.performSegue(withIdentifier: "toTabBar", sender: nil)
                }else {
                    print("google login error:", error!)
                }
            }
        }
    }
    private func login(credential: AuthCredential) {
        print("ログイン完了")
    }
    
    
    //facebook
//    func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
//        if let error = error {
//            print(error.localizedDescription)
//            return
//        }
//
//        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
//        Auth.auth().signIn(with: credential) { result, error in
//            if let user = result?.user {
//                print(user.uid)
//                UserDefaults.standard.set(user.uid, forKey: "userID")
//                self.performSegue(withIdentifier: "toTabBar", sender: nil)
//            }else {
//                print("facebook login error:", error!)
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTF.isSecureTextEntry = true

//        let facebookLoginBtn = FBLoginButton()
//        facebookLoginBtn.center = view.center
//        facebookLoginBtn.frame.origin.y = googleLoginView.frame.maxY + 20
//        view.addSubview(facebookLoginBtn)
        
        if let token = AccessToken.current,!token.isExpired {
                // User is logged in, do work such as go to next view controller.
            UserDefaults.standard.set(token.userID, forKey: "userID")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.string(forKey: "userID") != nil {
            self.performSegue(withIdentifier: "toTabBar", sender: nil)
            FirebaseAPI.shared.getGoodList()
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
    
    //改行したら自動的にキーボードを非表示にする
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == mailTF {
            passwordTF.becomeFirstResponder()
        }
        return true
    }

}
