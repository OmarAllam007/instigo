//
//  LoginViewController.swift
//  instigo
//
//  Created by Omar Khaled on 16/04/2022.
//

import UIKit
import CoreData
import Firebase

class LoginViewController: UIViewController {

    let signupButtonWithText:UIButton = {
        let button = UIButton(type: .system)
        let attributedText = NSMutableAttributedString(string: "Don't have an account, ", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor:UIColor.lightGray,
        ])
        
        attributedText.append(NSAttributedString(string: "Sign Up", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor:UIColor.rgb(red: 0, green: 120, blue: 175),
        ]))
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(showSignUp), for: .touchUpInside)
        return button
    }()
    
    let topViewContainer:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        
        
        let logoImage = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        logoImage.contentMode = .scaleAspectFill
        v.addSubview(logoImage)
        
        logoImage.anchor(top: nil, leading: nil, trailing: nil, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 50, width: v.frame.width)
        
        NSLayoutConstraint.activate([
            logoImage.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        ])
        
        
        return v
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
    
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 15
        tf.textContentType = .init(rawValue: "")
        tf.addTarget(self, action: #selector(checkIsFormValid), for: .editingChanged)
        return tf
    }()
    
    
    let loginButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        button.isEnabled = false
        return button
        
    }()
    
    
    @objc func loginUser(){
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let err = error {
                print("Error when trying to login: ",err)
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
    
    let messageLbl:UILabel = {
        let lbl = UILabel()
        lbl.text = "Don't have an account, "
        return lbl
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
   @objc fileprivate func showSignUp(){
        let signUpController = SignUpController()
        self.navigationController?.pushViewController(signUpController, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    
        
        view.addSubview(topViewContainer)
        view.addSubview(signupButtonWithText)
        
        signupButtonWithText.anchor(top: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeft: 12, paddingRight: 12, paddingBottom: 12, height: 50, width: 0)
        
        topViewContainer.anchor(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 150, width: 0)
        
        setupLoginForm()
        
    }
    
    
    @objc func checkIsFormValid(){
        let formValid = (emailTextField.text?.count ?? 0 > 0) && (passwordTextField.text?.count ?? 0 >= 6)
        
        
        if formValid{
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        }else{
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
        
    }
    
    
    fileprivate func setupLoginForm(){
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,passwordTextField,loginButton
        ])
        
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 12
        view.addSubview(stackView)
        
        
        stackView.anchor(top: topViewContainer.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil, paddingTop: 40, paddingLeft: 40, paddingRight: 40, paddingBottom: 0, height: view.frame.height / 5, width: 0,centerX: true)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
    }


}
