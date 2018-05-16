//
//  PreviewPhotoContainerView.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 15/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return btn
    }()
    
    let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [previewImageView, cancelButton, saveButton].forEach({addSubview($0)})
        previewImageView.anchor(top: topAnchor, bottom: bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0)
        cancelButton.anchor(top: topAnchor, bottom: nil, left: nil, right: rightAnchor, paddingTop: 12, paddingBottom: 0, paddingLeft: 0, paddingRight: 12, width: 50, height: 50)
        saveButton.anchor(top: nil, bottom: bottomAnchor, left: leftAnchor, right: nil, paddingTop: 0, paddingBottom: 24, paddingLeft: 24, paddingRight: 0, width: 50, height: 50)
    }
    
    @objc fileprivate func handleCancel() {
        self.removeFromSuperview()
    }
    
    @objc fileprivate func handleSave() {
        guard let previewImage = previewImageView.image else { return }
        
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { (success, err) in
            if let error = err {
                print("Failed to save image to photo library:", error)
            }
            
            print("Successfully saved image to library.")
            DispatchQueue.main.async {
                let savedLabel: UILabel = {
                    let lbl = UILabel()
                    lbl.text = "Saved Successfully"
                    lbl.font = UIFont.boldSystemFont(ofSize: 18)
                    lbl.backgroundColor = UIColor(white: 0, alpha: 0.3)
                    lbl.textColor = .white
                    lbl.textAlignment = .center
                    lbl.numberOfLines = 0
                    lbl.layer.cornerRadius = 12
                    lbl.layer.masksToBounds = true
                    lbl.frame = CGRect(x: 0, y: 0, width: 160, height: 80)
                    lbl.center = self.center
                    return lbl
                }()
                
                self.addSubview(savedLabel)
                
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (completed) in
                    
                    UIView.animate(withDuration: 1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (_) in
                        savedLabel.removeFromSuperview()
                    })
                })
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
