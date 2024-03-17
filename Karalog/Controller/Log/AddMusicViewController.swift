//
//  AddMusicViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/03/24.
//

import UIKit
import Vision
import CoreML
import Alamofire


//MARK: - AddMusicViewController

class AddMusicViewController: UIViewController {
    
    var image: UIImage!
    var musicName: String = ""
    var artistName: String = ""
    var musicImage: String!
    var sliderValue: Float = 0
    var selectedMenuType = ModelMenuType.no
    var alertCtl: UIAlertController!
    var callView: Bool = true
    var scaleList: [UIView] = []
    var postEnable: Bool = false
    var category: [String] = []
    
    let decoder: JSONDecoder = JSONDecoder()
    
    
    //MARK: - UI objects
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var musicTF: UITextField!
    @IBOutlet var artistTF: UITextField!
    @IBOutlet var scoreTF: UITextField!
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var modelBtn: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var addBtn: CustomButton!
    @IBOutlet var customSlider: CustomSliderView!
    @IBOutlet var postBox: PostBox!
    @IBOutlet var categoryView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var imageBtn: UIBarButtonItem!
    
    var backView = UIView()
    var imageView = UIImageView()
    var closeBtn = UIButton()
    
    //MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScroll()
        setupTextField()
        setupModelButton()
        setupKeyLabel()
        setupCategoryView()
        setupView()
        setupImageBtn()
        setupImage()
        
