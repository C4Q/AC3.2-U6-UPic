//
//  ProfileViewController.swift
//  UPic
//
//  Created by Eric Chang on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController, CellTitled, UITextFieldDelegate {
    
    // MARK: - Properties
    var propertyAnimator: UIViewPropertyAnimator?
    var titleForCell = "LOGIN/REGISTER"
    var activeField: UITextField?
    var ref: FIRDatabaseReference!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewHierarchy()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.propertyAnimator = UIViewPropertyAnimator(duration: 2.0, dampingRatio: 0.75, animations: nil)
        
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.animateLogo()
        
        self.addSlidingAnimationToUsername()
        self.addSlidingAnimationToPassword()
        self.startSlidingAnimations()
    }

    // MARK: - Setup View Hierarchy & Constraints
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = ColorPalette.primaryColor
        self.tabBarController?.title = titleForCell
        
        view.addSubview(UPicLogo)
        view.addSubview(usernameContainerView)
        view.addSubview(passwordContainerView)
        view.addSubview(loginButton)
        view.addSubview(registerButton)

        usernameContainerView.addSubview(usernameTextField)
        passwordContainerView.addSubview(passwordTextField)
        
        loginButton.addTarget(self, action: #selector(didTapLogin(sender:)), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister(sender:)), for: .touchUpInside)

    }
    
    func configureConstraints() {
        // Image View
        UPicLogo.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 200.0, height: 200.0))
            make.centerX.bottom.equalToSuperview()
        }
        
        // Containers
        usernameContainerView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(44.0)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.snp.top)
        }
        
        passwordContainerView.snp.makeConstraints { (make) in
            make.width.equalTo(usernameContainerView.snp.width)
            make.height.equalTo(usernameContainerView.snp.height)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.snp.top)
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
        
        // Buttons
        loginButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(registerButton.snp.top).inset(8.0)
        }
        
        registerButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(16.0)
        }
        
    }
    
    // MARK: Property Animations
    internal func addSlidingAnimationToUsername() {
        
        propertyAnimator?.addAnimations ({
            self.usernameContainerView.snp.remakeConstraints { (make) in
                make.width.equalToSuperview().multipliedBy(0.8)
                make.height.equalTo(44.0)
                make.centerX.equalToSuperview()
                make.top.equalTo(self.UPicLogo.snp.bottom).offset(24.0)
            }
            
            self.view.layoutIfNeeded()
            }, delayFactor: 0.0)
    }
    
    internal func addSlidingAnimationToPassword() {
        
        propertyAnimator?.addAnimations ({
            self.passwordContainerView.snp.remakeConstraints { (make) in
                make.width.equalTo(self.usernameContainerView.snp.width)
                make.height.equalTo(self.usernameContainerView.snp.height)
                make.top.equalTo(self.usernameContainerView.snp.bottom).offset(16.0)
                make.trailing.equalTo(self.usernameContainerView.snp.trailing)
            }
            
            self.view.layoutIfNeeded()
            }, delayFactor: 0.1)
    }
    
    internal func animateLogo() {
        
        UPicLogo.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        propertyAnimator?.addAnimations ({
            self.UPicLogo.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
            self.UPicLogo.snp.remakeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 200.0, height: 200.0))
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(75.0)
            })
            }, delayFactor: 1.0)
        
        
        UIView.animate(withDuration: 1.5, animations: {
            self.UPicLogo.alpha = 0.8
            }, completion: nil)
        
        self.view.layoutIfNeeded()
    }
    
    internal func startSlidingAnimations() {
        propertyAnimator?.startAnimation()
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        activeField = nil
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.passwordTextField {
            self.view.endEditing(true)
            return false
        }
        return true
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    // MARK: - Actions
    func didTapLogin(sender: UIButton) {
        self.ref = FIRDatabase.database().reference()
//        self.ref.child("users").child(usernameTextField.text!).observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            let anEmail = value?["email"] as? String
        
            if let password = self.passwordTextField.text, let email = self.usernameTextField.text {
                FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                    if user != nil {
                        self.navigationController?.pushViewController(LoggedInViewController(), animated: true)
                    }
                    else {
                        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                })
            }
        //})
    }
    
    func didTapRegister(sender: UIButton) {
        self.present(RegisterViewController(), animated: true, completion: nil)
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
    
    // Buttons
    internal lazy var loginButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setTitle("LOG IN", for: .normal)
        button.backgroundColor = ColorPalette.primaryColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightMedium)
        button.setTitleColor(ColorPalette.textIconColor, for: .normal)
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = ColorPalette.textIconColor.cgColor
        button.layer.borderWidth = 2.0
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 24.0, 8.0, 24.0)
        return button
    }()
    
    internal lazy var registerButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = ColorPalette.primaryColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightMedium)
        button.setTitleColor(ColorPalette.textIconColor, for: .normal)
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = ColorPalette.textIconColor.cgColor
        button.layer.borderWidth = 2.0
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 24.0, 8.0, 24.0)
        return button
    }()
    
}
