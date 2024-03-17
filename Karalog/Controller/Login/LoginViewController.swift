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
import AuthenticationServices
import CryptoKit


//MARK: - LoginViewController

class LoginViewController: UIViewController {
    
    let db = Firestore.firestore()
    var activityIndicatorView = UIActivityIndicatorView()
    fileprivate var currentNonce: String?
    
    
    // MARK: - UI objects

    @IBOutlet var mailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var lookPasswordBtn: UIButton!
    @IBOutlet var loginBtn: CustomButton!
    @IBOutlet var googleLoginView: UIView!
    @IBOutlet var secondView: UIView!
    
    var appleLoginButton = ASAuthorizationAppleIDButton()
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppleIDLoginButton()
        setupTF()
        setupUserID()
        makeIndicator()
        
    }
    
    
    //MARK: - Setup
    
    func setupAppleIDLoginButton() {
        
        secondView.addSubview(appleLoginButton)
        let topConstraint = NSLayoutConstraint.init(item: appleLoginButton, attribute: .top, relatedBy: .equal, toItem: loginBtn, attribute: .bottom, multiplier: 1.0, constant: 30)
        topConstraint.isActive = true
        let heightConstraint = NSLayoutConstraint.init(item: appleLoginButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        heightConstraint.isActive = true
        
        appleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        appleLoginButton.leftAnchor.constraint(equalToSystemSpacingAfter: googleLoginView.leftAnchor, multiplier: 0).isActive = true
        appleLoginButton.rightAnchor.constraint(equalToSystemSpacingAfter: googleLoginView.rightAnchor, multiplier: 0).isActive = true
        
        appleLoginButton.addTarget(self, action: #selector(authorizationAppleID), for: .touchUpInside)
    }
    
    func makeIndicator() {
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .imageColor

        view.addSubview(activityIndicatorView)
    }
    
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
                self.activityIndicatorView.startAnimating()
                guard let _user = result?.user else {
                    print("google login error", error!)
                    self.activityIndicatorView.stopAnimating()
                    return
                }
                Task {
                    await self.set(uid: _user.uid, userName: _user.displayName)
                    self.activityIndicatorView.stopAnimating()
                    self.segue(identifier: .tabBar)
                }
                
            }
        }
    }
    
    private func login(credential: AuthCredential) {
        print("ログイン完了")
    }
    
    func set(uid: String, userName: String?) async {
        activityIndicatorView.startAnimating()
        UserDefaultsKey.userID.set(value: uid)
        //すでにアカウントがある場合
        if let _pastUserInformation = await userFB.getUserInformation(id: uid) {
            utility.login(first: false, user: _pastUserInformation) {_ in
                UserDefaultsKey.judgeSort.set(value: Sort.late.rawValue)
                self.activityIndicatorView.stopAnimating()
                if UserDefaultsKey.showTutorial.get() == nil {
                    self.segue(identifier: .tutorial)
                } else {
                    self.segue(identifier: .tabBar)
                }
            }
            return
        }
        
        
        
        //まだアカウントがない時
        let alert = UIAlertController(title: "画像の送信", message: "画像認識向上のため撮影した採点画面の画像を送信することを許可しますか", preferredStyle: .alert)
        let not = UIAlertAction(title: "しない", style: .cancel) {_ in
            utility.login(first: true, user: User(name: userName ?? "No Name", goodList: [], listOrder: [], showAll: false, follow: [], follower: [], request: [], notice: [], getImage: false, id: uid)) {_ in
                self.db.collection("user").document(uid).setData([
                    "name": userName ?? "No Name",
                    "goodList": [],
                    "listOrder": [],
                    "showAll": false,
                    "follow": [],
                    "follower": [],
                    "request": [],
                    "notice": [],
                    "getImage": false
                ]) { err in
                    if let _err = err {
                        print("Error adding userName: \(_err)")
                    }
                }
                self.activityIndicatorView.stopAnimating()
                self.segue(identifier: .tutorial)
            }
        }
        let allow = UIAlertAction(title: "許可する", style: .default) {_ in
            utility.login(first: true, user: User(name: userName ?? "No Name", goodList: [], listOrder: [], showAll: false, follow: [], follower: [], request: [], notice: [], getImage: true, id: uid)) {_ in
                self.db.collection("user").document(uid).setData([
                    "name": userName ?? "No Name",
                    "goodList": [],
                    "listOrder": [],
                    "showAll": false,
                    "follow": [],
                    "follower": [],
                    "request": [],
                    "notice": [],
                    "getImage": true
                ]) { err in
                    if let _err = err {
                        print("Error adding userName: \(_err)")
                    }
                }
                self.activityIndicatorView.stopAnimating()
                self.segue(identifier: .tutorial)
            }
        }
        
        alert.addAction(not)
        alert.addAction(allow)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Nonce
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }

            return String(nonce)
    }

    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
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
            self.activityIndicatorView.startAnimating()
            guard let _user = result?.user else {
                print("cannot find account:", err!)
                self.activityIndicatorView.stopAnimating()
                let dialog = UIAlertController(title: "アカウントが見つかりませんでした", message: err?.localizedDescription, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
                return
            }
            Task {
                
                guard let userInfo = await userFB.getUserInformation(id: _user.uid) else {
                    self.activityIndicatorView.stopAnimating()
                    let dialog = UIAlertController(title: "アカウントが見つかりませんでした", message: err?.localizedDescription, preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(dialog, animated: true, completion: nil)
                    return
                }
                utility.login(first: false, user: userInfo) {_ in
                    UserDefaultsKey.judgeSort.set(value: Sort.late.rawValue)
                    self.activityIndicatorView.stopAnimating()
                    self.segue(identifier: .tabBar)
                }
            }
            
        }
    }
    
    //Google
    @IBAction func didTapGoogleSignInButton(_ sender: Any) {
        auth()
    }
    
    
    
    // MARK: - Objective - C
    
    //Apple
    @objc func authorizationAppleID() {
        if #available(iOS 13.0, *) {
            let nonce = randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
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


// MARK: - ASAuthorizationControllerDelegate

//extension LoginViewController: ASAuthorizationControllerDelegate {
//    @available(iOS 13.0, *)
//    private func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) async {
//        
//        handle(authorization.credential)
        
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            //　取得できる値
//            let userIdentifier = appleIDCredential.user
//            let fullName = appleIDCredential.fullName?.nickname
//            
//            await set(uid: userIdentifier, userName: fullName)
//        }
//    }
//
//    @available(iOS 13.0, *)
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        // エラー処理
//        print("Error Sign in with Apple")
//    }
//    
//    func handle(_ credential: ASAuthorizationCredential) {
//        // 認証完了後ASAuthorizationCredentialから必要な情報を取り出す
//        // エラー時のハンドリングはアプリごとに違うので省略
//        guard let appleIDCredential = credential as? ASAuthorizationAppleIDCredential else {
//            // キャスト失敗。ASPasswordCredential（パスワードは今回要求していないので起きないはず）だと失敗する
//            return
//        }
//        guard let nonce = currentNonce else {
//            // ログインリクエスト失敗
//            print("Error request")
//            return
//        }
//        
//        guard let appleIDToken = appleIDCredential.identityToken else {
//            print("Unable to fetch identity token")
//            // ユーザーに関する情報をアプリに伝えるためのJSON Web Tokenの取得に失敗
//            print("Error get JSON Web Token")
//            return
//        }
//        
//        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//            // JWTからトークン(文字列)へのシリアライズに失敗
//            print("Error JWT to String")
//            return
//        }
//        
//        // Sign In With Appleの認証情報を元にFirebase Authenticationの認証
//        let oAuthCredential = OAuthProvider.credential(
//            withProviderID: "apple.com",
//            idToken: idTokenString,
//            rawNonce: nonce)
//        
//        Auth.auth().signIn(with: oAuthCredential) { (authResult, error) in
//            if (error != nil) {
//                return
//            }
//            self.completeSigningInWithApple()
//            // 今回のアプリでは認証完了
//            // FireStore側に初期データを保存する処理を呼んだ後に前画面に戻る
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
    
//}

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                
                self.activityIndicatorView.startAnimating()
                guard let _user = authResult?.user else {
                    self.activityIndicatorView.stopAnimating()
                    let dialog = UIAlertController(title: "アカウントが見つかりませんでした", message: "", preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(dialog, animated: true, completion: nil)
                    if let _error = error {
                        print(_error.localizedDescription)
                    }
                    return
                }
                Task {
                    
                    await self.set(uid: _user.uid, userName: _user.displayName)
                    self.activityIndicatorView.stopAnimating()
                    self.segue(identifier: .tabBar)
                }
                
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}


// MARK: - ASAuthorizationControllerPresentationContextProviding

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
}
