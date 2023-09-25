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


//MARK: - AddListViewContoller

class AddListViewController: UIViewController {
    
    var listRef: CollectionReference!
    var addID: String = ""
    var randomImage: String = ""
    
    
    //MARK: - UI objects
    
    @IBOutlet var listImage: UIButton!
    @IBOutlet var listTF: UITextField!
    @IBOutlet var addBtn: CustomButton!
    
    
    //MARK: - View Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField()
        setupInitialImage()
        title = "リストを追加"
    }
    
    //MARK: - Setup
    
    func setupTextField() {
        listTF.delegate = self
    }
    
    func setupInitialImage() {
        
        listImage.layer.cornerRadius = listImage.frame.width * 0.1
        listImage.clipsToBounds = true
        
        randomImage = material.listImages.randomElement()!
        let image = UIImage(systemName: randomImage)?.withTintColor(UIColor.imageColor)
        let size = CGSize(width: listImage.frame.width, height: listImage.frame.height + 3)
        let renderer = UIGraphicsImageRenderer(size: size)
        let newImage = renderer.image { context in
            // 背景色を描画
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // SFSymbolを描画
            image?.draw(in: CGRect(origin: .zero, size: size))
        }
        
        listImage.setImage(newImage, for: .normal)
        listImage.imageView?.contentMode = .scaleAspectFill
        
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
        let image = listImage.image(for: .normal)
        var resizedImage: Data!
        if material.listImages.contains(where: { $0 == randomImage}) {
            resizedImage = resizedData(image: image!, maxSize: 1024, quality: 1.0)
            
        } else {
            resizedImage = resizedData(image: image!, maxSize: 1024, quality: 0.6)
            
        }
        
        listFB.addList(listName: listTF.text!, listImage: resizedImage!)
        fromAddList = true
        
        navigationController?.popViewController(animated: true)
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
    
    
    //MARK: - UI interaction
    
    @IBAction func tapChangeImage() {
        changeImage()
    }
    
    @IBAction func addListBtn() {
        addList()
    }
}


//MARK: - UITextFieldDelegate

extension AddListViewController: UITextFieldDelegate {
    //改行したら自動的にキーボードを非表示にする
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        listTF.resignFirstResponder()
        return true
    }
}


//MARK: - UIIMagePickerControllerDelegate

extension AddListViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //ImagePickerで取得してきた画像をcropにセット
        if let _image = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true)
            //画像をlistImageに切り抜く
            let cropViewController = CropViewController(croppingStyle: .default, image: _image)
            cropViewController.delegate = self
            // アスペクト比を固定（変更不可）に設定
            cropViewController.aspectRatioLockEnabled = true
            // アスペクト比をプリセットする
            cropViewController.aspectRatioPreset = .presetSquare
            // アスペクト比選択ボタンを非表示にする
            cropViewController.aspectRatioPickerButtonHidden = true
            // リセットボタンを非表示にする アスペクト比の指定ができなくなるため
            cropViewController.resetButtonHidden = true

            present(cropViewController, animated: true)
            
            
        } else {
            //ImagePickerを閉じる
            picker.dismiss(animated: true)
        }
    }
}


//MARK: - UINavigationControllerDelegate

extension AddListViewController: UINavigationControllerDelegate {
    
}


//MARK: - CropViewControllerDelegate

extension AddListViewController: CropViewControllerDelegate {
    //トリミング済みの画像を設定する
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        listImage.setImage(image, for: .normal)
        listImage.contentMode = .scaleAspectFill
        randomImage = ""
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    //キャンセルボタンが押された場合
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
