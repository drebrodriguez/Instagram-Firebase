//
//  HomeController.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 10/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var posts = [Post]()
    
    let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return rc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: UserProfileHeader.updateFeedNotifName, object: nil)
        
        collectionView?.backgroundColor = .white
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavBarItems()
        
        fetchAllPosts()
        
        collectionView?.refreshControl = refreshControl
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
        let uid = FIRAuth.fetchCurrentUserUID()
        FIRDatabase.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userIDDictionary = snapshot.value as? [String: Any] else {
                self.collectionView?.reloadData()
                self.collectionView?.refreshControl?.endRefreshing()
                self.collectionView?.isUserInteractionEnabled = true
                
                return
            }
            
            userIDDictionary.forEach({ (key, value) in
                FIRDatabase.fetchUserWithUID(uid: key, completion: { (user) in
                    FIRDatabase.fetchPostWithUser(user: user, completion: { (post) in
                        self.posts.insert(post, at: 0)
                        
                        self.posts.sort(by: { (p1, p2) -> Bool in
                            return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                        })
                        
                        self.collectionView?.reloadData()
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
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        FIRDatabase.fetchUserWithUID(uid: uid) { (user) in
            FIRDatabase.fetchPostWithUser(user: user, completion: { (post) in
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
        print("camera selected")
    }
    
    @objc func handleSend() {
        print("send selected")
    }
    
}
