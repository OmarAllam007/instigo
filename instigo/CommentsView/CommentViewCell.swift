//
//  CommentViewCell.swift
//  instigo
//
//  Created by Omar Khaled on 28/04/2022.
//

import Foundation
import UIKit


class CommentViewCell:UICollectionViewCell{
    
    let commentText:UITextView = {
        let lbl = UITextView()
        lbl.font = .systemFont(ofSize: 14)
        lbl.isScrollEnabled = false
        lbl.isEditable = false
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    
    let commentUserImage:CustomUIImageView = {
        let iv = CustomUIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
//        iv.backgroundColor = .gray
        return iv
    }()
    
    var comment:Comment? {
        didSet{
            guard let comment = comment else {return}
            
            let attributedText = NSMutableAttributedString(string:  comment.user.username,attributes: [
                NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14),
            ])
            attributedText.append(NSAttributedString(string: " " + comment.text,attributes: [
                NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),
            ]))

            
            commentText.attributedText = attributedText
            commentUserImage.loadImagFromURL(imageUrl: comment.user.profileImageUrl)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .yellow
        
        addSubview(commentText)
        addSubview(commentUserImage)
        
        
        commentUserImage.anchor(top: topAnchor, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: 8, paddingLeft: 8, paddingRight: 0, paddingBottom: 0, height: 40, width: 40)
        
        commentUserImage.layer.cornerRadius = 40 / 2
        
        commentText.anchor(top: topAnchor, leading: commentUserImage.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 5, paddingRight: 5, paddingBottom: 0, height: 0, width: 0)
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
