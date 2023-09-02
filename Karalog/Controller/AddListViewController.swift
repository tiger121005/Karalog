//
//  AddListViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import CropViewController

class AddListViewController: UIViewController {
    
    var listRef: CollectionReference!
    var addID: String = ""
    var randomImage: String = ""
    
    @IBOutlet var listImage: UIButton!
    @IBOutlet var listTF: UITextField!
    @IBOutlet var addBtn: CustomButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField()
        setupInitialImage()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //キーボード以外がタップされた時にキーボードを閉じる
        self.listTF.resignFirstResponder()
            
    }
    
    func setupTextField() {
        listTF.delegate = self
    }
    
    func setupInitialImage() {
        if (UIImage(systemName: "music.mic") != nil) {
            randomImage = Material.shared.listImages.randomElement()!
            let image = UIImage(systemName: randomImage)?.withTintColor(UIColor(named: "imageColor")!)
            let size = CGSize(width: listImage.frame.width, height: listImage.frame.height)
            let renderer = UIGraphicsImageRenderer(size: size)
            let newImage = renderer.image { context in
                // 背景色を描画
                UIColor.black.setFill()
                context.fill(CGRect(origin: .zero, size: size))
                
                // SFSymbolを描画
                image?.draw(in: CGRect(origin: .zero, size: size))
            }
            
            listImage.setBackgroundImage(newImage, for: .normal)
            listImage.imageView?.contentMode = .scaleAspectFill
        }else{
            print("値が入力されていません")
        }
    }
    
    @IBAction func tapChangeImage() {
        changeImage()
    }
    
    @IBAction func addListBtn() {
        addList()
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
    
    func addList() {
        let image = listImage.backgroundImage(for: .normal)
        var resizedImage: Data!
        if Material.shared.listImages.contains(where: { $0 == randomImage}) {
            resizedImage = resizedData(image: image!, maxSize: 1024, quality: 1.0)
            
        } else {
            resizedImage = resizedData(image: image!, maxSize: 1024, quality: 0.6)
            
        }
        
        FirebaseAPI.shared.addList(listName: listTF.text!, listImage: resizedImage!)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    

    func resizedData(image: UIImage, maxSize: CGFloat, quality: CGFloat)  -> Data? {
        var size: CGSize = image.size
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

extension AddListViewController: UITextFieldDelegate {
    //改行したら自動的にキーボードを非表示にする
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        listTF.resignFirstResponder()
        return true
    }
}

extension AddListViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //ImagePickerで取得してきた画像をimageViewにセット
        if let _image = info[.originalImage] as? UIImage {
            listImage.setBackgroundImage(_image, for: .normal)
            listImage.imageView?.contentMode = .scaleAspectFill
            randomImage = ""
        }
        //ImagePickerを閉じる
        dismiss(animated: true)
    }
}

extension AddListViewController: UINavigationControllerDelegate {
    
}

extension AddListViewController: CropViewControllerDelegate {
    
}
