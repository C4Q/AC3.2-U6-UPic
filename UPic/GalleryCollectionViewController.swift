//
//  GalleryCollectionViewController.swift
//  UPic
//
//  Created by Eric Chang on 2/7/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase

class GalleryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CellTitled {
    
    // MARK: - Properties
    var titleForCell: String = ""
    let reuseIdentifier = "GalleryCell"
    var colView: UICollectionView!
    let ref = FIRDatabase.database().reference()
    var imagesToLoad = [URL]()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        loadCollectionImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func loadCollectionImages() {
        //        let storageRef = storage.reference(forURL: "https://firebasestorage.googleapis.com/v0/b/upic-a2216.appspot.com/o")
        
        ref.child("categories").child("WOOFS & MEOWS").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let value = snapshot.value as? NSDictionary {
                for each in value {
                    guard let imgURL = URL(string: each.value as! String) else { continue }
                    self.imagesToLoad.append(imgURL)
                    print(self.imagesToLoad.count)
                }
                
                DispatchQueue.main.async {
                    self.colView.reloadData()
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
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
        
        cell.backgroundColor = ColorPalette.lightPrimaryColor
        //cell.imageView.image = imagesToLoad[indexPath.row]
        
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
