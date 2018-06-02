//
//  Extensions.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 27/04/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    static func rgbWithAlpha(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, right: NSLayoutXAxisAnchor?,paddingTop: CGFloat, paddingBottom: CGFloat, paddingLeft: CGFloat, paddingRight: CGFloat, width: CGFloat = 0, height: CGFloat = 0) {
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: paddingTop))
        }
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom))
        }
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: paddingLeft))
        }
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -paddingRight))
        }
        if width != 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: width))
        }
        if height != 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: height))
        }
        
        anchors.forEach({$0.isActive = true})
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func anchorXYCenter(centerX: NSLayoutXAxisAnchor?, centerY: NSLayoutYAxisAnchor?, width: CGFloat = 0, height: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func separatorLines(bgColor: UIColor = .lightGray, height: CGFloat = 0.5) {
        [self.topAnchor, self.bottomAnchor].forEach{(topAnchor) in
            let v = UIView()
            v.backgroundColor = bgColor
            self.addSubview(v)
            v.anchor(top: topAnchor, bottom: nil, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: height)
        }
    }
    
    func separatorLineBottom(bgColor: UIColor = .lightGray, height: CGFloat = 0.5) {
        let v = UIView()
        v.backgroundColor = bgColor
        self.addSubview(v)
        v.anchor(top: nil, bottom: bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: height)
    }
}

extension UIViewController {
    func activityIndicator() -> UIActivityIndicatorView{
        let activity: UIActivityIndicatorView = {
            let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            aiv.backgroundColor = UIColor(white: 0, alpha: 0.4)
            aiv.layer.cornerRadius = 20
            aiv.layer.masksToBounds = true
            aiv.hidesWhenStopped = true
            return aiv
        }()
        
        view.addSubview(activity)
        view.bringSubview(toFront: activity)
        
        activity.anchorXYCenter(centerX: view.centerXAnchor, centerY: view.centerYAnchor, width: 80, height: 80)
        
        return activity
    }
    
    func showAlert(alertTitle: String, message: String) {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
