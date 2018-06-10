//
//  CommentInputAccessoryView.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 09/06/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}

class CommentInputAccessoryView: UIView {
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return btn
    }()
    
    let commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tv.isScrollEnabled = false
        tv.layer.cornerRadius = 10
        tv.clipsToBounds = true
        tv.contentInset = UIEdgeInsetsMake(0, 4, 0, 0)
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    fileprivate func setupView() {
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        
        [submitButton, commentTextView].forEach({addSubview($0)})
        submitButton.anchor(top: topAnchor, bottom: nil, left: nil, right: rightAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 0, paddingRight: 12, width: 50, height: 0)
        commentTextView.anchor(top: topAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, left: leftAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingBottom: 8, paddingLeft: 8, paddingRight: 8, width: 0, height: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
    
    @objc fileprivate func handleSubmit() {
        guard let comment = commentTextView.text else { return }
        delegate?.didSubmit(for: comment)
    }
    
    func clearCommentTextField() {
        commentTextView.text = nil
        commentTextView.showPlaceholderlabel()
        commentTextView.resignFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
