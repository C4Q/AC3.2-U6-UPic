//
//  ProfileViewController.swift
//  UPic
//
//  Created by Eric Chang on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController, CellTitled {
    
    // MARK: - Properties
    var titleForCell = "LOGIN/REGISTER"

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewHierarchy()
        configureConstraints()
    }

    // MARK: - Setup View Hierarchy & Constraints
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = ColorPalette.primaryColor
        self.tabBarController?.title = titleForCell
        
        view.addSubview(UPicLogo)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(usernameContainerView)
        view.addSubview(passwordContainerView)
    }
    
    func configureConstraints() {
        // Image View
        UPicLogo.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 200.0, height: 200.0))
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50.0)
        }
        
        // Containers
        usernameContainerView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(44.0)
            make.top.equalTo(self.UPicLogo.snp.bottom).offset(24.0)
            make.trailing.equalTo(self.view.snp.leading)
        }
        
        passwordContainerView.snp.makeConstraints { (make) in
            make.width.equalTo(usernameContainerView.snp.width)
            make.height.equalTo(usernameContainerView.snp.height)
            make.top.equalTo(self.usernameContainerView.snp.bottom).offset(16.0)
            make.leading.equalTo(self.view.snp.trailing)
        }
        
        // Textfields
        usernameTextField.snp.makeConstraints { (make) in
            make.leading.top.equalTo(usernameContainerView).offset(4.0)
            make.trailing.bottom.equalTo(usernameContainerView).inset(4.0)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.leading.top.equalTo(passwordContainerView).offset(4.0)
            make.trailing.bottom.equalTo(passwordContainerView).inset(4.0)
        }

    }

    

    // MARK: - Lazy Instantiates
    // Logo Image View
    lazy var UPicLogo: UIImageView = {
        let logo = UIImageView()
        logo.image = #imageLiteral(resourceName: "logo")
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    
    // Textfields
    internal lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "USERNAME"
        textField.textColor = ColorPalette.accentColor
        textField.tintColor = ColorPalette.accentColor
        textField.borderStyle = .bezel
        return textField
    }()
    
    internal lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "PASSWORD"
        textField.textColor = ColorPalette.accentColor
        textField.tintColor = ColorPalette.accentColor
        textField.borderStyle = .bezel
        textField.isSecureTextEntry = true
        return textField
    }()
    
    // Containers
    internal lazy var usernameContainerView: UIView = {
        let view: UIView = UIView()
        return view
    }()
    
    internal lazy var passwordContainerView: UIView = {
        let view: UIView = UIView()
        return view
    }()
    
}
