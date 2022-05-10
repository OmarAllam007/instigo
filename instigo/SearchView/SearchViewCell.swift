import UIKit

class SearchViewCell: UICollectionViewCell {
    
    var user:User? {
        didSet{
            self.usernameLabel.text = user?.username
            guard let imageUrl = self.user?.profileImageUrl else {return}
            self.userImageView.loadImagFromURL(imageUrl: imageUrl)
        }
    }
    
    let userImageView:CustomUIImageView = {
        let iv = CustomUIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        return iv
    }()
    
    let usernameLabel:UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        return lbl
    }()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        addSubview(userImageView)
        
        userImageView.anchor(top: nil, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: 0, paddingLeft: 8, paddingRight: 0, paddingBottom: 0, height: 50, width: 50)
        userImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        userImageView.layer.cornerRadius = 50 / 2
        
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: topAnchor, leading: userImageView.trailingAnchor, trailing: nil, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 8, paddingRight: 8, paddingBottom: 0, height: 0, width: 0)
        
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(separatorView)
        
        separatorView.anchor(top: nil, leading: usernameLabel.leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 0.5, width: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
