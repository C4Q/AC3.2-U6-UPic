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

class LoggedInViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var titleForCell = "YOUR PROFILE"
    let reuseIdentifier = "imagesCellIdentifier"
    let bottomCollectionViewItemSize = CGSize(width: 125, height: 175)
    let bottomCollectionViewNibName = "ImagesCollectionViewCell"
    var imagesCollectionView: UICollectionView!
    var userTableView: UITableView = UITableView()
    var userVotes: [String] = []

    var userProfileImageReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("profileImageURL")
    var userUploadsReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("uploads")
    
    var picArray = [UIImage]()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        configureConstraints()
        self.navigationItem.hidesBackButton = true
        
        downloadProfileImage()
        downloadUserUploads()
        //imagesCollectionView.clearsSelectionOnViewWillAppear = false
    }
    
    // MARK: - Setup View Hierarchy & Constraints
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = ColorPalette.primaryColor
        self.tabBarController?.title = titleForCell
        
        createBottomCollectionView()
        
        view.addSubview(imagesCollectionView)
        view.addSubview(profileImage)
        view.addSubview(userTableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "LOG OUT", style: .plain, target: self, action: #selector(didTapLogout(sender:)))
        navigationItem.rightBarButtonItem?.tintColor = ColorPalette.accentColor
    }
    
    func configureConstraints() {
        
        imagesCollectionView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.height.equalTo(175.0)
        }
        profileImage.snp.makeConstraints { (view) in
            view.top.centerX.equalToSuperview()
            view.height.width.equalTo(200.0)
        }
        
        userTableView.snp.makeConstraints { (view) in
            view.top.equalTo(profileImage.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.bottom.equalTo(imagesCollectionView.snp.top)
        }
    }
    
    // MARK: - Actions
    func didTapLogout(sender: UIButton) {
        
        do {
            try FIRAuth.auth()?.signOut()
            _ = self.navigationController?.popViewController(animated: true)
        }
        catch {
            print(error)
        }
        
        do {
            FIRAuth.auth()?.signInAnonymously() { (user, error) in
                _ = user!.isAnonymous  // true
                _ = user!.uid
            }
        }
    }
    
    func createBottomCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
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
        return self.picArray.count
    }
    
    
    // MARK: - Download Image Tasks
    func downloadProfileImage() {
        //Fetch User Profile Image
        self.userProfileImageReference.observe(.childAdded, with: { (snapshot) in
            let downloadURL = snapshot.value as! String
            
            //Check cache for profile image
            if let cachedProfilePic = imageCache.object(forKey: downloadURL as AnyObject) {
                DispatchQueue.main.async {
                    self.profileImage.image = cachedProfilePic as? UIImage
                }
                return
            }
            
            //Download Image If Not Found In Cache. Insert into cache as well
            let storageRef = FIRStorage.storage().reference(forURL: downloadURL)
            
            storageRef.data(withMaxSize: 10 * 2000 * 2000) { (data, error) -> Void in
                
                if let data = data {
                    let pic = UIImage(data: data)
                    imageCache.setObject(pic!, forKey: downloadURL as AnyObject)
                    DispatchQueue.main.async {
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
    }
    
    //Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userVotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! VotersFeedTableViewCell
        
        cell.textLabel?.text = userVotes[indexPath.row]
        
        return cell
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
        profilePic.image = #imageLiteral(resourceName: "user_icon")
        profilePic.layer.cornerRadius = 100.0
        profilePic.layer.masksToBounds = true
        return profilePic
    }()
    
}
