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

class GalleryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CellTitled {
    
    // MARK: - Properties
    var titleForCell: String = ""
    let reuseIdentifier = "GalleryCell"
    var colView: UICollectionView!
    
    var imageURL: [URL] = []
    
    let storage = FIRStorage.storage()
    var ref: FIRDatabaseReference!
    // Create a reference with an initial file path and name
  
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        getImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
    
    
    func getImages() {
        
        ref = FIRDatabase.database().reference()
        
        let storageRef = storage.reference(forURL: "https://firebasestorage.googleapis.com/v0/b/upic-a2216.appspot.com/o")

        let imagesRef = storageRef.child("NATURE/")
        
       
        // let imagesRef = storageRef.child("NATURE/00E52E7C-5935-432C-A6A9-3BCD7B00C8CA.png")
        //gs://upic-a2216.appspot.com/
       
       // let starsRef = storageRef.child("images/stars.jpg")
        
        let child = imagesRef.child("")
        // Fetch the download URL
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        let archi = ref.child("categories").child("ARCHITECTURE")
        let query = archi.queryOrderedByValue()


//        
//        [specificPet observeEventType:FEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
//        NSDictionary *dict = snapshot.value;
//        NSString *key = snapshot.key;
//        
//        NSLog(@"key = %@ for child %@", key, dict);
//        }];
//
        
       
  
//        child.downloadURL { url, error in
//            if let error = error {
//                print(error)
//                // Handle any errors
//            } else {
//                print(url)
//                // Get the download URL for 'images/stars.jpg'
//            }
//        }
        
    
        // Child references can also take paths delimited by '/'
        // spaceRef now points to "images/space.jpg"
        // imagesRef still points to "images"
       // var spaceRef = storageRef.child("images/space.jpg")
        
        // This is equivalent to creating the full reference
        //let storagePath = "\(your_firebase_storage_bucket)/images/space.jpg"
        //spaceRef = storage.reference(forURL: storagePath)
        
        
        
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
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        cell.backgroundColor = ColorPalette.lightPrimaryColor
    
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