        title = "曲を追加"
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSlider()
        showAlert()
    }
    
    
    //MARK: - Setup
    
    func setupView() {
        guard let image else { return }
        let detectLog = imageRec.rec(image: image)
        musicTF.text = detectLog.music
        artistTF.text = detectLog.artist
        scoreTF.text = detectLog.score
        textView.text = detectLog.comment
        
        if detectLog.model.contains("DAM") {
            selectedMenuType = .DAM
        } else if detectLog.model.contains("JOY") {
            selectedMenuType = .JOYSOUND
        }
        configureMenuButton()
        
        
    }
    
    func setupScroll() {
        scrollView.delegate = self
        
    }
    
    func setupTextField() {
        musicTF.delegate = self
        artistTF.delegate = self
        scoreTF.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        
        tableView.rowHeight = 44
        textView.layer.cornerRadius = 5
        textView.layer.cornerCurve = .continuous
        
        musicTF.text = musicName
        artistTF.text = artistName
        
        musicTF.keyboardAppearance = .dark
        artistTF.keyboardAppearance = .dark
        textView.keyboardAppearance = .dark
    }
    
    func setupModelButton() {
        modelBtn.layer.cornerRadius = modelBtn.frame.height * 0.5
        modelBtn.layer.cornerCurve = .continuous
        modelBtn.layer.borderColor = UIColor.imageColor.cgColor
        modelBtn.layer.borderWidth = 2
        modelBtn.tintColor = UIColor.imageColor
        modelBtn.backgroundColor = .clear
        modelBtn.layer.shadowColor = UIColor.imageColor.cgColor
        modelBtn.layer.shadowOpacity = 0.8
        modelBtn.layer.shadowRadius = 5
        modelBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
        configureMenuButton()
    }
    
    func configureMenuButton() {
        
        var actions = [UIMenuElement]()
        // HIGH
        actions.append(UIAction(title: ModelMenuType.no.rawValue, image: nil, state: self.selectedMenuType == ModelMenuType.no ? .on : .off,
                                handler: { (_) in
                                    self.selectedMenuType = .no
                                    // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
                                    self.configureMenuButton()
                                }))
        // MID
        actions.append(UIAction(title: ModelMenuType.DAM.rawValue, image: nil, state: self.selectedMenuType == ModelMenuType.DAM ? .on : .off,
                                handler: { (_) in
                                    self.selectedMenuType = .DAM
                                    // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
                                    self.configureMenuButton()
                                }))
        // LOW
        actions.append(UIAction(title: ModelMenuType.JOYSOUND.rawValue, image: nil, state: self.selectedMenuType == ModelMenuType.JOYSOUND ? .on : .off,
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
    
    func setupKeyLabel() {
        keyLabel.layer.borderColor = CGColor(red: 0.93, green: 0.47, blue: 0.18, alpha: 1.0)
        keyLabel.layer.borderWidth = 2
        keyLabel.layer.cornerRadius = keyLabel.frame.height * 0.5
        keyLabel.layer.cornerCurve = .continuous
        keyLabel.layer.shadowColor = UIColor.imageColor.cgColor
        keyLabel.layer.shadowOpacity = 0.8
        keyLabel.layer.shadowRadius = 3
        keyLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    
    
    
    func setupCategoryView() {
        categoryView.isHidden = true
        categoryLabel.layer.cornerRadius = 5
        categoryLabel.layer.cornerCurve = .continuous
    }
    
    func setCategory() {
        categoryLabel.numberOfLines = 0
        if let _indexPathList = self.tableView.indexPathsForSelectedRows {
            
            var text: String = ""
            var newLine: Bool = false
            for i in _indexPathList {
                if newLine {
                    text += "\n#" + material.categoryList[i.row]
                    category.append(material.categoryList[i.row])
                }else {
                    text = "#" + material.categoryList[i.row]
                    newLine = true
                    category = [material.categoryList[i.row]]
                    
                }
            }
            categoryLabel.text = text
        } else {
            categoryLabel.text = ""
            category = []
        }
    }
    
    
    func setupSlider() {
        if callView {
            scaleList = []
            for i in 0...14 {
                
                let view = UIView(frame: CGRect(x: CGFloat((customSlider.slider.bounds.width - 31) * CGFloat(i) / 14) + 12.5, y: customSlider.slider.frame.maxY, width: 6, height: 6))
                
                if i <= 7 {
                    view.backgroundColor = UIColor.imageColor
                } else {
                    view.backgroundColor = UIColor.label
                }
                view.layer.cornerRadius = 3
                
                customSlider.slider.addSubview(view)
                
                customSlider.bringSubviewToFront(customSlider.slider)
                
                scaleList.append(view)
            }
            callView = false
        }
    }
    
    func showAlert() {
        if image != nil {
            let alert = UIAlertController(title: "入力された値を確認してください", message: "上の写真マークから撮影した画像を見返すことができます", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            present(alert, animated: true)
        }
    }
    
    func setupImageBtn() {
        imageBtn.image = UIImage.photo.withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
        if image == nil {
            imageBtn.isHidden = true
        }
    }
    
    func setupImage() {
        if let image {
            let viewWidth = view.frame.width
            let viewHeight = view.frame.height
            backView = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
            backView.backgroundColor = .black.withAlphaComponent(0.4)
            
            let imageAspect = image.size.height / image.size.width
            let areaHeight = (tabBarController?.tabBar.frame.minY ?? viewHeight) - (navigationController?.navigationBar.frame.maxY ?? 44)
            let areaCenter = (navigationController?.navigationBar.frame.maxY ?? 44) + (areaHeight / 2)
            var imageViewWidth = viewWidth - 80
            var imageViewHeight = imageViewWidth * imageAspect
            var imageViewX: CGFloat = 40
            if imageViewHeight > areaHeight - 120 {
                imageViewHeight = areaHeight - 120
                imageViewWidth = imageViewHeight / imageAspect
                imageViewX = (viewWidth / 2) - (imageViewWidth / 2)
            }
            
            let imageViewY = areaCenter - (imageViewHeight / 2)
            
            imageView = UIImageView(frame: CGRect(x: imageViewX, y: imageViewY, width: imageViewWidth, height: imageViewHeight))
            imageView.image = image
            
            closeBtn = UIButton(frame: CGRect(x: viewWidth - 90, y: imageViewY - 60, width: 60, height: 60))
            closeBtn.addAction(UIAction {_ in
                self.backView.isHidden = true
                self.imageView.isHidden = true
                self.closeBtn.isHidden = true
            }, for: .touchUpInside)
            var btnImage = UIImage.multiply.withTintColor(UIColor.imageColor)
            btnImage = btnImage.resized(toWidth: 60) ?? btnImage
            closeBtn.setImage(btnImage, for: .normal)
            
            view.addSubview(backView)
            view.addSubview(imageView)
            view.addSubview(closeBtn)
            
            backView.isHidden = true
            imageView.isHidden = true
            closeBtn.isHidden = true
        }
    }
    
    
    func getMusicImage() async -> String? {
        await withCheckedContinuation { continuation in
            //日本語をパソコン言語になおす
            let parameters = ["term": (self.musicTF.text ?? "") + "　" + (self.artistTF.text ?? ""), "country": "jp", "limit": "14"]
            //termが検索キーワード　countryが国　limitが数の上限
            //parameterを使ってsearch以降の文を書いている
            AF.request("https://itunes.apple.com/search", parameters: parameters).responseData { response in
                //if文みたいなやつ,この場合response.resultがsuccessの時とfailureの時で場合分けをしている
                switch response.result {
                case .success:
                    //doはエラーが出なかった場合 catchはエラーが出たとき
                    do {
                        guard let data = response.data else { return }
                        let iTunesData: ITunesData = try self.decoder.decode(ITunesData.self, from: data)
                        
                        guard let musicImageURL = iTunesData.results.first?.artworkUrl100 else { continuation.resume(returning: nil)
                            return
                        }
                        continuation.resume(returning: musicImageURL)
                            
                            
                        
                    } catch {
                        print("デコードに失敗しました")
                        continuation.resume(returning: nil)
                    }
                case .failure(let error):
                    print("error", error)
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    
    func post() {
        if postEnable {
            let content = "得点:　\(scoreTF.text ?? "")\nキー:　\(keyLabel.text ?? "")\n機種:　\(selectedMenuType.rawValue)\nコメント:　\(textView.text ?? "")"
            postFB.post(musicName: musicTF.text ?? "データなし", artistName: artistTF.text ?? "データなし", musicImage: musicImage, content: content, category: category)
        }
    }
    
    
    func add() async {
        Task{
            
            if musicImage == nil {
                if let musicImageData = await self.getMusicImage() {
                    musicImage = musicImageData
                } else {
                    musicImage = material.noMusicImageURL
                }
            }
            
            
            let df = DateFormatter()
            df.dateFormat = "yy年MM月dd日HH:mm"
            df.timeZone = TimeZone.current
            let time = df.string(from: Date())
            
            let filterMusic = manager.musicList.filter {$0.musicName == musicTF.text ?? "" && $0.artistName == self.artistTF.text ?? ""}
            if !filterMusic.isEmpty {
                guard let id = filterMusic.first?.id else {
                    let alert = UIAlertController(title: "エラー", message: "エラーが発生しました", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                    return
                }
                musicFB.addMusicDetail(musicID: id, time: time, score: Double(scoreTF.text ?? "") ?? 0, key: Int(keyLabel.text ?? "") ?? 0, model: selectedMenuType.rawValue, comment: textView.text ?? "", image: image)
            } else {
                musicFB.addMusic(musicName: musicTF.text ?? "", artistName: artistTF.text ?? "", musicImage: musicImage, time: time, score: Double(scoreTF.text ?? "") ?? 0, key: Int(keyLabel.text ?? "") ?? 0, model: selectedMenuType.rawValue, comment: textView.text ?? "", image: image, completionHandler: {_ in
                    
                })
                
            }
            //追加されたことを知らせる
            fromAdd = true
            
            //2画面前に戻る
            DispatchQueue.main.async {
                let screenIndex = 0
                self.navigationController?.popToViewController(self.navigationController!.viewControllers[screenIndex], animated: true)
            }
        }
        
        
    }
    
    
    //MARK: - UI interaction
    
    @IBAction func editingChanged(_ sender: Any) {
        
        guard let _scoreValue = scoreTF.text else { return }
        
        if Double(_scoreValue) ?? 0.0 > 100 {
            scoreTF.text = String((Double(scoreTF.text ?? "") ?? 0) / 10)
        }
        // textField内の文字数
        let textFieldNumber = _scoreValue.count
        
        if textFieldNumber > 6 && Double(_scoreValue) ?? 0.0 != 100 {
            scoreTF.text = String(_scoreValue.prefix(6))
        } else if scoreTF.text == "100.0000" {
            scoreTF.text = String(_scoreValue.prefix(7))
        }
    }
    
    @IBAction func slider(_ sender: UISlider) {
        
        let preValue = round(sender.value)
        keyLabel.text = String(Int(preValue))
        if keyLabel.text == "-0.0"{
            keyLabel.text = "0.0"
        }
        customSlider.slider.setValue(preValue, animated: false)
        if preValue != sliderValue {
            utility.playImpact(type: .impact(.light))
            sliderValue = preValue
            for i in 0..<scaleList.count {
                if i  <= Int(sliderValue) + 7 {
                    scaleList[i].backgroundColor = UIColor.imageColor
                } else {
                    scaleList[i].backgroundColor = UIColor.label
                }
            }
        }
    }
    
    @IBAction func tapAddBtn(_ sender: UIButton) {
        if musicTF.text != "" && artistTF.text != "" {
            if scoreTF != nil && Double(scoreTF.text!) != nil {
                Task {
                    await add()
                    post()
                }
            } else {
                alertCtl = UIAlertController(title: "入力ミス", message: "スコアがうまく入力されていません", preferredStyle: .alert)
                alertCtl.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertCtl, animated: true, completion: nil)
            }
        } else {
            
            alertCtl = UIAlertController(title: "入力ミス", message: "値がうまく入力されていません", preferredStyle: .alert)
            alertCtl.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertCtl, animated: true, completion: nil)
            
            
        }
    }
    
    @IBAction func tapCheckBox() {
        postEnable.toggle()
        categoryView.isHidden.toggle()
    }
    
    
    @IBAction func switchImage() {
        
        backView.isHidden.toggle()
        imageView.isHidden.toggle()
        closeBtn.isHidden.toggle()
        
    }
    
}


//MARK: - UITableViewDelegate

extension AddMusicViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        guard let rows = tableView.indexPathsForSelectedRows else { return }
        if rows.count <= 5 {
            cell?.accessoryType = .checkmark
            setCategory()
        }else{
            func alert(title: String, message: String) {
                alertCtl = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertCtl.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertCtl, animated: true)
            }
            alert(title: "入力ミス", message: "選択できるのは5個までです")
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .none
        setCategory()
    }
}


//MARK UITableViewDataSource

extension AddMusicViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return material.categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = material.categoryList[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.textColor = .white
        
        cell.backgroundColor = .black
        // セルの状態を確認しチェック状態を反映する
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        guard let contains = selectedIndexPaths?.contains(indexPath) else { return cell }
        if selectedIndexPaths != nil && contains {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
}


//MARK: - UITextFieldDelegate

extension AddMusicViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == musicTF {
            artistTF.becomeFirstResponder()
        } else if textField == artistTF {
            scoreTF.becomeFirstResponder()
        }
        return true
    }
}
