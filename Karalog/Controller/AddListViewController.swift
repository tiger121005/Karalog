//
//  AddListViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class AddListViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var listRef: CollectionReference!
    var addID = ""
    
    @IBOutlet var listImage: UIButton!
    @IBOutlet var listTF: UITextField!
    
    @IBAction func tapChangeImage() {
        changeImage()
    }
    
    @IBAction func addListBtn() {
        addList()
    }
    
    let defaultImageList = ["music.mic", "music.note.list", "music.note", "music.quarternote.3", "music.note.tv.fill", "music.note.tv", "music.note.house", "music.note.house.fill"]
    var randomImage = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        listTF.delegate = self
        
        if (UIImage(systemName: "music.mic") != nil) {
            randomImage = defaultImageList.randomElement()!
            let image = UIImage(systemName: randomImage)
            
            listImage.setBackgroundImage(image, for: .normal)
            listImage.imageView?.contentMode = .scaleAspectFill
        }else{
            print("値が入力されていません")
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //キーボード以外がタップされた時にキーボードを閉じる
        if (self.listTF.isFirstResponder) {
            self.listTF.resignFirstResponder()
        }else if (self.listTF.isFirstResponder){
            self.listTF.resignFirstResponder()
        }
            
    }
    

    func changeImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //ImagePickerで取得してきた画像をimageViewにセット
        if let image = info[.originalImage] as? UIImage {
            listImage.setBackgroundImage(image, for: .normal)
            listImage.imageView?.contentMode = .scaleAspectFill
            randomImage = ""
        }
        //ImagePickerを閉じる
        dismiss(animated: true)
    }
    
    func addList() {
        let image = listImage.backgroundImage(for: .normal)
        var resizedImage: Data!
        if let image = UIImage(systemName: randomImage)?.withTintColor(UIColor(red: 0.93, green: 0.47, blue: 0.18, alpha: 1.0)) {
            resizedImage = image.jpegData(compressionQuality: 1.0)
            print(resizedImage!)
            print(2222222)
        } else {
            resizedImage = resizedData(image: image!, maxSize: 1024, quality: 0.5)
            print(3333333)
        }

        
        print(Double(resizedImage!.count) / 1000)
        
        let docRef = listRef.addDocument(data: [
            "listName": listTF.text!,
            "listImage": resizedImage!,
            
        ]) { err in
            if let err = err {
                print("Error adding list: \(err)")
            } else {
                
            }
        }
        Firestore.firestore().collection("user").document(UserDefaults.standard.string(forKey: "userID")!).updateData([
            "listOrder": FieldValue.arrayUnion([docRef.documentID])])
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //改行したら自動的にキーボードを非表示にする
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        listTF.resignFirstResponder()
        return true
    }

    func resizedData(image: UIImage, maxSize: CGFloat, quality: CGFloat)  -> Data? {
        var size = image.size
        var scale: CGFloat = 1.0
        if size.width > maxSize || size.height > maxSize {
            scale = min(maxSize / size.width, maxSize / size.height)
            size = CGSize(width: size.width * scale, height: size.height * scale)
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage?.jpegData(compressionQuality: quality)
        
    }
}
