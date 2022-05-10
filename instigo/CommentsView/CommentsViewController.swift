//
//  CommentsViewController.swift
//  instigo
//
//  Created by Omar Khaled on 28/04/2022.
//

import UIKit
import Firebase

private let reuseIdentifier = "cellId"

class CommentsViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    var post:Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.collectionView.backgroundColor = .white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.keyboardDismissMode = .interactive
        
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        self.collectionView!.register(CommentViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
       
        fetchComments()
    }
    
    var comments:[Comment] = [Comment]()
    
    func fetchComments(){
        
        guard let postId = self.post?.id else {return}
        let ref = Database.database().reference().child("comments").child(postId)
        
        comments.removeAll()
        
        ref.observe(.childAdded) { snapshot in
            guard let commentDictionary = snapshot.value as? [String:Any] else {return}
            
            
            guard let uuid = commentDictionary["user_id"] as? String else {return}
            
            
            Database.loadUserWithUUID(uuid: uuid) { user in
                let comment = Comment(user:user ,dictionary: commentDictionary)
                
                self.comments.append(comment)
                self.collectionView.reloadData()
            }
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    
    lazy var textInputContainer:UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    
        containerView.backgroundColor = .white

        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        sendButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        sendButton.anchor(top: containerView.topAnchor, leading: nil, trailing: containerView.trailingAnchor, bottom: containerView.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeft: 5, paddingRight: 5, paddingBottom: 0, height: 0, width: 50)
    
        
        containerView.addSubview(commentTextField)
        commentTextField.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: sendButton.leadingAnchor, bottom: containerView.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeft: 12, paddingRight: 12, paddingBottom: 0, height: 0, width: 0)

        let separatorView = UIView()
        containerView.addSubview(separatorView)
        
        separatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        separatorView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, height: 0.5, width: 0)
        
        return containerView
    }()
    
    
    @objc func sendComment()
    {
        guard let post = post else {return}
        guard let uuid = Auth.auth().currentUser?.uid else {return}
                

        if let postId = post.id {
            let commentDictionary = [
                "text":commentTextField.text ?? "",
                "created_date":Date().timeIntervalSince1970,
                "user_id":uuid
            ] as [String:Any]
            
            Database.database().reference().child("comments").child(postId)
                .childByAutoId()
                .updateChildValues(commentDictionary) { error, ref in
                if let error = error {
                    print("error when post the comment",error)
                    return
                }
                
                print("comment sent")
                self.fetchComments()
            }
        }

        
    }
    
    let commentTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Comment"
        return tf
    }()
    
    override var inputAccessoryView: UIView? {
        return textInputContainer
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
  
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return comments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        as! CommentViewCell
    
        cell.comment = comments[indexPath.item]
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let intialFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cell = CommentViewCell(frame: intialFrame)
        cell.comment = comments[indexPath.item]
        cell.layoutIfNeeded()

        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = cell.systemLayoutSizeFitting(targetSize)
        let height = 40 + 8 + 8 + estimatedSize.height
        
        return CGSize(width: view.frame.width, height: height)
    }

}
