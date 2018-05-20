//
//  SharePhotoController.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 05/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }
    
    let containerView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white
        return vw
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(240, 240, 240)
        
        setupNavBar()
        setupImageAndTextViews()
    }
    
    fileprivate func setupImageAndTextViews() {
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 100)
        
        [imageView, textView].forEach{containerView.addSubview($0)}
        imageView.anchor(top: containerView.topAnchor, bottom: containerView.bottomAnchor, left: containerView.leftAnchor, right: nil, paddingTop: 8, paddingBottom: 8, paddingLeft: 8, paddingRight: 0, width: 84, height: 0)
        textView.anchor(top: containerView.topAnchor, bottom: containerView.bottomAnchor, left: imageView.rightAnchor, right: containerView.rightAnchor, paddingTop: 8, paddingBottom: 8, paddingLeft: 8, paddingRight: 8, width: 0, height: 0)
    }
    
    fileprivate func setupNavBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleShare))
    }
    
    @objc fileprivate func handleShare() {
        guard let image = selectedImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        let activity = activityIndicator()
        activity.startAnimating()
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("posts").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
            if let error = err {
                print("Failed to upload post image:", error)
                activity.stopAnimating()
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            //Success upload
//            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            metadata?.storageReference?.downloadURL(completion: { (url, err) in
                if let error = err {
                    print("Failed to fetch imageUrl:", error)
                }
                guard let imageUrl = url?.absoluteString else { return }
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
            })
//            self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
        }
        
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let postImage = selectedImage else { return }
        guard let caption = textView.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return}
        
        let userPostRef = Database.database().reference().child("posts").child(uid).childByAutoId()
        let values = ["imageUrl":imageUrl, "caption":caption, "imageWidth":postImage.size.width, "imageHeight":postImage.size.height, "creationDate":Date().timeIntervalSince1970] as [String : Any]
        
        userPostRef.updateChildValues(values) { (err, ref) in
            if let error = err {
                print("Failed to save to DB:", error)
                return
            }
            //Success save
            self.dismiss(animated: true, completion: self.activityIndicator().stopAnimating)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
