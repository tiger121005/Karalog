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
    var musicImage: Data!
    var sliderValue: Float = 0
    var selectedMenuType = ModelMenuType.未選択
    var alertCtl: UIAlertController!
    var callView: Bool = true
    var scaleList: [UIView] = []
    var postEnable: Bool = false
    var category: [String] = []
    
    let config = MLModelConfiguration()
    var requestModel: VNCoreMLRequest!
    var requestDetectModel: VNCoreMLRequest!
    
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
    @IBOutlet var checkBox: UIView!
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
        if let image {
            
            classifyModel()
        }
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
        actions.append(UIAction(title: ModelMenuType.未選択.rawValue, image: nil, state: self.selectedMenuType == ModelMenuType.未選択 ? .on : .off,
                                handler: { (_) in
                                    self.selectedMenuType = .未選択
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
            let areaHeight = (tabBarController?.tabBar.frame.minY)! - (navigationController?.navigationBar.frame.maxY)!
            let areaCenter = (navigationController?.navigationBar.frame.maxY)! + (areaHeight / 2)
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
            btnImage = btnImage.resized(toWidth: 60)!
            closeBtn.setImage(btnImage, for: .normal)
            
            view.addSubview(backView)
            view.addSubview(imageView)
            view.addSubview(closeBtn)
            
            backView.isHidden = true
            imageView.isHidden = true
            closeBtn.isHidden = true
        }
    }
    
    
    func getMusicImage() async -> Data? {
        await withCheckedContinuation { continuation in
            //日本語をパソコン言語になおす
            let parameters = ["term": (musicTF.text ?? "") + "　" + (artistTF.text ?? ""), "country": "jp", "limit": "14"]
            //termが検索キーワード　countryが国　limitが数の上限
            //parameterを使ってsearch以降の文を書いている
            AF.request("https://itunes.apple.com/search", parameters: parameters).responseData { response in
                //if文みたいなやつ,この場合response.resultがsuccessの時とfailureの時で場合分けをしている
                switch response.result {
                case .success:
                    //doはエラーが出なかった場合 catchはエラーが出たとき
                    do {
                        let iTunesData: ITunesData = try self.decoder.decode(ITunesData.self, from: response.data!)
                        
                        if let musicImageURL = iTunesData.results.first?.artworkUrl100 {
                            
                            if let imageUrl = URL(string: musicImageURL) {
                                
                                Task {
    
                                    let (data, _) = try await URLSession.shared.data(from: imageUrl)
                                    
                                    continuation.resume(returning: data)
                                }
                                
                            } else {
                                continuation.resume(returning: nil)
                            }
                            
                        } else {
                            continuation.resume(returning: nil)
                        }
                        
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
    
    
    //撮影した画像を機種ごとに分類する
    func classifyModel() {
        
        let model = try? VNCoreMLModel(for: KaraokeClassifier(configuration: config).model)
        
        requestModel = VNCoreMLRequest(model: model!) { (request, error) in
            if let _error = error {
                
                print("Error: \(_error)")
                return
            }
            
            
            guard let _results = request.results as? [VNClassificationObservation], let _firstObservation = _results.first else {
                return
            }
            let predictModel = _firstObservation.identifier
//            DispatchQueue.main.async {
//                self.addFrame(model: _firstObservation.identifier)
//            }
            self.branchImage(kind: predictModel)
        }
        if let cgImage = image.cgImage {
            // imageRequestHanderにimageをセット
            let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage)
            // imageRequestHandlerにrequestをセットし、実行
            try? imageRequestHandler.perform([requestModel])
        }
    }
    
    //機種によって分類する
    func branchImage(kind: String) {
        var mlModel: MLModel!
        switch kind {
        case Model.DAMAI.rawValue:
            mlModel = try? Detect_DAM_AI(configuration: config).model
            self.selectedMenuType = .DAM
            self.configureMenuButton()
        case Model.DAMDXG.rawValue:
            mlModel = try? Detect_DAM_DX_G(configuration: config).model
            self.selectedMenuType = .DAM
            self.configureMenuButton()
        case Model.JOYnew.rawValue:
            mlModel = try? Detect_JOY_new(configuration: config).model
            self.selectedMenuType = .JOYSOUND
            self.configureMenuButton()
        case Model.JOYold.rawValue:
            mlModel = try? Detect_JOY_old(configuration: config).model
            self.selectedMenuType = .JOYSOUND
            self.configureMenuButton()
        default:
            return
        }
        detectString(mlModel: mlModel)
    }
    
    //得点などの記録の位置を取得し、文字認識をしてデータを取り込む
    func detectString(mlModel: MLModel) {
        guard let model = try? VNCoreMLModel(for: mlModel) else { return }
        requestDetectModel = VNCoreMLRequest(model: model) { (request, error) in
            if let _error = error {
                print("Error: \(_error)")
                return
            }
            
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
            
            var musicText: String!
            var artistText: String!
            var scoreText: String!
            var commentText: String!
            print("results: ", results)
            for result in results {
                //やってみてから調整
                // ラベル名。「labels」の０番目（例えば”Car”の信頼度が一番高い。１番目（例えば”Truck”）の信頼度が次に高い。
                let label:String = result.labels.first!.identifier
                
                print("model label: ", label)
                // "Car"
                switch label {
                case Objects.music.rawValue:
                    

                    guard let trimedImage = self.trimmingImage(trimmingArea: result.boundingBox).cgImage else {
                        print("error music trimed")
                        return
                        
                    }
                    
                    self.getString(cgImage: trimedImage) { results in
                        var musicY: CGFloat!
                        for visionRequest in results {
                            print("music", visionRequest.topCandidates(1).first?.string ?? "")
                            if var musicY {
                                if visionRequest.boundingBox.minY < musicY {
                                    musicY = visionRequest.boundingBox.minY
                                    musicText = visionRequest.topCandidates(1).first?.string
                                }
                            } else {
                                musicY = visionRequest.boundingBox.minY
                                musicText = visionRequest.topCandidates(1).first?.string
                            }
                            
                            
                        }
                        
                        self.musicTF.text = musicText
                    }
                    
                case Objects.artist.rawValue:
                    
                    
                    guard let trimedImage = self.trimmingImage(trimmingArea: result.boundingBox).cgImage else {
                        print("error artist trimed")
                        return
                        
                    }
                    self.getString(cgImage: trimedImage) { results in
                        
                        var artistY: CGFloat!
                        for visionRequest in results {
                            print("artist", visionRequest.topCandidates(1).first?.string ?? "")
                            if var artistY {
                                if visionRequest.boundingBox.minY < artistY {
                                    artistY = visionRequest.boundingBox.minY
                                    artistText = visionRequest.topCandidates(1).first?.string
                                }
                            } else {
                                artistY = visionRequest.boundingBox.minY
                                artistText = visionRequest.topCandidates(1).first?.string
                            }
                            
                            
                        }
                        
                        self.artistTF.text = artistText
                        
                    }
                    
                case Objects.score.rawValue:
                    

                    guard let trimedImage = self.trimmingImage(trimmingArea: result.boundingBox).cgImage else {
                        print("error score trimed")
                        return
                        
                    }
                    
                    self.getString(cgImage: trimedImage) { results in
                        var scoreMaxHeight: CGFloat!
                        var largeText: String!
                        var scoreSecondHeight: CGFloat!
                        var smallText: String!
                        for visionRequest in results {
                            
                            if var scoreMaxHeight {
                                
                                if visionRequest.boundingBox.height > scoreMaxHeight {
                                    
                                    scoreSecondHeight = scoreMaxHeight
                                    smallText = largeText
                                    scoreMaxHeight = visionRequest.boundingBox.height
                                    largeText = visionRequest.topCandidates(1).first?.string
                                    
                                } else if visionRequest.boundingBox.height > scoreSecondHeight {
                                    
                                    scoreSecondHeight = visionRequest.boundingBox.height
                                    smallText = visionRequest.topCandidates(1).first?.string
                                    
                                }
                            } else {
                                
                                scoreMaxHeight = visionRequest.boundingBox.height
                                largeText = visionRequest.topCandidates(1).first?.string
                                
                            }
                            
                            guard let largeScore = Double(largeText) else { return }
                            
                            if largeText.count >= 6 {
                                if largeText.last == "点" {
                                    largeText = String(largeText.dropLast())
                                }
                                scoreText = largeText
                                
                            } else {
                                
                                if largeText.last == "." {
                                    largeText = String(largeText.dropLast())
                                }
                                if var smallText {
                                    if smallText.first == "." {
                                        smallText = String(smallText.dropFirst())
                                    }
                                    if smallText.last == "点" {
                                        smallText = String(smallText.dropLast())
                                    }
                                    scoreText = largeText + "." + smallText
                                }
                            }
                            
                        }
                        
                        self.scoreTF.text = scoreText
                    }
                    
                case Objects.comment.rawValue:
                    
                    
                    guard let trimedImage = self.trimmingImage(trimmingArea: result.boundingBox).cgImage else {
                        print("error comment trimed")
                        return
                        
                    }
                    
                    self.getString(cgImage: trimedImage) { results in
                        var first = true
                        for visionRequest in results {
                            if first {
                                commentText = visionRequest.topCandidates(1).first?.string
                                first = false
                            } else {
                                commentText += visionRequest.topCandidates(1).first?.string ?? ""
                            }
                        }
                        
                        self.textView.text = commentText
                    }
                    
                default:
                    break
                    
                }

            }
            
        }
        
        if let cgImage = image.cgImage {
            // imageRequestHanderにimageをセット
            let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage)
            // imageRequestHandlerにrequestをセットし、実行
            try? imageRequestHandler.perform([requestDetectModel])
        }
        
        
        
    }

    func trimmingImage(trimmingArea: CGRect) -> UIImage {
        let cgImage = image.cgImage!
        
        let imgRef = cgImage.cropping(to: CGRect(x: trimmingArea.minX * image.size.height,
                                                 y: image.size.width - (trimmingArea.maxY * image.size.width),
                                                 width: trimmingArea.width * image.size.height,
                                                 height: trimmingArea.height * image.size.width))
        
        let trimImage = UIImage(cgImage: imgRef!, scale: 0, orientation: image.imageOrientation)
        
        return trimImage
        
    }
    
    //文字認識を行う
    func getString(cgImage: CGImage, completionHandler: @escaping([VNRecognizedTextObservation]) -> Void) {
        let request = VNRecognizeTextRequest { (request, error) in
            guard let _results = request.results as? [VNRecognizedTextObservation] else {
                print("error get string")
                return
                
            }
            completionHandler(_results)
            print(_results)
        }

        request.recognitionLanguages = ["ja-JP", "en_US"]
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
    }
    
    func post() {
        if postEnable {
            let content = "得点:　\(scoreTF.text!)\nキー:　\(keyLabel.text!)\n機種:　\(selectedMenuType.rawValue)\nコメント:　\(textView.text!)"
            postFB.post(musicName: musicTF.text!, artistName: artistTF.text!, musicImage: musicImage, content: content, category: category)
        }
    }
    
    
    func add() async {
        Task{
            
            if musicImage == nil {
                if let musicImageData = await getMusicImage() {
                    musicImage = musicImageData
                } else {
                    musicImage = UIImage.musicNote.withTintColor(UIColor.imageColor).jpegData(compressionQuality: 1.0)
                }
            }
            
            
            let df = DateFormatter()
            df.dateFormat = "yy年MM月dd日HH:mm"
            df.timeZone = TimeZone.current
            let time = df.string(from: Date())
            
            let filterMusic = manager.musicList.filter {$0.musicName == musicTF.text! && $0.artistName == artistTF.text!}
            if !filterMusic.isEmpty {
                guard let id = filterMusic.first?.id else {
                    let alert = UIAlertController(title: "エラー", message: "エラーが発生しました", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                    return
                }
                musicFB.addMusicDetail(musicID: id, time: time, score: Double(scoreTF.text!)!, key: Int(keyLabel.text!)!, model: selectedMenuType.rawValue, comment: textView.text!)
            } else {
                musicFB.addMusic(musicName: musicTF.text!, artistName: artistTF.text!, musicImage: musicImage, time: time, score: Double(scoreTF.text!)!, key: Int(keyLabel.text!)!, model: selectedMenuType.rawValue, comment: textView.text!, completionHandler: {_ in
                    
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
            scoreTF.text = String(Double(scoreTF.text!)! / 10)
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
            function.playImpact(type: .impact(.light))
            sliderValue = preValue
            for i in 0...scaleList.count - 1 {
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
        if tableView.indexPathsForSelectedRows!.count <= 5 {
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
        // セルの状態を確認しチェック状態を反映する
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        if selectedIndexPaths != nil && (selectedIndexPaths?.contains(indexPath))! {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.backgroundColor = .black
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
