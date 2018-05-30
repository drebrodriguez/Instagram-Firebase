//
//  HomePostCell.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 10/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didLike(for cell: HomePostCell)
}

class HomePostCell: UICollectionViewCell {
    
    var delegate: HomePostCellDelegate?
    
    var post: Post? {
        didSet {
            setupPostImagesAndUsername()
            setupCaption()
            setupLike()
        }
    }
    
    let userProfileImage: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        iv.layer.cornerRadius = 40/2
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Username"
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        return lbl
    }()
    
    let optionButton: UIButton = {
        let btn = UIButton(type: UIButtonType.system)
        btn.setTitle("•••", for: UIControlState.normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return iv
    }()
    
    lazy var likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return btn
    }()
    
    lazy var commentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return btn
    }()
    
    let sendMessageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let bookmarkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let captionLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        [userProfileImage, usernameLabel, optionButton, photoImageView, captionLabel].forEach({addSubview($0)})
        
        userProfileImage.anchor(top: topAnchor, bottom: nil, left: leftAnchor, right: nil, paddingTop: 8, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 40, height: 40)
        
        usernameLabel.anchor(top: nil, bottom: nil, left: userProfileImage.rightAnchor, right: optionButton.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 0, height: 0)
        usernameLabel.anchorXYCenter(centerX: nil, centerY: userProfileImage.centerYAnchor)
        
        optionButton.anchor(top: topAnchor, bottom: nil, left: nil, right: rightAnchor, paddingTop: 12, paddingBottom: 0, paddingLeft: 0, paddingRight: 8, width: 50, height: 0)
        
        photoImageView.anchor(top: userProfileImage.bottomAnchor, bottom: nil, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        setupActionButtons()
        
        captionLabel.anchor(top: likeButton.bottomAnchor, bottom: bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 12, paddingRight: 12, width: 0, height: 0)
    }
    
    fileprivate func setupActionButtons() {
        let stackview: UIStackView = {
            let sv = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton])
            sv.distribution = .fillEqually
            return sv
        }()
        
        [stackview, bookmarkButton].forEach({addSubview($0)})
        stackview.anchor(top: photoImageView.bottomAnchor, bottom: nil, left: leftAnchor, right: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 4, paddingRight: 0, width: 120, height: 50)
        
        bookmarkButton.anchor(top: photoImageView.bottomAnchor, bottom: nil, left: nil, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 4, width: 50, height: 50)
    }
    
    fileprivate func setupPostImagesAndUsername() {
        guard let imageUrl = post?.imageUrl else { return }
        photoImageView.loadImageWithUrl(urlString: imageUrl)
        
        usernameLabel.text = post?.user.username
        
        guard let profileImageUrl = post?.user.profileImageUrl else { return }
        userProfileImage.loadImageWithUrl(urlString: profileImageUrl)
    }
    
    fileprivate func setupCaption() {
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " \(post.caption)", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 4)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.gray]))

        captionLabel.attributedText = attributedText
    }
    
    fileprivate func setupLike() {
        likeButton.setImage(post?.hasLiked == true ? #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    @objc fileprivate func handleComment() {
        guard let post = self.post else { return }
        delegate?.didTapComment(post: post)
    }
    
    @objc fileprivate func handleLike() {
        delegate?.didLike(for: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
