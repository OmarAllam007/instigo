//
//  UserProfileViewController.swift
//  instigo
//
//  Created by Omar Khaled on 16/04/2022.
//

import UIKit
import Firebase




class UserProfileViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,UserProfileViewDelegate {
   
    

    var user:User?
    let cellId = "cellId"
    var posts = [Post]()
    
    var userId:String?
    var isGridView = true
    
    let homePostCellId = "homePostCellId"
    
    var isFinishedPagination = false
    let paginationSize:UInt = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        
        collectionView.register(UserPhotoPostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(HomeViewPostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        
        if userId == nil{
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout))
        }
        
        getUserInformation()
        
    }
    
    
    fileprivate func loadPaginatedPosts(){
        let userId = self.userId ?? ( Auth.auth().currentUser?.uid ?? "")
        let dbRef = Database.database().reference().child("posts").child(userId)
        
            
        var query = dbRef.queryOrdered(byChild: "created_at") // order by date
        
        
        if posts.count > 0 {
            let value = posts.last?.createdDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: paginationSize).observeSingleEvent(of: .value) { snapshot in
            guard var allObjects   = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < self.paginationSize {
                self.isFinishedPagination = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            guard let user = self.user else {
                return
            }

            allObjects.forEach { snapshot in
                guard let dictionary = snapshot.value as? [String:Any] else { return }
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
                
            }
            
            self.collectionView.reloadData()
        }
        
        
    }
    
   
    
    fileprivate func loadOrderedPosts(){
        let userId = self.userId ?? ( Auth.auth().currentUser?.uid ?? "")
        let dbRef = Database.database().reference().child("posts").child(userId)
        
        dbRef.queryOrdered(byChild: "created_at").observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else { return  }
        
            guard let user = self.user else {
                return
            }

            
            let post = Post(user:user,dictionary: dictionary)
            self.posts.insert(post, at: 0)
            self.collectionView?.reloadData()
        } withCancel: { error in
            print("failed to load posts")
        }

    }
    
    
    @objc func handleLogout(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(
            UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                
                do {
                  try  Auth.auth().signOut()
                   
                    let loginController = LoginViewController()
                    let navController = UINavigationController(rootViewController: loginController)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)
                    
                    
                } catch let logoutError {
                    print("can't logout: " ,logoutError)
                }
                
            })
        )
        alertController.addAction(
            UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        )
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - collection view functions
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height / 5)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == self.posts.count - 1 && !self.isFinishedPagination {
            loadPaginatedPosts()
        }
        
        if isGridView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserPhotoPostCell
            cell.post = posts[indexPath.item]
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomeViewPostCell
            cell.post = posts[indexPath.item]
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let accurateWidth = view.frame.width - 2
            return CGSize(width: accurateWidth / 3  , height: accurateWidth / 3)
        }else{
            var height:CGFloat = 40 + 8 + 8
            height += view.frame.width
            height += 50
            height += 80
            
            return CGSize(width: view.frame.width  , height: height)
        }
        
        
    }
    // MARK: - View Functions
    fileprivate func getUserInformation(){
        
        let uid = userId ?? (Auth.auth().currentUser?.uid  ?? "")
        Database.loadUserWithUUID(uuid: uid) { user in
            self.user = user
            self.navigationItem.title = self.user?.username
            
            self.collectionView.reloadData()
            
            self.loadOrderedPosts()
        }
        
    }
    
    
    func convertToGridView() {
        self.isGridView = true
        self.collectionView.reloadData()
    }
    
    func convertTolListView() {
        self.isGridView = false
        self.collectionView.reloadData()
    }

}
