//
//  PhotoCollectionViewCell.swift
//  instigo
//
//  Created by Omar Khaled on 18/04/2022.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    var imageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(imageView)
        imageView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 0, width: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
