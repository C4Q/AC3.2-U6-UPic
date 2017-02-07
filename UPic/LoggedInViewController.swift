//
//  LoggedInViewController.swift
//  UPic
//
//  Created by Marcel Chaucer on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoggedInViewController: UIViewController {
    var titleForCell = "YOUR PROFILE"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        configureConstraints()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = editButtonItem
        self.navigationItem.rightBarButtonItem?.title = "LOG OUT"
     }
    

    func configureConstraints() {
               // Buttons
        logoutButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        
    }

    
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = ColorPalette.primaryColor
        self.tabBarController?.title = titleForCell
        
        view.addSubview(logoutButton)
        
        
        logoutButton.addTarget(self, action: #selector(didTapLogout(sender:)), for: .touchUpInside)
        
    }
    
    func didTapLogout(sender: UIButton) {
      
            do {
                try FIRAuth.auth()?.signOut()
                _ = self.navigationController?.popViewController(animated: true)
            }
            catch {
                print(error)
            }
        }


    // MARK: - Lazy Instantiates
    // Logo Image View
    
    // Buttons
    internal lazy var logoutButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setTitle("LOG OUT", for: .normal)
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
