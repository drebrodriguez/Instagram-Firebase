//
//  Comment.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 20/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import Foundation

struct Comment {
    
    let user: User
    let uid: String
    let text: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.uid = dictionary["uid"] as? String ?? ""
        self.text = dictionary["text"] as? String ?? ""
    }
}
