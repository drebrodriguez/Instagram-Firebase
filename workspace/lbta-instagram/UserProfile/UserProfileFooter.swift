//
//  UserProfileFooter.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 04/06/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit

class UserProfileFooter: UICollectionViewCell {
    
    let loadMoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Load More", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        aiv.color = UIColor.rgb(17, 154, 237)
        return aiv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    fileprivate func setupView() {
        addSubview(activityIndicator)
        activityIndicator.anchorXYCenter(centerX: centerXAnchor, centerY: centerYAnchor, width: 50, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
