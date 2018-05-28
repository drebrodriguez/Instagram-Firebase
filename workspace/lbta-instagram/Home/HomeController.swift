//
//  HomeController.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 10/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    let cellId = "cellId"
    
    var posts = [Post]()
    
    let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return rc
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: UserProfileHeader.updateFeedNotifName, object: nil)
        
        collectionView?.backgroundColor = .white
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.refreshControl = refreshControl
        
        setupNavBarItems()
        
        fetchAllPosts()
        showAlert(alertTitle: "✨New Feature✨", message: "You can now like a photo by tapping the 🖤 icon.")
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    @objc fileprivate func handleRefresh() {
        collectionView?.isUserInteractionEnabled = false
        posts.removeAll()
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchPost()
        fetchFollowingPost()
    }
    
    fileprivate func fetchFollowingPost() {
        let uid = Auth.fetchCurrentUserUID()
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userIdDictionary = snapshot.value as? [String: Any] else {
                self.collectionView?.reloadData()
                self.collectionView?.refreshControl?.endRefreshing()
                self.collectionView?.isUserInteractionEnabled = true
                
                return
            }
            
            userIdDictionary.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    Database.fetchPostWithUser(user: user, completion: { (post) in
                        var tempPost = post
                        guard let postId = post.id else { return }
                        Database.database().reference().child("likes").child(postId).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

                            if let value = snapshot.value as? Int, value == 1 {
                                tempPost.hasLiked = true
                            } else {
                                tempPost.hasLiked = false
                            }

                            self.posts.append(tempPost)
                            self.posts.sort(by: { (p1, p2) -> Bool in
                                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                            })
                            self.collectionView?.reloadData()

                        }, withCancel: { (err) in
                            print("Failed to fetch liked photos:", err.localizedDescription)
                        })
                    })
                })
            })
            
            self.collectionView?.refreshControl?.endRefreshing()
            self.collectionView?.isUserInteractionEnabled = true
        }) { (err) in
            print("Failed to fetch following UIDs:", err)
        }
    }
    
    fileprivate func fetchPost() {
        let uid = Auth.fetchCurrentUserUID()
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            Database.fetchPostWithUser(user: user, completion: { (post) in
                self.posts.insert(post, at: 0)
                self.collectionView?.reloadData()
            })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        if indexPath.item < posts.count {
            cell.post = posts[indexPath.item]
        }
        
        cell.delegate = self
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 16
        height += view.frame.width
        height += 50
        height += 80
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    fileprivate func setupNavBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleCamera))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSend))
        
        let titleImage: UIImageView = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "logo2"))
            iv.contentMode = .scaleAspectFit
            return iv
        }()
        
        navigationItem.titleView = titleImage
    }
    
    @objc func handleCamera() {
        present(CameraController(), animated: true, completion: nil)
    }
    
    @objc func handleSend() {
        print("send selected")
        showAlert(alertTitle: "🚧Send🚧", message: "Under Construction")
    }
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = self.posts[indexPath.item]
        
        guard let postId = post.id else { return }
        let uid = Auth.fetchCurrentUserUID()
        let values = [uid: post.hasLiked == true ? 0 : 1]
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (err, ref) in
            if let error = err {
                print("Failed to like post:", error)
                return
            }
            
            post.hasLiked = !post.hasLiked
            self.posts[indexPath.item] = post
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
    
}
