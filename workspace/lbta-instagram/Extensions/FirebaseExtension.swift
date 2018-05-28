//
//  FirebaseExtension.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 11/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
        }) { (err) in
            print("Failed to fetch user:", err.localizedDescription)
        }
    }
    
    static func fetchPostWithUser(user: User, completion: @escaping (Post) -> ()) {
        let postRef = Database.database().reference().child("posts").child(user.uid)
        postRef.queryOrdered(byChild: "creationDate").observe(.childAdded, with: {(snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            var post = Post(user: user, dictionary: dictionary)
            post.id = snapshot.key
            
            completion(post)
        }) { (err) in
            print("Failed to fetch post:", err.localizedDescription)
        }
    }
    
    static func fetchUserLikeWithPost(currentUserUID: String, post: Post, completion: @escaping (Post) -> ()) {
        guard  let postId = post.id else { return }
        var tempPost = post
        Database.database().reference().child("likes").child(postId).child(currentUserUID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let value = snapshot.value as? Int, value == 1 {
                tempPost.hasLiked = true
            } else {
                tempPost.hasLiked = false
            }
            
            completion(tempPost)
        }, withCancel: { (err) in
            print("Failed to fetch liked photos:", err.localizedDescription)
        })
    }
}

extension Auth {
    
    static func fetchCurrentUserUID() -> String {
        let uid = Auth.auth().currentUser?.uid ?? ""
        return uid
    }
}
