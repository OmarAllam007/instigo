//
//  HomeViewController.swift
//  instigo
//
//  Created by Omar Khaled on 19/04/2022.
//

import UIKit
import Firebase

private let reuseIdentifier = "postCell"

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomeViewPostCellDelegate{
    
    
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: SharePostViewController.updateHomeNotificationName, object: nil)
        
        collectionView.backgroundColor = .white

        self.collectionView!.register(HomeViewPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        collectionView.alwaysBounceVertical = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleTakePhoto))
    
        loadPosts()
    }
    
    @objc func handleTakePhoto(){
        let navicationController = UINavigationController(rootViewController: CameraViewController())
        navicationController.modalPresentationStyle = .fullScreen
        present(navicationController, animated: true, completion: nil)
    }
    
    
    @objc func handleRefresh(){
        self.posts = []
        loadPosts()
    }
    
    func loadPosts(){
        self.posts = []
        loadPostsImages()
        loadFollowingPosts()
    }


    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeViewPostCell
        
        cell.post = posts[indexPath.item]
        cell.postDelegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 40 + 8 + 8
        height += view.frame.width
        height += 50
        height += 80
        return CGSize(width: view.frame.width, height: height)
    }


   
    
    fileprivate func loadPostsImages(){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Database.loadUserWithUUID(uuid: userId) { user in
            self.loadUserPosts(user: user)
        }
        
        
    }
    
    fileprivate func loadUserPosts(user:User){
        let dbRef = Database.database().reference().child("posts").child(user.uuid)
        
        dbRef.observe(.value) { snapshot in
            guard let posts = snapshot.value as? [String:Any] else { return }
            
            posts.forEach { (key,value) in
                guard let dictionary = value as? [String:Any] else { return  }
            
                var post = Post(user:user,dictionary: dictionary)
                post.id = key
                
                guard let userId = Auth.auth().currentUser?.uid else { return }
                
                Database.database().reference().child("likes").child(key).child(userId).observeSingleEvent(of: .value) { snapshot in
                    if let value = snapshot.value as? Int , value == 1 {
                        post.hasLiked = true
                    }else{
                        post.hasLiked = false
                    }
                    self.posts.append(post)
                    self.posts.sort { p1, p2 in
                        return p1.createdDate.compare(p2.createdDate) == .orderedDescending
                    }
                    self.collectionView?.reloadData()
                }
                
                
            }
            
            
            
            
        }
    }
    
    fileprivate func loadFollowingPosts(){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("following").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let followingUsers = snapshot.value as? [String:Any] else {return}
            
            followingUsers.forEach({ (key: String, value: Any) in
                Database.loadUserWithUUID(uuid: key) { user in
                    self.loadUserPosts(user: user)
                }
            })
        }
        self.posts.sort { p1, p2 in
            return p1.createdDate.compare(p2.createdDate) == .orderedDescending
        }
        
        self.collectionView.refreshControl?.endRefreshing()
        
    }
    
    
    func didTapCommentButton(post: Post) {
        print(post.description)
        let layout = UICollectionViewFlowLayout()
        let controller = CommentsViewController(collectionViewLayout: layout)
        controller.post = post
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func didTapLikeButton(cell: HomeViewPostCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {return}

        var post = posts[indexPath.item]
        
        guard let postId = post.id else {return}
        
        guard let uuid = Auth.auth().currentUser?.uid else {return}
                
        
        let likeDictionary = [uuid: post.hasLiked ? 0 : 1]
        
        Database.database().reference().child("likes").child(postId).updateChildValues(likeDictionary) { error, ref in
            if let error = error {
                print("error in likes", error)
                return
            }
            
            post.hasLiked = !post.hasLiked
            self.posts[indexPath.item] = post
            self.collectionView.reloadItems(at: [indexPath])
        }
        
    }

}
