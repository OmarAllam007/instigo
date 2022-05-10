//
//  CameraViewController.swift
//  instigo
//
//  Created by Omar Khaled on 25/04/2022.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController,AVCapturePhotoCaptureDelegate,UIViewControllerTransitioningDelegate {

    let captureImageButton:UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        return btn
    }()
    

     
    let presentCustomPresentor = CustomAnimationPresentor()
    let dismissedCustomPresentor = CustomDismissedAnimation()
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissedCustomPresentor
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            
        return presentCustomPresentor
    }
    
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        setupCameraSession()
        
        view.addSubview(captureImageButton)
        
        captureImageButton.anchor(top: nil, leading: nil, trailing: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 0, width: 0)
        
        captureImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc func capturePhoto(){
        
        
        let settings = AVCapturePhotoSettings()
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else {return}
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String:previewFormatType]
        output.capturePhoto(with: settings, delegate: self)
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
     

        let imageData = photo.fileDataRepresentation()
        let previewImage = UIImage(data: imageData!)
        
        
        let containerView = CapturedPhotoView()
        containerView.containerImage.image = previewImage
        view.addSubview(containerView)
        
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 0, width: 0)
        
    }
    

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
    
       
//
        
    }
    
    
    let output = AVCapturePhotoOutput()
    func setupCameraSession(){
        
        let captureSession = AVCaptureSession()
        
        // 1.setup inputs
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        do{
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        
        }catch {
            print("error when load session")
        }
        
        //2. setup output
        
        
        
        if captureSession.canAddOutput(output){
            captureSession.addOutput(output)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
    }


}
