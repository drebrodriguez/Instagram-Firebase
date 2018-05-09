//
//  Post.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 09/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import Foundation

struct Post {
    let imageUrl: String
    
    init(dictionary: [String: Any]) {
        imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
}
