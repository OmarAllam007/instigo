//
//  UserProfileHeaderCollectionViewCell.swift
//  instigo
//
//  Created by Omar Khaled on 16/04/2022.
//

import UIKit
import Firebase

protocol UserProfileViewDelegate {
    func convertToGridView()
    func convertTolListView()
}

class UserProfileHeader: UICollectionViewCell {
    
    var delegate:UserProfileViewDelegate?
    
    var isAuthProfile:Bool = true
    
    
    
    var user:User? {
        didSet{
            self.usernameLabal.text = user?.username
            loadProfileAvatar()
            checkIfAuthProfile()
            
        }
    }
    
    let gridButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(#imageLiteral(resourceName: "grid")), for: .normal)
        button.addTarget(self, action: #selector(convertToGridView), for: .touchUpInside)
        return button
    }()
    
    
    let listViewButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(#imageLiteral(resourceName: "list")), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.3)
        button.addTarget(self, action: #selector(convertToListView), for: .touchUpInside)
        return button
    }()
    
    
    let favouriteViewButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(#imageLiteral(resourceName: "ribbon")).withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.3)
        return button
    }()
    
    let userProfileImage:CustomUIImageView = {
        let iv = CustomUIImageView()
        iv.layer.cornerRadius = 30
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let usernameLabal:UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        return lbl
    }()
    
    lazy var postsLabal:UILabel = {
        return createAttributedLabelForStats(firstText: "11\n", secondString: "Posts")
    }()
    
    lazy var followersLabal:UILabel = {
        return createAttributedLabelForStats(firstText: "0\n", secondString: "Followers")
    }()
    
    lazy var followingLabal:UILabel = {
        return createAttributedLabelForStats(firstText: "0\n", secondString: "Following")
    }()
    
    let editProfileButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleFollowOrEdit), for: .touchUpInside)
        return button
    }()
    
    
    @objc func convertToGridView(){
        
        listViewButton.tintColor = UIColor(white: 0, alpha: 0.3)
        gridButton.tintColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        delegate?.convertToGridView()
        
    }
    
    @objc func convertToListView(){
        gridButton.tintColor = UIColor(white: 0, alpha: 0.3)
        listViewButton.tintColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        delegate?.convertTolListView()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUserProfileImageView()
        setupButtonStackView()
        
        addSubview(usernameLabal)
        usernameLabal.anchor(top: userProfileImage.bottomAnchor, leading: nil, trailing: nil, bottom: gridButton.topAnchor, paddingTop: 12, paddingLeft: 12, paddingRight: 0, paddingBottom: 12, height: 0, width: 0)
        usernameLabal.centerXAnchor.constraint(equalTo: userProfileImage.centerXAnchor).isActive = true
        
        addStatsLabels()
        
        addSubview(editProfileButton)
        editProfileButton.anchor(top: postsLabal.bottomAnchor, leading: postsLabal.leadingAnchor, trailing: followingLabal.trailingAnchor, bottom: nil, paddingTop: 12, paddingLeft: 12, paddingRight: 12, paddingBottom: 0, height: 30, width: 0)
        
        
    }
    
    func checkIfAuthProfile(){
        guard let currentAuthUserId = Auth.auth().currentUser?.uid else {return}
        guard let profileUserId = self.user?.uuid else {return}
        
        self.isAuthProfile = (currentAuthUserId == profileUserId)
        
        if !self.isAuthProfile {
            checkIfAlreadyFollowing()
        }
    }
    
    
    
    func checkIfAlreadyFollowing() {
        guard let currentAuthUserId = Auth.auth().currentUser?.uid else {return}
        guard let profileUserId = self.user?.uuid else {return}
        let ref = Database.database().reference().child("following").child(currentAuthUserId)
        
        ref.child(profileUserId).observeSingleEvent(of: .value) { snapshot in
            if let isFollowed = snapshot.value as? Int , isFollowed == 1 {
                self.changeFollowingButton(following: true)
            }
            else{
                self.changeFollowingButton(following: false)
            }
        }
        
    }
    
    func changeFollowingButton(following:Bool){
        if following {
            editProfileButton.setTitle("Unfollow", for: .normal)
            editProfileButton.backgroundColor = .white
            editProfileButton.setTitleColor(.black, for: .normal)
        }else{
            
            editProfileButton.setTitle("Follow", for: .normal)
            editProfileButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            editProfileButton.setTitleColor(.white, for: .normal)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - All Helper Methods
    
    fileprivate func createAttributedLabelForStats(firstText:String,secondString:String) -> UILabel{
        let lbl = UILabel()
        let attributedText = NSMutableAttributedString(string: firstText, attributes: [
            NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)
        ])
        attributedText.append(NSAttributedString(string: secondString, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor : UIColor.lightGray
        ]))
        
        lbl.attributedText = attributedText
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        
        return lbl
    }
    
    
    fileprivate func setupButtonStackView(){
        let topBorderView = UIView()
        topBorderView.backgroundColor = .lightGray
        
        
        let footerBorderView = UIView()
        footerBorderView.backgroundColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [
            gridButton,listViewButton,favouriteViewButton
        ])
        
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        stackView.anchor(top: nil, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 50, width: 0)
        
        addSubview(topBorderView)
        addSubview(footerBorderView)
        
        topBorderView.anchor(top: stackView.topAnchor, leading: stackView.leadingAnchor, trailing: stackView.trailingAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 0.5, width: 0)
        
        footerBorderView.anchor(top: nil, leading: stackView.leadingAnchor, trailing: stackView.trailingAnchor, bottom: stackView.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 0.5, width: 0)
    }
    
    
    fileprivate func addStatsLabels(){
        let stackView =  UIStackView(arrangedSubviews:[
            postsLabal,followersLabal,followingLabal
        ])
        
        addSubview(stackView)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        stackView.anchor(top: topAnchor, leading: usernameLabal.trailingAnchor, trailing: trailingAnchor, bottom: nil, paddingTop: 12, paddingLeft: 20, paddingRight: 0, paddingBottom: 0, height: 0, width: 0)
    }
    
    
    
    
    fileprivate func loadProfileAvatar(){
        guard let url = self.user?.profileImageUrl else { return }
        userProfileImage.loadImagFromURL(imageUrl: url)
    }
    
    fileprivate func setupUserProfileImageView() {
        addSubview(userProfileImage)
        
        userProfileImage.anchor(top: topAnchor, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: 0, paddingLeft: 12, paddingRight: 0, paddingBottom: 12, height: 80, width: 80)
        
        userProfileImage.layer.cornerRadius = 40
        userProfileImage.clipsToBounds = true
    }
    
    
    @objc func handleFollowOrEdit(){
        guard let currentAuthUserId = Auth.auth().currentUser?.uid else {return}
        guard let profileUserId = self.user?.uuid else {return}
        let values = [profileUserId:1]
        
        if editProfileButton.titleLabel?.text == "Follow" {
            Database.database().reference().child("following").child(currentAuthUserId).updateChildValues(values) { error, ref in
                if let err = error {
                    print("Failed to fetch user data",err.localizedDescription)
                    return
                }
                self.changeFollowingButton(following: true)
            }
        }else if editProfileButton.titleLabel?.text == "Unfollow" {
            Database.database().reference().child("following").child(currentAuthUserId).child(profileUserId).removeValue { error, ref in
                self.changeFollowingButton(following: false)
            }
        }
    }
}
