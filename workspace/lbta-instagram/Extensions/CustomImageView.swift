//
//  CustomImageView.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 09/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    var lastUrlUsed: String?
    
    func loadImageWithUrl(urlString: String) {
        
        lastUrlUsed = urlString
        
        guard  let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let error = err {
                print("Failed to fetch post image:", error)
                return
            }
            
            if url.absoluteString != self.lastUrlUsed { return }
            
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            
            DispatchQueue.main.async {
                self.image = photoImage
            }
            }.resume()
    }
}
