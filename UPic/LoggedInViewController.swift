//
//  LoggedInViewController.swift
//  UPic
//
//  Created by Marcel Chaucer on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class LoggedInViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var titleForCell = "YOUR PROFILE"
    let reuseIdentifier = "imagesCellIdentifier"
    let bottomCollectionViewItemSize = CGSize(width: 125, height: 175)
    let bottomCollectionViewNibName = "ImagesCollectionViewCell"
    var imagesCollectionView: UICollectionView!
    
    
    var userReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("uploads")
    
    
    var picArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        configureConstraints()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = editButtonItem
        self.navigationItem.rightBarButtonItem?.title = "LOG OUT"
        dump(self.userReference)
        dump(FIRStorage.storage().reference())
        downloadImages()
        //imagesCollectionView.clearsSelectionOnViewWillAppear = false
    }
    
    
    func configureConstraints() {
        // Buttons
        logoutButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        imagesCollectionView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.height.equalTo(175.0)
        }
        
    }
    
    
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = ColorPalette.primaryColor
        self.tabBarController?.title = titleForCell
        createBottomCollectionView()
        view.addSubview(logoutButton)
        view.addSubview(imagesCollectionView)
        
        
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
    
    func createBottomCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        // layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = bottomCollectionViewItemSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        imagesCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let nib = UINib(nibName: bottomCollectionViewNibName, bundle:nil)
        imagesCollectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        imagesCollectionView.backgroundColor = .white
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.picArray.count)
        return self.picArray.count
    }
    
    func downloadImages() {
        self.userReference.observe(.childAdded, with: { (snapshot) in
            // Get download URL from snapshot
            let downloadURL = snapshot.value as! String
            dump("This is download URL \(downloadURL)")
            // Create a storage reference from the URL
            let storageRef = FIRStorage.storage().reference(forURL: downloadURL)
            // Download the data, assuming a max size of 1MB (you can change this as necessary)
            storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                // Create a UIImage, add it to the array
                let pic = UIImage(data: data!)
                self.picArray.append(pic!)
                DispatchQueue.main.async {
                    self.imagesCollectionView.reloadData()
                }
            }
        })
        print(self.picArray.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImagesCollectionViewCell
        cell.collectionImageView.image = nil
        
        cell.collectionImageView.image = self.picArray[indexPath.row]
        cell.setNeedsLayout()
        
        
        return cell
    }
    
    
    // MARK: - Lazy Instantiates
    
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
