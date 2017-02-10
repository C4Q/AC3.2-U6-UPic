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

//Global Variable to have access throughout the app
let imageCache = NSCache<AnyObject, AnyObject>()

class LoggedInViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var titleForCell = "YOUR PROFILE"
    let reuseIdentifier = "imagesCellIdentifier"
    let bottomCollectionViewItemSize = CGSize(width: 125, height: 175)
    let bottomCollectionViewNibName = "ImagesCollectionViewCell"
    var imagesCollectionView: UICollectionView!

    var userProfileImageReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("profileImageURL")
    var userUploadsReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("uploads")
    
    
    var picArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        configureConstraints()
        self.navigationItem.hidesBackButton = true
        self.profileImage.image = #imageLiteral(resourceName: "user_icon")
        dump(FIRStorage.storage().reference())
        downloadProfileImage()
        downloadUserUploads()
        //imagesCollectionView.clearsSelectionOnViewWillAppear = false

    }
    
    
    func configureConstraints() {
        
        imagesCollectionView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.height.equalTo(175.0)
        }
        profileImage.snp.makeConstraints { (view) in
            view.top.leading.trailing.equalToSuperview()
            view.height.equalTo(200.0)
        }
        
        
    }
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = ColorPalette.primaryColor
        self.tabBarController?.title = titleForCell
        createBottomCollectionView()
        view.addSubview(imagesCollectionView)
        view.addSubview(profileImage)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "LOG OUT", style: .plain, target: self, action: #selector(didTapLogout(sender:)))
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
    
    
    
    func downloadProfileImage() {
        //Fetch User Profile Image
        self.userProfileImageReference.observe(.childAdded, with: { (snapshot) in
            let downloadURL = snapshot.value as! String
            dump("profile image url \(downloadURL)")
            //Check cache for profile image
            if let cachedProfilePic = imageCache.object(forKey: downloadURL as AnyObject) as? UIImage {
                DispatchQueue.main.async {
                    self.view.layoutSubviews()
                    self.profileImage.image = cachedProfilePic
                }
                return
            }
            
            //Download Image If Not Found In Cache. Insert into cache as well
            let storageRef = FIRStorage.storage().reference(forURL: downloadURL)
            
            storageRef.data(withMaxSize: 10 * 1024 * 1024) { (data, error) -> Void in
                
                if let data = data {
                    let pic = UIImage(data: data)
                    imageCache.setObject(pic!, forKey: downloadURL as AnyObject)
                    DispatchQueue.main.async {
                        self.view.layoutSubviews()
                        self.profileImage.image = pic
                    }
                }
            }
        })

    }
    
    func downloadUserUploads() {
       
        
        //Downloads User Uploads
        self.userUploadsReference.observe(.childAdded, with: { (snapshot) in
            // Get download URL from snapshot
            let downloadURL = snapshot.value as! String
            dump("This is download URL \(downloadURL)")
            
            //Check cache for images
            if let cachedImage = imageCache.object(forKey: downloadURL as AnyObject) as? UIImage {
                self.picArray.append(cachedImage)
                DispatchQueue.main.async {
                    self.imagesCollectionView.reloadData()
                }
                return
            }
            
            // Create a storage reference from the URL
            let storageRef = FIRStorage.storage().reference(forURL: downloadURL)
            // Download the data, assuming a max size of 1MB (you can change this as necessary)
            storageRef.data(withMaxSize: 10 * 1024 * 1024) { (data, error) -> Void in
                // Create a UIImage, add it to the array
                if let data = data {
                let pic = UIImage(data: data)
                imageCache.setObject(pic!, forKey: downloadURL as AnyObject)
                self.picArray.append(pic!)
                }
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
    
    // UIImage
    lazy var profileImage: UIImageView = {
        let profilePic = UIImageView()
        profilePic.contentMode = .scaleAspectFit
        return profilePic
    }()
    
}
