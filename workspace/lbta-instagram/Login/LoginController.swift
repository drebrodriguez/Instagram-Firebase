//
//  LoginController.swift
//  lbta-instagram
//
//  Created by Dreb Rodriguez on 03/05/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let logoContainerView: UIView = {
        let vw = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        vw.backgroundColor = UIColor.rgb(17, 154, 237)
        vw.addSubview(logoImageView)
        logoImageView.anchorXYCenter(centerX: vw.centerXAnchor, centerY: vw.centerYAnchor, width: 200, height: 50)
        return vw
    }()
    
    let topFillerLogoContainerView: UIView = {
        let vw = UIView()
        vw.backgroundColor = UIColor.rgb(17, 154, 237)
        return vw
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = false
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor.rgb(149, 204, 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor:UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor:UIColor.rgb(17, 154, 237)]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        btn.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return btn
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeKeyboardNotification()
        
        view.backgroundColor = .white
        
        navigationController?.isNavigationBarHidden = true
        
        [topFillerLogoContainerView, logoContainerView, signUpButton].forEach{view.addSubview($0)}
        
        topFillerLogoContainerView.anchor(top: view.topAnchor, bottom: logoContainerView.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0)
        
        logoContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 150)
        
        signUpButton.anchor(top: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 50)
        
        setupInputFields()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    fileprivate func observeKeyboardNotification() {
        if UIScreen.main.nativeBounds.height <= 1136 {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: .UIKeyboardWillHide, object: nil)
        }
    }
    
    @objc fileprivate func handleKeyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: -20, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    }
    
    @objc fileprivate func handleKeyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    }
    
    fileprivate func setupInputFields() {
        let stackview: UIStackView = {
            let sv = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
            sv.axis = .vertical
            sv.distribution = .fillEqually
            sv.spacing = 10
            return sv
        }()
        
        view.addSubview(stackview)
        stackview.anchor(top: logoContainerView.bottomAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingBottom: 0, paddingLeft: 40, paddingRight: 40, width: 0, height: 140)
    }
    
    @objc fileprivate func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        [emailTextField, passwordTextField].forEach({$0.resignFirstResponder()})
//        emailTextField.resignFirstResponder()
//        passwordTextField.resignFirstResponder()
        
        let activity = activityIndicator()
        activity.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
            if let err = err {
                print("Failed to sign in: ", err)
                activity.stopAnimating()
                self.showAlert(alertTitle: "Login Error", message: "Failed to log in. Try again.")
                return
            }
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            
            self.dismiss(animated: true, completion: activity.stopAnimating)
        })
    }
    
    @objc fileprivate func handleShowSignUp() {
        navigationController?.pushViewController(SignUpController(), animated: true)
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(17, 154, 237)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(149, 204, 244)
        }
    }
    
}
