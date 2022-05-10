//
//  CapturedPhotoView.swift
//  instigo
//
//  Created by Omar Khaled on 26/04/2022.
//

import UIKit
import Photos

class CapturedPhotoView: UIView {
    
    let saveButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
                button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        
        return button
    }()
    
    
    let cancelButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancel_shadow"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        
        return button
    }()
    
    let containerImage:UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let label : UILabel = {
        let lbl = UILabel()
        lbl.text = "aksdmalkdmaldsad"
        lbl.textColor = .white
        return lbl
    }()
    
    
    
    @objc func handleCancel(){
        self.removeFromSuperview()
    }
    
    
    
    @objc func handleSave(){
        guard let previewImage = containerImage.image else {return}
        
        let library = PHPhotoLibrary.shared()
        library.performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        } completionHandler: { success, error in
            if let error  = error {
                print("error while saving the image", error)
            }
            
            
            DispatchQueue.main.async {
                let saveLabel = UILabel()
                saveLabel.text = "Saved Successfully"
                saveLabel.textColor = .white
                saveLabel.numberOfLines = 0
                saveLabel.font = .boldSystemFont(ofSize: 14)
                saveLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                saveLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width * 0.9, height: 80)
                saveLabel.center = self.center
                saveLabel.textAlignment = .center
                self.addSubview(saveLabel)
                
                
                saveLabel.layer.transform = CATransform3DMakeScale(0,0,0)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    saveLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                } completion: { completed in
                    
                    UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                        saveLabel.layer.transform = CATransform3DMakeScale(0.1,0.1,0.1)
                        saveLabel.alpha = 0
                    } completion: { _ in
                        saveLabel.removeFromSuperview()
                    }
                    
                }
                
            }
        }
        
        
        
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.addSubview(self.containerImage)
        
        
        self.containerImage.anchor(top: self.topAnchor, leading: self.leadingAnchor, trailing: self.trailingAnchor, bottom: self.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 0, width: 0)
        
        
        
        self.addSubview(self.saveButton)
        
        self.saveButton.anchor(top: nil, leading: self.safeAreaLayoutGuide.leadingAnchor, trailing: nil, bottom: self.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 50, width: 50)
        
        
        self.addSubview(self.cancelButton)
        
        self.cancelButton.anchor(top: self.safeAreaLayoutGuide.topAnchor, leading: self.safeAreaLayoutGuide.leadingAnchor, trailing: nil, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 50, width: 50)
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
