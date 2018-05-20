//
//  UserProfileHeader.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 02/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    var user: User? {
        didSet {
            setupProfileImageAndUsername()
            setupEditFollowButton()
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 80/2
        iv.layer.masksToBounds = true
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        return lbl
    }()
    
    let gridButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return btn
    }()
    
    let listButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        return btn
    }()
    
    let bookmarkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        return btn
    }()
    
    let postLabel: UILabel = {
        let lbl = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor:UIColor.lightGray]))
        lbl.attributedText = attributedText
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let followersLabel: UILabel = {
        let lbl = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor:UIColor.lightGray]))
        lbl.attributedText = attributedText
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let followingLabel: UILabel = {
        let lbl = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor:UIColor.lightGray]))
        lbl.attributedText = attributedText
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    lazy var editProfileButton: UIButton = {
        let btn = UIButton(type: UIButtonType.system)
//        btn.setTitle("Edit Profile", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 3
        btn.addTarget(self, action: #selector(handleEditFollow), for: .touchUpInside)
        return btn
    }()
    
    static let updateFeedNotifName = NSNotification.Name(rawValue: "UpdateFeed")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [profileImageView, usernameLabel, editProfileButton].forEach {addSubview($0)}
        
        profileImageView.anchor(top: topAnchor, bottom: nil, left: leftAnchor, right: nil, paddingTop: 12, paddingBottom: 0, paddingLeft: 12, paddingRight: 0, width: 80, height: 80)
        
        usernameLabel.anchor(top: profileImageView.bottomAnchor, bottom: nil, left: nil, right: nil, paddingTop: 16, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0)
        usernameLabel.anchorXYCenter(centerX: profileImageView.centerXAnchor, centerY: nil)
        
        setupUserStats()
        
        editProfileButton.anchor(top: postLabel.bottomAnchor, bottom: nil, left: postLabel.leftAnchor, right: followingLabel.rightAnchor, paddingTop: 4, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 34)
        
        setupBottomToolbar()
    }
    
    @objc fileprivate func handleEditFollow() {
        guard let currentLoggedInUser = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if editProfileButton.titleLabel?.text == "Unfollow" {
            Database.database().reference().child("following").child(currentLoggedInUser).child(userId).removeValue { (err, ref) in
                if let error = err {
                    print("Failed to unfollow user:", error)
                    return
                }
                
                self.setupFollowStyle()
            }
        } else {
            if currentLoggedInUser == userId {
                print("Edit profile view")
            } else {
                let ref = Database.database().reference().child("following").child(currentLoggedInUser)
                let values = [userId: 1]
                
                ref.updateChildValues(values) { (err, ref) in
                    if let error =  err {
                        print("Failed to follow user:", error)
                        return
                    }
                    
                    self.editProfileButton.setTitle("Unfollow", for: .normal)
                    self.editProfileButton.setTitleColor(.black, for: .normal)
                    self.editProfileButton.backgroundColor = .white
                    self.editProfileButton.layer.borderColor = UIColor.lightGray.cgColor
                }
            }
        }
        
        NotificationCenter.default.post(name: UserProfileHeader.updateFeedNotifName, object: nil)
    }
    
    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUser = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUser == userId {
            self.editProfileButton.setTitle("Edit Profile", for: .normal)
        } else {
            Database.database().reference().child("following").child(currentLoggedInUser).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.editProfileButton.setTitle("Unfollow", for: .normal)
                } else {
                    self.setupFollowStyle()
                }
            }) { (err) in
                print("Failed to check if following:", err)
            }
        }
    }
    
    fileprivate func setupFollowStyle() {
        self.editProfileButton.setTitle("Follow", for: .normal)
        self.editProfileButton.backgroundColor = UIColor.rgb(17, 154, 237)
        self.editProfileButton.setTitleColor(.white, for: .normal)
        self.editProfileButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    fileprivate func setupUserStats() {
        let stackview: UIStackView = {
            let sv = UIStackView(arrangedSubviews: [postLabel,followersLabel,followingLabel])
            sv.distribution = .fillEqually
            return sv
        }()
        
        addSubview(stackview)
        stackview.anchor(top: topAnchor, bottom: nil, left: profileImageView.rightAnchor, right: rightAnchor, paddingTop: 12, paddingBottom: 0, paddingLeft: 12, paddingRight: 12, width: 0, height: 50)
    }
    
    fileprivate func setupBottomToolbar() {
        let stackview: UIStackView = {
            let sv = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
            sv.distribution = .fillEqually
            return sv
        }()
                
        [stackview].forEach{addSubview($0)}

        stackview.anchor(top: nil, bottom: bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 50)
        
        stackview.separatorLines()
    }
    
    fileprivate func setupProfileImageAndUsername() {
        guard  let profileImageUrl = user?.profileImageUrl else { return }
        profileImageView.loadImageWithUrl(urlString: profileImageUrl)
        
        usernameLabel.text = user?.username
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
