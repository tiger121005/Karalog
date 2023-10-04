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


//MARK: - LoginViewController

class LoginViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    
    // MARK: - UI objects

    @IBOutlet var mailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var lookPasswordBtn: UIButton!
    @IBOutlet var loginBtn: CustomButton!
    @IBOutlet var googleLoginView: UIView!
    
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTF()
        setupUserID()
//        let handle = Auth.auth().addStateDidChangeListener { auth, user in
//            print("🇲🇪", auth)
//            print("🇲🇱", user)
//        }
        
    }
    
    
    //MARK: - Setup
    
    func setupTF() {
        mailTF.delegate = self
        passwordTF.delegate = self
        passwordTF.isSecureTextEntry = true
        passwordTF.textContentType = .none
    }
    
    func setupUserID() {
        if let _token = AccessToken.current,!_token.isExpired {
            // User is logged in, do work such as go to next view controller.
            UserDefaultsKey.userID.set(value: _token.userID)
        }
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
                
                guard let _user = result?.user else {
                    print("google login error", error!)
                    return
                }
                Task {
                    await self.set(uid: _user.uid, userName: _user.displayName)
                    
                    self.segue(identifier: .tabBar)
                }
                
            }
        }
    }
    private func login(credential: AuthCredential) {
        print("ログイン完了")
    }
    
    func set(uid: String, userName: String?) async {
        UserDefaultsKey.userID.set(value: uid)
        //すでにアカウントがある場合
        if let _pastUserInformation = await userFB.getUserInformation(id: uid) {
            function.login(first: false, user: _pastUserInformation)
            UserDefaultsKey.judgeSort.set(value: Sort.追加順（遅）.rawValue)
            segue(identifier: .tabBar)
            return
        }
        
        guard let _name = userName else { return }
        
        //まだアカウントがない時
        self.db.collection("user").document(uid).setData([
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
        function.login(first: true, user: User(name: _name, goodList: [], listOrder: [], showAll: false, follow: [], follower: [], request: [], notice: [], id: uid))
        
    }
    
    func segue(identifier: Segue) {
        if UserDefaultsKey.showTutorial.get() == nil {
            self.performSegue(withIdentifier: "toTutorial", sender: nil)
        } else {
            let id = identifier.rawValue
            self.performSegue(withIdentifier: id, sender: nil)
        }
    }
    
    
    // MARK: UI interaction
    
    //メール
    @IBAction func lookPassword() {
        if passwordTF.isSecureTextEntry {
            lookPasswordBtn.setImage(UIImage.eye, for: .normal)
        }else{
            lookPasswordBtn.setImage(UIImage.eyeSlash, for: .normal)
        }
        passwordTF.isSecureTextEntry.toggle()
    }
    
    
    @IBAction func tapLoginBtn() {
        guard let _mail = mailTF.text else {
            return
        }
        guard let _password = passwordTF.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: _mail, password: _password) { (result, err) in
            guard let _user = result?.user else {
                print("cannot find account:", err!)
                
                let dialog = UIAlertController(title: "アカウントが見つかりませんでした", message: err?.localizedDescription, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
                return
            }
            Task {
                guard let userInfo = await userFB.getUserInformation(id: _user.uid) else {
                    let dialog = UIAlertController(title: "アカウントが見つかりませんでした", message: err?.localizedDescription, preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(dialog, animated: true, completion: nil)
                    return
                }
                function.login(first: false, user: userInfo)
                UserDefaultsKey.judgeSort.set(value: Sort.追加順（遅）.rawValue)
                self.segue(identifier: .tabBar)
            }
            
        }
    }
    
    //Google
    @IBAction func didTapGoogleSignInButton(_ sender: Any) {
        auth()
    }
    
    
    
    
}


//MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == mailTF {
            passwordTF.becomeFirstResponder()
        }
        return true
    }
}
