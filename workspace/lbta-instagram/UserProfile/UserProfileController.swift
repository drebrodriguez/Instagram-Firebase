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
    
    var user: User?, posts = [Post](), userUID: String?, isGridView = true, isFinishedPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        fetchUserAndPost()
//        paginatePosts()
    }
    
    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .white
//        collectionView?.alwaysBounceVertical = true
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
    }
    
    fileprivate func paginatePosts(user: User) {
//        guard let uid = self.user?.uid else { return }
        let queryLimit = 9
        let postsRef = Database.database().reference().child("posts").child(user.uid)
        var query = postsRef.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0 {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: UInt(queryLimit)).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < 4 {
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
                
                let postCount = self.posts.count
                self.user?.postCount = postCount
            })
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to paginate posts:", err.localizedDescription)
        }
    }
    
    fileprivate func fetchUserAndPost() {
        let activity = activityIndicator()
        activity.startAnimating()
        
        let uid = userUID ?? Auth.fetchCurrentUserUID()
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            if uid == Auth.fetchCurrentUserUID() {
                self.navigationItem.title = self.user?.username
                self.setupLogOutButton()
            } else {
                self.setupDirectMessageButton()
            }
            
            self.paginatePosts(user: user)
            
//            Database.fetchPostWithUser(user: user, completion: { (post) in
//                self.posts.insert(post, at: 0)
//
//                let postCount = self.posts.count
//                self.user?.postCount = postCount
//
//                self.fetchFollowersAndFollowingWith(uid: uid)
//
//            })
            
            
            
            self.fetchFollowersAndFollowingWith(uid: uid)
            
            activity.stopAnimating()
            self.collectionView?.reloadData()
        }
    }
    
    fileprivate func fetchFollowersAndFollowingWith(uid: String) {
        
        let followingRef = Database.database().reference().child("following")
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == self.posts.count - 1 && !isFinishedPaging    {
            if let user = self.user {
                paginatePosts(user: user)
            }
        }
        
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
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.isAtBottom {
//            print("Reached bottom")
//        }
//    }
}

extension UIScrollView {
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
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
