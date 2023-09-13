//
//  CameraViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/09/13.
//

import UIKit
import AVFoundation
import Vision



//MARK: - CameraViewController

class CameraViewController: UIViewController {
    
    
    //撮影した画像
    var image: UIImage!
    
    //zoomの値の初期設定
    var baseZoomFactor: CGFloat = 1.0
    
    //カメラの縦横比
    var bufferAspectRatio: Double!
    
    //撮影するためのもの
    var photoOutput = AVCapturePhotoOutput()
    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: "com.example.apple-samplecode.CaptureSessionQueue")
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var captureDevice: AVCaptureDevice?
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //画面の回転に関わる
    var regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
    var textOrientation = CGImagePropertyOrientation.up
    var uiRotationTransform = CGAffineTransform.identity
    var roiToGlobalTransform = CGAffineTransform.identity
    var visionToAVFTransform = CGAffineTransform.identity
    var bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
    //画面の向き
    var currentOrientation = UIDeviceOrientation.portrait
    
    //撮影するまでの画面
    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDataOutputQueue = DispatchQueue(label: "com.example.apple-samplecode.VideoDataoutputQueue")
    
    //text認識に使う
    var request: VNRecognizeTextRequest!
    
    //認識した文字の枠
    var boxLayer = [CAShapeLayer]()
    
    @IBOutlet var previewView: VideoView!
    @IBOutlet var cameraBtn: UIButton!
    
    
    //MARK: - View Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        previewView.session = captureSession
        captureSessionQueue.async {
            self.setupCamera()
            DispatchQueue.main.async {
                self.setupOrientationAndTransform()
            }
        }
        self.setupPinchGestureReconizer()
        
        request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        
        setupCameraBtn()
    }
    
    
    //viewのサイズが変更されようとしているタイミング
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Only change the current orientation if the new one is landscape or portrait.
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation.isPortrait || deviceOrientation.isLandscape {
            currentOrientation = deviceOrientation
        }
        
        // Handle device orientation in the preview layer.
        if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
            if let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation) {
                videoPreviewLayerConnection.videoOrientation = newVideoOrientation
            }
        }
        
        // The orientation changed. Figure out the new ROI.
//        calculateRegionOfInterest()
        setupOrientationAndTransform()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddMusic" {
            let nextView = segue.destination as! AddMusicViewController
            nextView.image = image
        }
    }
    
    
    //MARK: - Setup
    
    func setupCameraBtn() {
        var btnImage = UIImage.circleInsetFilled.withTintColor(UIColor.imageColor)
        btnImage = btnImage.resized(toWidth: 100)!
        cameraBtn.setImage(btnImage, for: .normal)
        cameraBtn.backgroundColor = .clear
        cameraBtn.layer.cornerRadius = cameraBtn.frame.height * 0.5
        
    }
    
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    
    //画面の向きが変わった時に呼び出される
    func setupOrientationAndTransform() {
        let roi = regionOfInterest
        roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y).scaledBy(x: roi.width, y: roi.height)
        
        switch currentOrientation {
        case .portraitUpsideDown:
            textOrientation = .left
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 0).rotated(by: CGFloat.pi / 2)
        case .landscapeLeft:
            textOrientation = .up
            uiRotationTransform = .identity
        case .landscapeRight:
            textOrientation = .down
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 1)
        default: textOrientation = .right
            uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
        }
        
        visionToAVFTransform = roiToGlobalTransform
            .concatenating(bottomToTopTransform)
            .concatenating(uiRotationTransform)
    }
    
    func setupCamera() {
        guard let _captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Could not create capture device.")
            return
        }
        self.captureDevice = _captureDevice
        
        if _captureDevice.supportsSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = .hd4K3840x2160
            bufferAspectRatio = 3840.0 / 2160.0
        } else {
            captureSession.sessionPreset = .hd1920x1080
            bufferAspectRatio = 1920.0 / 1080.0
        }
        
        guard let _deviceInput = try? AVCaptureDeviceInput(device: _captureDevice) else {
            print("Could not create device input.")
            return
        }
        if captureSession.canAddInput(_deviceInput) {
            captureSession.addInput(_deviceInput)
        }
        
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.connection(with: .video)?.preferredVideoStabilizationMode = .off
        } else {
            print("Could not add VDO output")
            return
        }
        
        photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])])
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.startRunning()
    }
    
    private func setupPinchGestureReconizer() {
        let pinchGestureReconizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(onPinchGesture(_:)))
        self.view.addGestureRecognizer(pinchGestureReconizer)
    }
    
    //text認識
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        var boxes = [CGRect()]
        
        guard let _results = request.results as? [VNRecognizedTextObservation] else { return }
        
        let maximumCandidates = 1
        
        for visionResult in _results {
            boxes.append(visionResult.boundingBox)
        }
        
        show(boxGroup: boxes)
        
    }
    
    
    
    //認識したテキストに枠を描く
    func draw(rect: CGRect) {
        let layer = CAShapeLayer()
        layer.opacity = 0.5
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
        layer.frame = rect
        boxLayer.append(layer)
        previewView.videoPreviewLayer.insertSublayer(layer, at: 1)
    }
    
    //古くなったテキスト認識の枠を消す
    func removeBoxes() {
        for layer in boxLayer {
            layer.removeFromSuperlayer()
        }
        boxLayer.removeAll()
    }
    
    
    
    func show(boxGroup: [CGRect]) {
        DispatchQueue.main.async {
            let layer = self.previewView.videoPreviewLayer
            self.removeBoxes()
            for box in boxGroup {
                
                let rect = layer.layerRectConverted(fromMetadataOutputRect: box.applying(self.visionToAVFTransform))
                self.draw(rect: rect)
                
            }
        }
    }
    
    
    
    
    //MARK: - UI interaction
    
    // シャッターボタンが押された時のアクション
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        
        //カメラの手ぶれ補正
        settings.isAutoStillImageStabilizationEnabled = true
        // 撮影された画像をdelegateメソッドで処理
        self.photoOutput.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
        
    }

    
    //MARK: - Objective - C
    
    @objc private func onPinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            self.baseZoomFactor = (self.captureDevice?.videoZoomFactor)!
        }
        
        let tempZoomFactor: CGFloat = self.baseZoomFactor * sender.scale
        let newZoomFactor: CGFloat
        if tempZoomFactor < (self.captureDevice?.minAvailableVideoZoomFactor)! {
            newZoomFactor = (self.captureDevice?.minAvailableVideoZoomFactor)!
        } else if tempZoomFactor > (self.captureDevice?.maxAvailableVideoZoomFactor)! {
            newZoomFactor = (self.captureDevice?.maxAvailableVideoZoomFactor)!
        } else {
            newZoomFactor = tempZoomFactor
        }
        
        do {
            try self.captureDevice?.lockForConfiguration()
            self.captureDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 32.0)
            self.captureDevice?.unlockForConfiguration()
        } catch {
            print("Failed to change zoom factor")
        }
    }

}


//MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Data型をUIImageオブジェクトに変換
            image = UIImage(data: imageData)
            // 写真ライブラリに画像を保存
//            UIImageWriteToSavedPhotosAlbum(uiImage!, nil,nil,nil)
            self.performSegue(withIdentifier: "toAddMusic", sender: nil)
        }
    }
}


//MARK: - AVCaptureVideoOrientation

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
}


//MARK: - AVCaptureVideoDataOutputAampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if let _pixelBuffuer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            request.recognitionLanguages = ["ja"] // 日本語を指定
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            request.regionOfInterest = regionOfInterest
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: _pixelBuffuer, orientation: textOrientation, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                print(error)
            }
            
        }
    }
    
    
}


