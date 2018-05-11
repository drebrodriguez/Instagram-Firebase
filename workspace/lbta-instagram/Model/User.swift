//
//  User.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 02/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit

struct User {
    let username: String
    let profileImageUrl: String
    
    init(dictionary: [String:Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
