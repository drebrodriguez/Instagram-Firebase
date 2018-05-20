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
            print("Failed to fetch user:", err)
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
            print("Failed to fetch post:", err)
        }
    }
}

extension Auth {
    
    static func fetchCurrentUserUID() -> String {
        let uid = Auth.auth().currentUser?.uid ?? ""
        return uid
    }
}
