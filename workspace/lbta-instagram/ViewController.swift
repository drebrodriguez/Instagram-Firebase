//
//  ViewController.swift
//  lbta-instagram
//
//  Created by Joash Tubaga on 26/04/2018.
//  Copyright © 2018 Joash Tubaga. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.tintColor = UIColor(r: 149, g: 204, b: 244)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    
        [addPhotoButton].forEach {view.addSubview($0)}
        
        NSLayoutConstraint.activate([
            addPhotoButton.heightAnchor.constraint(equalToConstant: 140),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 140),
            addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addPhotoButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40)
        ])
        
        setupInputFields()
        
  }
    
    fileprivate func setupInputFields() {
        let stackView: UIStackView = {
            let sv = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
            sv.distribution = .fillEqually
            sv.axis = .vertical
            sv.spacing = 10
            sv.translatesAutoresizingMaskIntoConstraints = false
            return sv
        }()
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 40),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            stackView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
    }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

