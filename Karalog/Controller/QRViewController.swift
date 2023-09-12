//
//  QRViewController.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/09/08.
//

import UIKit
import AVFoundation
import QRCode


//MARK: - QRViewController

class QRViewController: UIViewController {
    
    var userID: String!
    var gotID: String!
    //カメラ用のAVsessionインスタンス作成
    let AVsession = AVCaptureSession()
    //カメラ画像を表示するレイヤー
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    // カメラの設定
    // 今回は背面カメラなのでposition: .back
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
    var firstCamera = true
    
    
    //MARK: - UI objects
    
    @IBOutlet var QRImageView: UIImageView!
    var cancelBtn = UIButton()
    var backView = UIView()
    
    
    //MARK: - View Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupQR()
        title = "QRコード"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            let nextView = segue.destination as! ProfileViewController
            nextView.userID = gotID
        }
    }
    
    
    //MARK: - Setup
    
    func setupQR() {
        
        let doc = QRCode.Document(utf8String: userID, errorCorrection: .high)
        doc.design.backgroundColor(UIColor.baseColor.cgColor)
        doc.design.shape.eye = QRCode.EyeShape.RoundedRect()
        doc.design.style.onPixels = QRCode.FillStyle.Solid(UIColor.imageColor.cgColor)
        doc.logoTemplate = QRCode.LogoTemplate(image: UIImage.KaralogQRImage.cgImage!)
        
        let generated = doc.cgImage(CGSize(width: 800, height: 800))
        QRImageView.image = UIImage(cgImage: generated!)
    }
    
    
    //MARK: - UI interaction
    
    @IBAction func readQR() {
        if firstCamera {
            //カメラデバイスの取得
            let devices = discoverySession.devices
            
            //背面のカメラ情報を取得
            if let backCamera = devices.first {
                do {
                    //カメラ入力をinputとして取得
                    let input = try AVCaptureDeviceInput(device: backCamera)
                    
                    //Metadata情報（今回はQRコード）を取得する準備
                    //AVssessionにinputを追加:既に追加されている場合を考慮してemptyチェックをする
                    if AVsession.inputs.isEmpty {
                        AVsession.addInput(input)
                        //MetadataOutput型の出力用の箱を用意
                        let captureMetadataOutput = AVCaptureMetadataOutput()
                        //captureMetadataOutputに先ほど入力したinputのmetadataoutputを入れる
                        AVsession.addOutput(captureMetadataOutput)
                        //MetadataObjectsのdelegateに自己(self)をセット
                        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        //Metadataの出力タイプをqrにセット
                        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                        
                        //カメラ画像表示viewの準備とカメラの開始
                        //カメラ画像を表示するAVCaptureVideoPreviewLayer型のオブジェクトをsessionをAVsessionで初期化でプレビューレイヤを初期化
                        videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: AVsession)
                        backView.backgroundColor = UIColor.baseColor
                        backView.frame = view.layer.bounds
                        cancelBtn.setTitle("キャンセル", for: .normal)
                        cancelBtn.setTitleColor(UIColor.imageColor, for: .normal)
                        let cancel = UIAction() {_ in
                            //一旦停止
                            self.AVsession.stopRunning()
                            self.videoPreviewLayer?.removeFromSuperlayer()
                            self.cancelBtn.isHidden = true
                            self.backView.isHidden = true
                        }
                        cancelBtn.addAction(cancel, for: .touchUpInside)
                        cancelBtn.frame = CGRect(x: view.frame.width - 110,
                                                 y: (navigationController?.navigationBar.frame.maxY)! + 10,
                                                 width: 100,
                                                 height: 30)
                        //カメラ画像を表示するvideoPreviewLayerの大きさをview（superview）の大きさに設定
                        let safeHeight = (tabBarController?.tabBar.frame.minY)! - (navigationController?.navigationBar.frame.maxY)!
                        videoPreviewLayer?.frame = CGRect(x: 0,
                                                          y: (self.navigationController?.navigationBar.frame.maxY)! + 50,
                                                          width: backView.frame.width,
                                                          height: safeHeight - 50)
                        //カメラ画像を表示するvideoPreviewLayerをビューに追加
                        view.addSubview(backView)
                        view.addSubview(cancelBtn)
                        view.layer.addSublayer(videoPreviewLayer!)
                    }
                    //セッションの開始(今回はカメラの開始)
                    DispatchQueue.global(qos: .background).async {
                        self.AVsession.startRunning()
                        self.firstCamera = false
                    }
                } catch {
                    print("Error occured while creating video device input: \(error)")
                }
            }
        } else {
            self.backView.isHidden = false
            self.cancelBtn.isHidden = false
            view.layer.addSublayer(videoPreviewLayer!)
            DispatchQueue.global(qos: .background).async {
                self.AVsession.startRunning()
            }
            
            
        }
        
    }
    
}


//MARK: - AVCaptureMetaDataOutputObjectDelegate

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        //カメラ画像にオブジェクトがあるか確認
        if metadataObjects.count == 0 {
            return
        }
        //オブジェクトの中身を確認
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // metadataのtype： metadata.type
            // QRの中身： metadata.stringValue
            guard let value = metadata.stringValue else { return }
            print("読み取りvalue：",value)
            //一旦停止
            AVsession.stopRunning()
            videoPreviewLayer?.removeFromSuperlayer()
            cancelBtn.removeFromSuperview()
            backView.removeFromSuperview()

            gotID = value
            performSegue(withIdentifier: "toProfile", sender: nil)

        }
    }
}
