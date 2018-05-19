//
//  CommentsCell.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 20/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit

class CommentsCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            setupComment()
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50 / 2
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        [profileImageView, textView].forEach({addSubview($0)})
        profileImageView.anchor(top: topAnchor, bottom: bottomAnchor, left: leftAnchor, right: nil, paddingTop: 8, paddingBottom: 8, paddingLeft: 8, paddingRight: 0, width: 50, height: 50)
        textView.anchor(top: topAnchor, bottom: bottomAnchor, left: profileImageView.rightAnchor, right: rightAnchor, paddingTop: 4, paddingBottom: 4, paddingLeft: 8, paddingRight: 4, width: 0, height: 0)
        
        textView.separatorLineBottom()
    }
    
    fileprivate func setupComment() {
        guard let comment = self.comment else { return }
        
        profileImageView.loadImageWithUrl(urlString: comment.user.profileImageUrl)
        
        let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        
        textView.attributedText = attributedText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
