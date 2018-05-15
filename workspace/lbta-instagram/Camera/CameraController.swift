//
//  CameraController.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 14/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    let output = AVCapturePhotoOutput()
    
    let capturePhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleCapture), for: .touchUpInside)
        return btn
    }()
    
    let dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return btn
    }()
    
    let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupHUD()
    }
    
    @objc fileprivate func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handleCapture() {
//        print("Capturing photo...")
        let photoSettings = AVCapturePhotoSettings()
        
        guard let previewFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first else { return }
        photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey: previewFormatType] as [String : Any]
        
        output.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        
        let previewImageView = UIImageView(image: previewImage)
        
        view.addSubview(previewImageView)
        previewImageView.anchor(top: view.topAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0)
        
        previewImageView.addSubview(cancelButton)
        cancelButton.anchor(top: previewImageView.topAnchor, bottom: nil, left: nil, right: previewImageView.rightAnchor, paddingTop: 12, paddingBottom: 0, paddingLeft: 0, paddingRight: 12, width: 50, height: 50)
    }
    
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let err {
            print("Could not setup camera input:", err)
        }
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    fileprivate func setupHUD() {
        [capturePhotoButton, dismissButton].forEach({view.addSubview($0)})
        capturePhotoButton.anchor(top: nil, bottom: view.bottomAnchor, left: nil, right: nil, paddingTop: 0, paddingBottom: 20, paddingLeft: 0, paddingRight: 0, width: 80, height: 80)
        capturePhotoButton.anchorXYCenter(centerX: view.centerXAnchor, centerY: nil)
        
        dismissButton.anchor(top: view.topAnchor, bottom: nil, left: nil, right: view.rightAnchor, paddingTop: 12, paddingBottom: 0, paddingLeft: 0, paddingRight: 12, width: 50, height: 50)
    }
}
