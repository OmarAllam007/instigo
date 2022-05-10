//
//  SharePostViewController.swift
//  instigo
//
//  Created by Omar Khaled on 18/04/2022.
//

import UIKit
import Firebase

class SharePostViewController: UIViewController {

    var selectedImage:UIImage? {
        didSet{
            self.postImage.image = selectedImage
        }
    }
    
    
    let postImage:UIImageView = {
        let i = UIImageView()
        i.layer.cornerRadius = 10
        i.layer.masksToBounds = true
        i.contentMode = .scaleAspectFill
        return i
    }()
    
    
    let textView:UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 14)
        return tv
    }()
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let uiviewContainer:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(sharePost))
        
        setupPostView()
        
    }
    
    
    private func setupPostView(){
        
        view.addSubview(uiviewContainer)
        
        uiviewContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: view.frame.height / 6, width: 0)
        
        view.addSubview(postImage)
        
        
        postImage.anchor(top: uiviewContainer.topAnchor, leading: uiviewContainer.leadingAnchor, trailing: nil, bottom: uiviewContainer.bottomAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 8, paddingBottom: 8, height: 0, width: view.frame.width / 4)
        
        view.addSubview(textView)
        
        textView.anchor(top: uiviewContainer.topAnchor, leading: postImage.trailingAnchor, trailing: nil , bottom: uiviewContainer.bottomAnchor, paddingTop: 8, paddingLeft: 2, paddingRight: 2, paddingBottom: 8, height: 0, width: view.frame.width)
    }
    
    @objc private func sharePost(){
        guard let selectedImage = selectedImage else {
            return
        }
    
        let filename = NSUUID().uuidString
        
        guard let data = selectedImage.jpegData(compressionQuality: 0.5) else { return }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        storageRef.putData(data, metadata: nil) { metadata, error in
            
            if let error = error {
                print("Failed to upload the image, ", error.localizedDescription)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            storageRef.downloadURL { url, error in
                
                if let err = error {
                    print("download error ,", err)
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    return
                }
                
                guard let imageUrl = url?.absoluteString else { return }
                self.savePostToDatabase(imageURL: imageUrl)
            }
            
            
        }
    }
    
    static let updateHomeNotificationName = Notification.Name("updateHomeView")
    
    fileprivate func savePostToDatabase(imageURL:String){
        guard let uuid = Auth.auth().currentUser?.uid else { return }
        guard let postImage = selectedImage else { return }
        
        guard let description = self.textView.text, !description.isEmpty else { return }
        
        let dbRef = Database.database().reference().child("posts").child(uuid)
        let ref = dbRef.childByAutoId()
        
        
        let data = ["imageURL":imageURL,"description":description,
                    "imageWidth":postImage.size.width,
                    "imageHeight":postImage.size.height,
                    "created_at": Date().timeIntervalSince1970
        ] as [String:Any]
        
        ref.updateChildValues(data) { error, ref in
            if let error = error {
                print("save to db error",error.localizedDescription)
                return
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(Notification(name: SharePostViewController.updateHomeNotificationName, object: nil))
        }
    }

}
