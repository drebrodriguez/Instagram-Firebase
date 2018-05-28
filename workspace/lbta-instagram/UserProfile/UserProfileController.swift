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
    
    let cellId = "cellId", headerId = "headerId", homePostCellId = "homePostCellId", bookmarkCellId = "bookmarkCellId"
    
    var user: User?, posts = [Post](), userUID: String?, isGridView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        fetchUserAndPost()
        
        setupLogOutButton()
    }
    
    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .white
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
//        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: bookmarkCellId)
    }
    
    fileprivate func fetchUserAndPost() {
        let activity = activityIndicator()
        activity.startAnimating()
        
        let uid = userUID ?? Auth.fetchCurrentUserUID()
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            if uid == Auth.fetchCurrentUserUID() {
                self.navigationItem.title = self.user?.username
            }
            
            Database.fetchPostWithUser(user: user, completion: { (post) in
                self.posts.insert(post, at: 0)
                
                let postCount = self.posts.filter{return $0.id != nil}.count
                self.user?.postCount = postCount
                
//                Database.database().reference().child("following").child(uid).observe(.childAdded, with: { (snapshot) in
//                    let count = snapshot.childrenCount
//                    self.user?.followingCount = Int(count)
//                    self.collectionView?.reloadData()
//
//                }, withCancel: { (err) in
//                    print("Failed to count following:", err.localizedDescription)
//                })
                Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

                    let count = snapshot.childrenCount
                    self.user?.followingCount = Int(count)
                    self.collectionView?.reloadData()

                }, withCancel: { (err) in
                    print("Failed to count following:", err.localizedDescription)
                })
            })
            
            activity.stopAnimating()
            self.collectionView?.reloadData()
        }
    }
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc fileprivate func handleLogOut() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logout = UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            
            do {
                try Auth.auth().signOut()
                
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
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            
            cell.post = posts[indexPath.item]
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            
            cell.post = posts[indexPath.item]
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let size = (view.frame.width - 2) / 3
            return CGSize(width: size, height: size)
        } else {
            var height: CGFloat = 40 + 16
            height += view.frame.width
            height += 50
            height += 80
            
            return CGSize(width: view.frame.width, height: height)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        
        header.user = self.user
        header.delegate = self
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}

extension UserProfileController: UserProfileHeaderDelegate {
    func didChangeToGridView() {
        isGridView = true
        collectionView?.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    func didChangeToBookmark() {
        showAlert(alertTitle: "Bookmark", message: "Bookmark section under development.")
    }
}
