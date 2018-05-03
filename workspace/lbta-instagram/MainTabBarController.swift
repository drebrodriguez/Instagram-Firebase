//
//  MainTabBarController.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 01/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FIRAuth.auth()?.currentUser == nil {
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: LoginController())
                self.present(navController, animated: true, completion: nil)
                return
            }
        }
        
        setupViewControllers()
    }
    
    func setupViewControllers() {
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        let navController = UINavigationController(rootViewController: userProfileController)
        
        navController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        tabBar.tintColor = .black
        
        viewControllers = [navController, UIViewController()]
    }
}
