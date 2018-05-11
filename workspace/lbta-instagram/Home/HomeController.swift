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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavBarItems()
        
        fetchPost()
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
        
        cell.post = posts[indexPath.item]
        
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
