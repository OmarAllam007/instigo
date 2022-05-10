//
//  SearchViewController.swift
//  instigo
//
//  Created by Omar Khaled on 23/04/2022.
//

import UIKit
import Firebase

private let cellId = "cellId"

class SearchViewController:
    UICollectionViewController,UICollectionViewDelegateFlowLayout, UISearchBarDelegate{
    
    lazy var searchBar:UISearchBar = {
        let sb = UISearchBar()
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        sb.delegate = self
        return sb
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "Enter username"
        searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        self.navigationItem.titleView = searchBar
        
        
        self.collectionView!.register(SearchViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        
        loadUsers()
    }

    var filteredUsers = [User]()
    var users = [User]()
    
    fileprivate func loadUsers(){
        let ref = Database.database().reference().child("users")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String:Any] else { return  }
            data.forEach { (key: String, value: Any) in
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                
                guard let userDictionary = value as? [String:Any] else {  return  }
                let user = User(uuid: key, dictionary: userDictionary)
                
                self.users.append(user)
            }
            
            self.users = self.users.sorted(by: { u1, u2 in
                return u1.username.compare(u2.username) == .orderedAscending
            })
            
            self.filteredUsers = self.users
            
            self.collectionView.reloadData()
            
            self.collectionView.keyboardDismissMode = .onDrag
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        let layout = UICollectionViewFlowLayout()
        let userController = UserProfileViewController(collectionViewLayout: layout)
        let user = self.filteredUsers[indexPath.item]
        
        userController.userId = user.uuid
        navigationController?.pushViewController(userController, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchViewCell
        cell.user = self.filteredUsers[indexPath.item]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }


    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.filteredUsers = self.users
        }else{
            self.filteredUsers = self.users.filter({ (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            })
        }
        
        
        
        self.collectionView.reloadData()
    }
}
