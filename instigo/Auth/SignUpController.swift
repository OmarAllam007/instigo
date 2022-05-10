//
//  ViewController.swift
//  instigo
//
//  Created by Omar Khaled on 14/04/2022.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let loginButtonWithText:UIButton = {
        let button = UIButton(type: .system)
        let attributedText = NSMutableAttributedString(string: "Already have an account, ", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor:UIColor.lightGray,
        ])
        
        attributedText.append(NSAttributedString(string: "Login", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor:UIColor.rgb(red: 0, green: 120, blue: 175),
        ]))
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(showloginController), for: .touchUpInside)
        return button
    }()
    

    
    let addProfileImage:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(selectedImage), for: .touchUpInside)
        return button
    }()
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 15
        tf.addTarget(self, action: #selector(checkIsFormValid), for: .editingChanged)
        return tf
    }()
    
    let usernameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 15
        tf.addTarget(self, action: #selector(checkIsFormValid), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 15
        tf.addTarget(self, action: #selector(checkIsFormValid), for: .editingChanged)
        tf.textContentType = .init(rawValue: "")
        return tf
    }()
    
    
    let signUpButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        button.isEnabled = false
        return button
        
    }()
    
    
    @objc fileprivate func showloginController(){
        _ = self.navigationController?.popViewController(animated: true)
     }
    
    
    @objc func selectedImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[.originalImage] as? UIImage {
            self.addProfileImage.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let editedImage = info[.editedImage] as? UIImage {
            self.addProfileImage.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        self.addProfileImage.imageView?.contentMode = .scaleAspectFill
        self.addProfileImage.layer.cornerRadius = self.addProfileImage.frame.width / 2
        self.addProfileImage.layer.masksToBounds = true
        self.addProfileImage.layer.borderColor = UIColor.black.cgColor
        self.addProfileImage.layer.borderWidth = 2
        dismiss(animated: true)
    }
    
    @objc func checkIsFormValid(){
        let formValid = (emailTextField.text?.count ?? 0 > 0) &&  (usernameTextField.text?.count ?? 0 > 0) && (passwordTextField.text?.count ?? 0 >= 6)
        
        
        if formValid{
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        }else{
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
        
    }
    
    @objc func registerUser(){
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let username = usernameTextField.text, !username.isEmpty else { return }
        guard let password = passwordTextField.text, !password.isEmpty else { return }
        
        guard let image = addProfileImage.imageView?.image else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        
        
        
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (user:AuthDataResult?,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            else{
                let fileName = NSUUID().uuidString
                
                let storageRef = Storage.storage().reference().child("profile_images")
                    .child(fileName)
                
                storageRef.putData(imageData, metadata: nil) { metadata, error in
                    
                    if let error = error {
                        print("error to save image to firestore",error.localizedDescription)
                        return
                    }
                    
                    storageRef.downloadURL{ url, error in
                        if let error = error {
                            print("error to load image url from firestore",error.localizedDescription)
                            return
                        }
                        
                        guard let uid = user?.user.uid else { return }
                        guard let url = url?.absoluteString else { return }
                        
                        let userInformation = ["username":username,"profileImageURL":url,]
                        
                        let userInfoDictionary = [uid:userInformation]
                        Database.database().reference().child("users").updateChildValues(userInfoDictionary) { (error, ref) in
                            print("updated")
                            if let error = error {
                                print("error to save user data to DB",error.localizedDescription)
                                return
                            }
                            
                            guard let mainTabBarViewController = UIApplication.shared.connectedScenes
                                .filter({$0.activationState == .foregroundActive})
                                .compactMap({$0 as? UIWindowScene})
                                .first?.windows
                                    .filter({$0.isKeyWindow}).first?.rootViewController as? MainTabBarViewController else { return }
                            
                            mainTabBarViewController.setupViewControllers()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(addProfileImage)
        addProfileImage.anchor(top: view.topAnchor, leading: nil, trailing: nil, bottom: nil, paddingTop: 80, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 140, width: 140,centerX: true)
        addProfileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        setupRegistrationForm()
        
        
        view.addSubview(loginButtonWithText)
        
        loginButtonWithText.anchor(top: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeft: 12, paddingRight: 12, paddingBottom: 12, height: 50, width: 0)
    }
    
    fileprivate func setupRegistrationForm(){
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,usernameTextField,passwordTextField,signUpButton
        ])
        
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 12
        view.addSubview(stackView)
        
        
        stackView.anchor(top: addProfileImage.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil, paddingTop: 40, paddingLeft: 40, paddingRight: 40, paddingBottom: 0, height: 200, width: 0,centerX: true)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
    }
    
    
}

