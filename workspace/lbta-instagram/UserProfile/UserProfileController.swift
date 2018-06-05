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
    
    let cellId = "cellId", headerId = "headerId", footerId = "footerId"
    let homePostCellId = "homePostCellId", bookmarkCellId = "bookmarkCellId"
    
    var user: User?, posts = [Post](), userUID: String?
    var isGridView = true, isFinishedPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        fetchUserAndPost()
    }
    
    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .white
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(UserProfileFooter.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerId)
        
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
    }
    
    fileprivate func paginatePosts(user: User) {
        let queryLimit = 9
        let postsRef = Database.database().reference().child("posts").child(user.uid)
        var query = postsRef.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0 {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        query.queryLimited(toLast: UInt(queryLimit)).observe(.value, with: { (snapshot) in

            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < queryLimit {
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                guard let dictionary =  snapshot.value as? [String: Any] else { return }
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key
                
//                self.posts.insert(post, at: 0)
                self.posts.append(post)
                
            })
            
            self.collectionView?.reloadData()
        }) { (err) in
            print("Failed to paginate posts:", err.localizedDescription)
        }
    }
    
    fileprivate func fetchUserAndPost() {
        
        let uid = userUID ?? Auth.fetchCurrentUserUID()
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            if uid == Auth.fetchCurrentUserUID() {
                self.navigationItem.title = self.user?.username
                self.setupLogOutButton()
            } else {
                self.setupDirectMessageButton()
            }
            
            self.fetchUserStats(uid: uid)
            self.paginatePosts(user: user)
            
            self.collectionView?.reloadData()
        }
    }
    
    fileprivate func fetchUserStats(uid: String) {
        let dataRef = Database.database().reference()
        
        let postsRef = dataRef.child("posts").child(uid)
        postsRef.observe(.value, with: { (snapshot) in
            let postCount = Int(snapshot.childrenCount)
            self.user?.postCount = postCount
            
        }) { (err) in
            print("Failed to count posts:", err.localizedDescription)
        }
        
        let followingRef = dataRef.child("following")
        followingRef.observe(.value, with: { (snapshot) in
            var count = 0
            
            guard let followingDictionaries  = snapshot.value as? [String: Any] else { return }
            followingDictionaries.forEach({ (key, value) in
                if key == uid {
                    guard let following = value as? [String:Any] else { return }
                    self.user?.followingCount = following.count
                }
                
                if key != uid {
                    guard let followersDictionary = value as? [String: Any] else { return }
                    followersDictionary.forEach({ (key, _) in
                        if key == uid {
                            count += 1
                        }
                    })
                    self.user?.followersCount = count
                }
            })
            self.collectionView?.reloadData()
        }) { (err) in
            print("Failed to count followers and following:", err.localizedDescription)
        }
    }
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleLogOut))
    }
    
    fileprivate func setupDirectMessageButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSend))
    }
    
    @objc fileprivate func handleSend() {
        showAlert(alertTitle: "🚧 Direct Message 🚧", message: "Under development")
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
    var currentIndexPathItem = Int()
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        currentIndexPathItem = indexPath.item
        
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
    
    var footerView = UserProfileFooter()
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
            
            header.user = self.user
            header.delegate = self
            
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath) as! UserProfileFooter
            self.footerView = footer
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isFinishedPaging {
            return CGSize.zero
        } else {
            return CGSize(width: view.frame.width, height: 60)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            footerView.activityIndicator.startAnimating()
            
            if currentIndexPathItem == self.posts.count - 1 && !isFinishedPaging {
                if let user = self.user {
                    paginatePosts(user: user)
                }
            }
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            footerView.activityIndicator.stopAnimating()
        }
    }
    
//    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let contentOffset = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//        let diffHeight = contentHeight - contentOffset
//
//        let frameHeight = scrollView.frame.size.height
//        let pullHeight = fabs(diffHeight - frameHeight)
//
//        if pullHeight <= 0.2 {
//            if currentIndexPathItem == self.posts.count - 1 && !isFinishedPaging {
//                if let user = self.user {
//                    paginatePosts(user: user)
//                }
//            }
//        }
//
//    }
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
