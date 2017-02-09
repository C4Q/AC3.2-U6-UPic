//
//  DisplayImageViewController.swift
//  UPic
//
//  Created by Madushani Lekam Wasam Liyanage on 2/8/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase
import FirebaseStorage

class DisplayImageViewController: UIViewController {

    var image: UIImage!
    var imageUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        configureConstraints()
        
        selectedImageView.contentMode = .scaleToFill
        selectedImageView.image = image
        selectedImageView.setNeedsLayout()
        
        print(imageUrl)
        
    }

    func setupViewHierarchy() {
        self.view.addSubview(imageContainerView)
        imageContainerView.addSubview(selectedImageView)
        imageContainerView.addSubview(votesContainerView)
        votesContainerView.addSubview(upvoteButton)
        votesContainerView.addSubview(downvoteButton)
        votesContainerView.addSubview(upvotesLabel)
        votesContainerView.addSubview(downvotesLabel)
        
        upvoteButton.addTarget(self, action: #selector(upvoteButtonTapped(sender:)), for: .touchUpInside)
        downvoteButton.addTarget(self, action: #selector(downvoteButtonTapped(sender:)), for: .touchUpInside)

                
    }
    
    internal func upvoteButtonTapped(sender: UIButton) {
        
        print("Upvote Tapped")
        editMetaData()
        
    }
    
    internal func downvoteButtonTapped(sender: UIButton) {
        
        print("Downvote Tapped")
        
    }
 
    func editMetaData() {
         let storageRef = FIRStorage.storage().reference().child("users")
        // Create reference to the file whose metadata we want to change
        let forestRef = storageRef.child("\(imageUrl)")
        
        // Create file metadata to update
        let newMetadata = FIRStorageMetadata()
        newMetadata.cacheControl = "public,max-age=300";
        newMetadata.contentType = "image/jpeg";
        
        // Update metadata properties
        forestRef.update(newMetadata) { metadata, error in
            if let error = error {
                // Uh-oh, an error occurred!
            print("Error ----- \(error.localizedDescription)")
                
            } else {
                // Updated metadata for 'images/forest.jpg' is returned
                let value = String(newMetadata.value(forKeyPath: "upvotes") as! Int + 1)
                newMetadata.setValue(value, forKey: "upvotes")
                
            }
        }
        
    }
    
    
    func configureConstraints() {
        self.imageContainerView.snp.makeConstraints { (view) in
            let targetHeight = self.navigationController?.navigationBar.frame.size.height
            view.top.equalToSuperview().offset(targetHeight!)
            view.leading.trailing.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.5)
        }
        self.selectedImageView.snp.makeConstraints { (view) in
            view.top.leading.trailing.equalTo(imageContainerView)
            view.bottom.equalTo(imageContainerView.snp.bottom).inset(20.0)
        }
        self.votesContainerView.snp.makeConstraints { (view) in
            view.leading.trailing.bottom.equalTo(imageContainerView)
            view.top.equalTo(imageContainerView.snp.bottom).inset(60.0)
        }
        self.upvotesLabel.snp.makeConstraints { (view) in
            view.bottom.equalTo(votesContainerView)
            view.height.equalTo(20.0)
            view.width.equalTo(votesContainerView.snp.width).multipliedBy(0.5)
            view.leading.equalTo(votesContainerView.snp.leading)
        }
        self.upvoteButton.snp.makeConstraints { (view) in
           view.top.equalTo(votesContainerView.snp.top).offset(10.0)
            view.centerX.equalTo(upvotesLabel.snp.centerX)
            view.height.equalTo(20)
            view.width.size.equalTo(20.0)
        }
        self.downvotesLabel.snp.makeConstraints { (view) in
            view.bottom.equalTo(votesContainerView)
            view.height.equalTo(20.0)
            view.width.equalTo(votesContainerView.snp.width).multipliedBy(0.5)
            view.trailing.equalTo(votesContainerView.snp.trailing)
        }
        self.downvoteButton.snp.makeConstraints { (view) in
            view.top.equalTo(votesContainerView.snp.top).offset(10.0)
            view.centerX.equalTo(downvotesLabel.snp.centerX)
            view.height.equalTo(20)
            view.width.size.equalTo(20.0)
        }
        
    }
    
    internal lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primaryColor
        return view
    }()
    
    internal lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = ColorPalette.primaryColor
        return imageView
    }()
    
    internal lazy var votesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primaryColor
        view.alpha = 0.6
        return view
    }()
    
    internal lazy var upvoteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "up_arrow"), for: .normal)
        button.tintColor = ColorPalette.accentColor
        return button
    }()
    
    internal lazy var downvoteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "down_arrow"), for: .normal)
        button.tintColor = ColorPalette.accentColor
        return button
    }()
    
    internal lazy var upvotesLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = ColorPalette.primaryColor
        label.textColor = ColorPalette.accentColor
        label.textAlignment = .center
        label.text = "0"
        return label
    }()
    
    internal lazy var downvotesLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = ColorPalette.primaryColor
        label.textColor = ColorPalette.accentColor
        label.textAlignment = .center
        label.text = "0"
        return label
    }()

}
