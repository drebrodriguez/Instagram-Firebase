//
//  UserProfileController.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 01/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId", headerId = "headerId"
    
    var user: User?, posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchUser()
        
        setupLogOutButton()
        
        fetchPost()
    }
    
    fileprivate func fetchPost() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let postRef = FIRDatabase.database().reference().child("posts").child(uid)
        
        postRef.queryOrdered(byChild: "creationDate").observe(.childAdded, with: {   (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let post = Post(dictionary: dictionary)
            self.posts.append(post)
            
            self.collectionView?.reloadData()
        }) { (err) in
            print("Failed to fetch posts:", err)
        }
    }
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc fileprivate func handleLogOut() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logout = UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            
            do {
                try FIRAuth.auth()?.signOut()
                
                let navController = UINavigationController(rootViewController: LoginController())
                self.present(navController, animated: true, completion: nil)
                
            } catch let err {
                print("Failed to sign out:", err)
            }
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        [logout,cancel].forEach{(alert.addAction($0))}
        
        present(alert, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
        
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (view.frame.width - 2) / 3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        
        header.user = user
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    fileprivate func fetchUser() {
        let activity = activityIndicator()
        activity.startAnimating()
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            
            self.user = User(dictionary: dictionary)
            
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
            activity.stopAnimating()
        }) { (err) in
            print("Failed to fetch user: ", err)
            activity.stopAnimating()
        }
    }
}
