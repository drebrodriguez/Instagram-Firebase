//
//  Post.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 09/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import Foundation

struct Post {
    
    var id: String?
    var hasLiked = false
    
    let user: User
    let imageUrl: String
    let caption: String
    let creationDate: Date
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        
        let secFrom1970 = dictionary["creationDate"] as? Double ?? 0
        creationDate = Date(timeIntervalSince1970: secFrom1970)
    }
}
