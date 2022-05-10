//
//  MainTabBarViewController.swift
//  instigo
//
//  Created by Omar Khaled on 16/04/2022.
//

import UIKit
import Firebase

class MainTabBarViewController: UITabBarController,UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        self.delegate = self
        
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginViewController()
                let navigationController = UINavigationController(rootViewController: loginController)
                navigationController.modalPresentationStyle = .fullScreen
                navigationController.isNavigationBarHidden = true
                self.present(navigationController, animated: true)
            }
            
            return
        }
        
        
        setupViewControllers()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            let layout = UICollectionViewFlowLayout()
            let photoSelectorVC = SelectPhotoViewController(collectionViewLayout: layout)
            let navigationController = UINavigationController(rootViewController: photoSelectorVC)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
            
            return false
        }
        return true
    }
    
    
    
    func setupViewControllers(){
        let layout = UICollectionViewFlowLayout()
        let userViewController = UserProfileViewController(collectionViewLayout: layout)
        let homeViewController = HomeViewController(collectionViewLayout: layout)
        let searchControll = SearchViewController(collectionViewLayout: layout)
        
        let userNavController = templateForCreateTabController(selectedImage: #imageLiteral(resourceName: "profile_selected"),unselectedImage: #imageLiteral(resourceName: "profile_unselected"), controller: userViewController)
        let homeNavController = templateForCreateTabController(selectedImage: #imageLiteral(resourceName: "home_selected"),unselectedImage: #imageLiteral(resourceName: "home_unselected"), controller: homeViewController)
        let searchNavController = templateForCreateTabController(selectedImage: #imageLiteral(resourceName: "search_selected"),unselectedImage: #imageLiteral(resourceName: "search_unselected"), controller: searchControll)
        let createPostNavController = templateForCreateTabController(selectedImage: #imageLiteral(resourceName: "plus_unselected"),unselectedImage: #imageLiteral(resourceName: "plus_unselected"), controller: UIViewController())
        let likeNavController = templateForCreateTabController(selectedImage: #imageLiteral(resourceName: "like_selected"),unselectedImage: #imageLiteral(resourceName: "like_unselected"), controller: UIViewController())
        
        viewControllers = [homeNavController,searchNavController,createPostNavController,likeNavController,userNavController]
        
        guard let items = tabBar.items else { return }
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    
    fileprivate func templateForCreateTabController(selectedImage:UIImage, unselectedImage:UIImage, controller:UIViewController?) -> UINavigationController {
        let navController = UINavigationController(rootViewController: controller ?? UIViewController())
        tabBar.tintColor = .black
        tabBar.backgroundColor = .white
        navController.tabBarItem.selectedImage = selectedImage
        navController.tabBarItem.image = unselectedImage
        
        return navController
    }
}
