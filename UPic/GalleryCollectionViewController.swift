//
//  GalleryCollectionViewController.swift
//  UPic
//
//  Created by Eric Chang on 2/7/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseStorage

class GalleryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CellTitled {
    
    // MARK: - Properties
    var titleForCell: String = ""
    let reuseIdentifier = "GalleryCell"
    var colView: UICollectionView!
    let ref = FIRDatabase.database().reference()
    var imageURLs: [URL] = []
    var imagesToLoad = [UIImage]()
    var refArr: [FIRStorageReference] = []
    var category: GallerySections!
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        loadCollectionImages(category: category)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        colView.collectionViewLayout.invalidateLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup View Hierarchy & Constraints
    internal func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        colView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        colView.delegate = self
        colView.dataSource = self
        colView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: "GalleryCell")
        colView.backgroundColor = ColorPalette.primaryColor
        
        self.navigationController?.navigationBar.tintColor = ColorPalette.accentColor
        self.title = titleForCell
        
        view.addSubview(colView)
    }
    
    internal func configureConstraints() {
        colView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Firebase Storage - Download Images
    func loadCollectionImages(category: GallerySections) {
        
        let userReference = FIRDatabase.database().reference().child("categories").child(category.rawValue)
        print(userReference)
        userReference.observe(.childAdded, with: { (snapshot) in
            
            if snapshot.childrenCount != 0 {
                let downloadURL = snapshot.childSnapshot(forPath: "url").value
                
                self.imageURLs.append(URL(string: downloadURL as! String )!)
                let storageRef = FIRStorage.storage().reference(forURL: downloadURL as! String )
                self.refArr.append(storageRef)
                //Check Cache for Image
                if let cachedImage = imageCache.object(forKey: downloadURL as AnyObject) as? UIImage {
                    
                    self.imagesToLoad.append(cachedImage)
                    self.imageURLs.append(URL(string: downloadURL as! String )!)
                    DispatchQueue.main.async {
                        self.colView.reloadData()
                    }
                    dump(cachedImage)
                    return
                }
                
                
                
                // Download the data, assuming a max size of 1MB (you can change this as necessary)
                storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                    // Create a UIImage, add it to the array
                    if let data = data {
                        let pic = UIImage(data: data)
                        
                        //If Image isn't in Cache, insert it for future use
                        imageCache.setObject(pic!, forKey: downloadURL as AnyObject)
                        self.imagesToLoad.append(pic!)
                        
                        DispatchQueue.main.async {
                            self.colView.reloadData()
                        }
                    }
                }
            }
            
        })
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesToLoad.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! GalleryCollectionViewCell
        
        cell.imageView.image = nil
        
        cell.imageView.image = self.imagesToLoad[indexPath.row]
        
        
        cell.textLabel.text = String(describing: self.imagesToLoad[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let displayImageVC = DisplayImageViewController()
        displayImageVC.image = self.imagesToLoad[indexPath.row]
        displayImageVC.imageUrl = self.imageURLs[indexPath.row]
        displayImageVC.ref = self.refArr[indexPath.row]
        self.navigationController?.pushViewController(displayImageVC, animated: false)
        
    }
    
    //TODO: Fix Collection View Overlap
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: colView.frame.size.width/2, height: colView.frame.size.width/2)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}

