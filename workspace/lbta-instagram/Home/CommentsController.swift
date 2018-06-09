//
//  CommentsController.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 17/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var post: Post?, comments = [Comment]()
    
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        
        commentInputAccessoryView.separatorLines()
        commentInputAccessoryView.delegate = self
        
        return commentInputAccessoryView
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        
        setupCollectionView()
        setupNavBar()
        fetchComments()
    }
    
    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .white
        collectionView?.register(CommentsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
    }
    
    @objc func handleKeyboardDidShow() {
        if comments.count > 0 {
            collectionView?.scrollToItem(at: IndexPath(item: comments.count - 1, section: 0), at: UICollectionViewScrollPosition.bottom, animated: true)
        }
    }
    
    fileprivate func fetchComments() {
        guard let postId = post?.id else { return }
        
        let commentsRef = Database.database().reference().child("comments").child(postId)
        commentsRef.observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: uid, completion: { (user) in
                let comment = Comment(user: user,dictionary: dictionary)
                
                self.comments.append(comment)
                self.collectionView?.reloadData()
            })
        }) { (err) in
            print("Failed to observe comments:", err)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentsCell
        
        cell.comment = comments[indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 56)
        let dummyCell = CommentsCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(56, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    fileprivate func setupNavBar() {
        navigationItem.title = "Comments"
        navigationController?.navigationBar.tintColor = .black
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension CommentsController: CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String) {
        let uid = Auth.fetchCurrentUserUID()
        let postId = self.post?.id ?? ""
        let values = ["uid": uid, "text": comment, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            if let error = err {
                print("Failed to save comment to DB:", error)
                return
            }
            
//            print("Successfully saved comment to DB.")
            self.containerView.clearCommentTextField()
        }
    }
    
}
