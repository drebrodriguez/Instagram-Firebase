//
//  SearchUserCell.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 12/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit

class SearchUserCell: UICollectionViewCell {
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50 / 2
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Username"
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [photoImageView, usernameLabel].forEach({addSubview($0)})
        
        photoImageView.anchor(top: nil, bottom: nil, left: leftAnchor, right: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 50, height: 50)
        photoImageView.anchorXYCenter(centerX: nil, centerY: centerYAnchor)
        
        usernameLabel.anchor(top: topAnchor, bottom: bottomAnchor, left: photoImageView.rightAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 0, height: 0)
        
        usernameLabel.separatorLineBottom()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
