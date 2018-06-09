//
//  CommentInputTextView.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 09/06/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {
    
    let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Comment here..."
        lbl.textColor = .lightGray
        return lbl
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        setupView()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func setupView() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: .UITextViewTextDidChange, object: nil)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, bottom: bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingBottom: 0, paddingLeft: 6, paddingRight: 0)
    }
    
    @objc fileprivate func handleTextChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    func showPlaceholderlabel() {
        placeholderLabel.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
