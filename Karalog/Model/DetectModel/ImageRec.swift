//
//  ImageRec.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/10/03.
//
import UIKit
import CoreML
import Vision


//MARK: - ImageRec

let imageRec = ImageRec.shared

class ImageRec {
    
    static let shared = ImageRec()
    
    var image: UIImage!
    let config = MLModelConfiguration()
    var requestModel: VNCoreMLRequest!
    var requestDetectModel: VNCoreMLRequest!
    
    let emptyLog = DetectLog(music: "", artist: "", score: "", model: "", comment: "")
    
    
    //MARK: - imageRec {
    func rec(image: UIImage) -> DetectLog {
        self.image = image
        guard let model = classifyModel() else { print("AA"); return emptyLog }
        guard var getLog = detectString(kind: model) else { return DetectLog(music: "", artist: "", score: "", model: model, comment: "") }
        getLog.model = model
        return getLog
    }
    
    
    //MARK: - crassifyModel
    
    //撮影した画像を機種ごとに分類する
    func classifyModel() -> String? {
        var model: VNCoreMLModel!
        var kind: String?
        do {
            model = try VNCoreMLModel(for: KaraokeClassifier(configuration: config).model)
        } catch {
            return nil
            
        }
        
        
        requestModel = VNCoreMLRequest(model: model) { (request, error) in
            if let _error = error {
                
                print("Error: \(_error)")
                return
            }
            
            
            guard let _results = request.results as? [VNClassificationObservation], let _firstObservation = _results.first else {
                return
            }
            let predictModel = _firstObservation.identifier
            kind = predictModel
            return
        }
        
        guard let cgImage = image.cgImage else { print("AA"); return nil }
        // imageRequestHanderにimageをセット
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage)
        // imageRequestHandlerにrequestをセットし、実行
        try? imageRequestHandler.perform([requestModel])
        return kind
    }
    
    
    //MARK: - detectString
    
    //得点などの記録の位置を取得し、文字認識をしてデータを取り込む
    func detectString(kind: String) -> DetectLog? {
        var mlModel: MLModel?
        switch kind {
        case Model.DAMAI.rawValue:
            mlModel = try? Detect_DAM_AI(configuration: self.config).model
            
        case Model.DAMDXG.rawValue:
            mlModel = try? Detect_DAM_DX_G(configuration: self.config).model
            
        case Model.JOYnew.rawValue:
            mlModel = try? Detect_JOY_new(configuration: self.config).model
            
        case Model.JOYold.rawValue:
            mlModel = try? Detect_JOY_old(configuration: self.config).model
            
        default:
            return nil
        }
        guard let mlModel else { return nil }
        guard let model = try? VNCoreMLModel(for: mlModel) else { return nil }
        var musicText: String = ""
        var artistText: String = ""
        var scoreText: String = ""
        var commentText: String = ""
        requestDetectModel = VNCoreMLRequest(model: model) { (request, error) in
            if let _error = error {
                print("Error: \(_error)")
                return
            }
            
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
            
            
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
                        continue
                        
                    }
                    
                    self.getString(cgImage: trimedImage) { results in
                        var musicY: CGFloat!
                        for visionRequest in results {
                            print("music", visionRequest.topCandidates(1).first?.string ?? "")
                            guard var musicY else {
                                musicY = visionRequest.boundingBox.minY
                                musicText = visionRequest.topCandidates(1).first?.string ?? ""
                                continue
                            }
                            if visionRequest.boundingBox.minY < musicY {
                                musicY = visionRequest.boundingBox.minY
                                musicText = visionRequest.topCandidates(1).first?.string ?? ""
                            }
                        }
                        
                    }
                    
                case Objects.artist.rawValue:
                    
                    
                    guard let trimedImage = self.trimmingImage(trimmingArea: result.boundingBox).cgImage else {
                        print("error artist trimed")
                        continue
                        
                    }
                    self.getString(cgImage: trimedImage) { results in
                        
                        var artistY: CGFloat!
                        for visionRequest in results {
                            print("artist", visionRequest.topCandidates(1).first?.string ?? "")
                            guard var artistY else {
                                artistY = visionRequest.boundingBox.minY
                                artistText = visionRequest.topCandidates(1).first?.string ?? ""
                                continue
                            }
                            if visionRequest.boundingBox.minY < artistY {
                                artistY = visionRequest.boundingBox.minY
                                artistText = visionRequest.topCandidates(1).first?.string ?? ""
                            }
                        }
                    }
                    
                case Objects.score.rawValue:
                    
                    
                    guard let trimedImage = self.trimmingImage(trimmingArea: result.boundingBox).cgImage else {
                        print("error score trimed")
                        continue
                        
                    }
                    
                    self.getString(cgImage: trimedImage) { results in
                        var scoreMaxHeight: CGFloat!
                        var largeText: String!
                        var scoreSecondHeight: CGFloat!
                        var smallText: String!
                        for visionRequest in results {
                            
                            guard var scoreMaxHeight else {
                                scoreMaxHeight = visionRequest.boundingBox.height
                                largeText = visionRequest.topCandidates(1).first?.string
                                continue
                            }
                            
                            
                            if visionRequest.boundingBox.height > scoreMaxHeight {
                                
                                scoreSecondHeight = scoreMaxHeight
                                smallText = largeText
                                scoreMaxHeight = visionRequest.boundingBox.height
                                largeText = visionRequest.topCandidates(1).first?.string
                                
                            } else if visionRequest.boundingBox.height > scoreSecondHeight {
                                
                                scoreSecondHeight = visionRequest.boundingBox.height
                                smallText = visionRequest.topCandidates(1).first?.string
                                
                            }
                        }
                        
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
                    
                case Objects.comment.rawValue:
                    
                    
                    guard let trimedImage = self.trimmingImage(trimmingArea: result.boundingBox).cgImage else {
                        print("error comment trimed")
                        continue
                        
                    }
                    
                    self.getString(cgImage: trimedImage) { results in
                        var first = true
                        for visionRequest in results {
                            if first {
                                commentText = visionRequest.topCandidates(1).first?.string ?? ""
                                first = false
                            } else {
                                commentText += visionRequest.topCandidates(1).first?.string ?? ""
                            }
                        }
                    }
                    
                default:
                    continue
                    
                }
            }
        }
        
        guard let cgImage = image.cgImage else { return nil }
        // imageRequestHanderにimageをセット
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage)
        // imageRequestHandlerにrequestをセットし、実行
        try? imageRequestHandler.perform([requestDetectModel])
        return DetectLog(music: musicText, artist: artistText, score: scoreText, model: "", comment: commentText)
        
    }
    
    
    //MARK: - trimmingImage

    func trimmingImage(trimmingArea: CGRect) -> UIImage {
        let cgImage = image.cgImage!
        
        guard let imgRef = cgImage.cropping(to: CGRect(x: trimmingArea.minX * image.size.height,
                                                 y: image.size.width - (trimmingArea.maxY * image.size.width),
                                                 width: trimmingArea.width * image.size.height,
                                                       height: trimmingArea.height * image.size.width)) else { return UIImage.heart}
        
        let trimImage = UIImage(cgImage: imgRef, scale: 0, orientation: image.imageOrientation)
        
        return trimImage
        
    }
    
    
    //MARK: - getString
    
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
}
