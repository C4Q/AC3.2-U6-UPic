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
    var imagesToLoad = [UIImage]()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup View Hierarchy & Constraints
    internal func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 2, height: view.frame.height/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
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
            
            let downloadURL = snapshot.value as! String
            dump("This is download URL \(downloadURL)")
            
            let storageRef = FIRStorage.storage().reference(forURL: downloadURL)
            // Download the data, assuming a max size of 1MB (you can change this as necessary)
            storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                // Create a UIImage, add it to the array
                if let data = data {
                    let pic = UIImage(data: data)
                    self.imagesToLoad.append(pic!)
                    
                    DispatchQueue.main.async {
                        self.colView.reloadData()
                    }
                }
            }
            
        })
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesToLoad.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GalleryCollectionViewCell
        
        cell.imageView.image = imagesToLoad[indexPath.row]
        
        cell.textLabel.text = String(describing: imagesToLoad[indexPath.row])
        
        return cell
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
