//
//  CommentsController.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 17/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit

class CommentsController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .lightGray
        
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    fileprivate func setupNavBar() {
        navigationItem.title = "Comments"
        navigationController?.navigationBar.tintColor = .black
    }
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        let textField = UITextField()
        textField.placeholder = "Enter Comment"
        textField.font = UIFont.systemFont(ofSize: 14)
//        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
//        textField.layer.cornerRadius = 5
//        textField.layer.masksToBounds = true
        
        [submitButton, textField].forEach({containerView.addSubview($0)})
        submitButton.anchor(top: containerView.topAnchor, bottom: containerView.bottomAnchor, left: nil, right: containerView.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 8, width: 50, height: 0)
        textField.anchor(top: containerView.topAnchor, bottom: containerView.bottomAnchor, left: containerView.leftAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingBottom: 8, paddingLeft: 8, paddingRight: 8, width: 0, height: 0)
        
        return containerView
    }()
    
    @objc fileprivate func handleSubmit() {
        print("handle submit button")
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
