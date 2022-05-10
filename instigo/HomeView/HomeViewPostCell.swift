//
//  HomeViewPostCell.swift
//  instigo
//
//  Created by Omar Khaled on 19/04/2022.
//

import UIKit

protocol HomeViewPostCellDelegate {
    func didTapCommentButton(post:Post)
    func didTapLikeButton(cell:HomeViewPostCell)
}
class HomeViewPostCell:UICollectionViewCell{
    
    var postDelegate:HomeViewPostCellDelegate?
    
    var post:Post? {
        didSet{
            guard let post = post else {
                return
            }

             let imageUrl = post.imageUrl
            postImageView.loadImagFromURL(imageUrl: imageUrl)
            
            likeButton.setImage(post.hasLiked ? #imageLiteral(resourceName: "like_selected") : #imageLiteral(resourceName: "like_unselected"), for: .normal)
            
            let user = post.user 
            userNameLbl.text = user.username
            userImageView.loadImagFromURL(imageUrl: user.profileImageUrl)
            
            setupPostDescription()
        }
    }
    
    fileprivate func setupPostDescription(){
        guard let post = post else {
            return
        }
        
        let attributedText = NSMutableAttributedString(string: "\(post.user.username)",attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString.init(string: " \(post.description)",attributes: [
        
            NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),
    
        ]))

        attributedText.append(NSAttributedString.init(string: "\n\n",attributes: [
            NSAttributedString.Key.font:UIFont.systemFont(ofSize: 4),
            NSAttributedString.Key.foregroundColor : UIColor.darkGray
    
        ]))
        
        let date = post.createdDate.timeAgoDisplay()
        
        attributedText.append(NSAttributedString.init(string: "\(date)",attributes: [
            NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor : UIColor.darkGray
    
        ]))
        
        captionLbl.attributedText = attributedText
    }
    
    let userImageView:CustomUIImageView = {
        let iv = CustomUIImageView()
        iv.contentMode  = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let postImageView:CustomUIImageView = {
        let pov = CustomUIImageView()
        pov.contentMode = .scaleAspectFill
        pov.clipsToBounds = true
        return pov
    }()
    
    let userNameLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "Username"
        return lbl
    }()
    
    let optionsButton:UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .black
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()
    
    let likeButton:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(likePost), for: .touchUpInside)
        return btn
    }()
    
    
    let commentButton:UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(showPostComments), for: .touchUpInside)
        return btn
    }()
    
    let sendMessageButton:UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    
    
    let bookMarkButton:UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let captionLbl: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        return lbl
    }()
    
    
    
    @objc func showPostComments(){
        guard let post = post else {
            return
        }

        postDelegate?.didTapCommentButton(post: post)
    }
    
    
    @objc func likePost(){
        postDelegate?.didTapLikeButton(cell: self)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(postImageView)
        addSubview(userImageView)
        addSubview(userNameLbl)
        addSubview(optionsButton)

        userImageView.anchor(top: topAnchor, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: 8, paddingLeft: 8, paddingRight: 0, paddingBottom: 0, height: 40, width: 40)
        
        postImageView.anchor(top: userImageView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: nil, paddingTop: 8, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 0, width: 0)

//        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
//
        userImageView.layer.cornerRadius = 40 / 2
//
//
        userNameLbl.anchor(top: topAnchor, leading: userImageView.trailingAnchor, trailing: nil, bottom: postImageView.topAnchor, paddingTop: 0, paddingLeft: 8, paddingRight: 8, paddingBottom: 0, height: 0, width: 0)
//
        optionsButton.anchor(top: topAnchor, leading: nil, trailing: trailingAnchor, bottom: postImageView.topAnchor, paddingTop: 0, paddingLeft: 8, paddingRight: 8, paddingBottom: 0, height: 0, width: 0)


        setupActionsButton()

        addSubview(captionLbl)
        captionLbl.anchor(top: likeButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 8, paddingRight: 8, paddingBottom: 0, height: 0, width: 0, centerX: false)
    }
    
    private func setupActionsButton(){
        let stackView = UIStackView(arrangedSubviews: [
            likeButton,commentButton,sendMessageButton
        ])
        
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        addSubview(stackView)
        addSubview(bookMarkButton)
        
        bookMarkButton.anchor(top: postImageView.bottomAnchor, leading: nil, trailing: trailingAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 50, width: 40)
        
        stackView.anchor(top: postImageView.bottomAnchor, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: 0, paddingLeft: 8, paddingRight: 8, paddingBottom: 0, height: 50, width: frame.width / 3)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
