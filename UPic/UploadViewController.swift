//
//  UploadViewController.swift
//  UPic
//
//  Created by Eric Chang on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import Photos
import SnapKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

enum Catagory: String {
    case animals = "WOOFS & MEOWS"
    case nature = "NATURE"
    case architecture = "ARCHITECTURE"
}
class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var imagesCollectionView: UICollectionView!
    //var catagories: [Catagory] = [.animals, .nature, .architecture]
    var catagories = ["WOOFS & MEOWS","NATURE", "ARCHITECTURE" ]
    var assetsArr: [PHAsset] = []
    var selectedSegment: Catagory = .animals
    var picToUpload: PHAsset?
    let reuseIdentifier = "imagesCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "UPLOAD"
        setupViewHierarchy()
        configureConstraints()
        
        getMoments()
    }
    
    func setupViewHierarchy() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        // layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 150, height: 200)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        imagesCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "imagesCellIdentifier")
        let nibName = UINib(nibName: "ImagesCollectionViewCell", bundle:nil)
        imagesCollectionView.register(nibName, forCellWithReuseIdentifier: reuseIdentifier)
        imagesCollectionView.backgroundColor = .white
        
        self.view.addSubview(topContainerView)
        self.topContainerView.addSubview(titleTextField)
        self.topContainerView.addSubview(scrollView)
        
        self.view.addSubview(imagesCollectionView)
        self.view.addSubview(selectedImageView)
        
        navigationController?.navigationBar.backgroundColor = ColorPalette.darkPrimaryColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "up_arrow"), style: .plain, target: self, action: #selector(didTapUpload))
        navigationItem.rightBarButtonItem?.tintColor = ColorPalette.accentColor
        
        catogorySegmentedControl = UISegmentedControl(items: catagories)
        catogorySegmentedControl.selectedSegmentIndex = 0
        catogorySegmentedControl.addTarget(self, action: #selector(didSelectSegment(sender:)), for: .valueChanged)
        
        self.scrollView.addSubview(catogorySegmentedControl)
    }
    
    func configureConstraints() {
        
        topContainerView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            let targetHeight = self.navigationController?.navigationBar.frame.size.height
            view.top.equalToSuperview().offset(targetHeight!)
            view.height.equalTo(110.0)
        }
        imagesCollectionView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.height.equalTo(200.0)
        }
        selectedImageView.snp.makeConstraints { (view) in
            view.top.equalTo(topContainerView.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.bottom.equalTo(imagesCollectionView.snp.top)
        }
        titleTextField.snp.makeConstraints { (view) in
            view.top.equalTo(topContainerView.snp.top).offset(40.0)
            view.leading.equalToSuperview().offset(8.0)
            view.trailing.equalToSuperview().inset(8.0)
            view.height.equalTo(20.0)
        }
        scrollView.snp.makeConstraints { (view) in
            view.bottom.equalTo(topContainerView.snp.bottom).inset(8.0)
            view.trailing.leading.equalTo(topContainerView)
            view.height.equalTo(30.0)
            
        }
        catogorySegmentedControl.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalTo(scrollView)
        }
        
    }
    
    internal func didSelectSegment(sender: UISegmentedControl) {
        selectedSegment = Catagory(rawValue: catagories[sender.selectedSegmentIndex])!
        print(selectedSegment)
        
    }
    
    internal func didTapUpload(sender: UIButton) {
        print("Upload Tapped")
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child(self.catogorySegmentedControl.titleForSegment(at: self.catogorySegmentedControl.selectedSegmentIndex)!).child("\(imageName).png")
        if let uploadData = UIImagePNGRepresentation(self.selectedImageView.image!) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                }
                //This gives us download URLs
//                let imageToUpload = metadata?.downloadURL()?.absoluteURL
//                if let user = FIRAuth.auth()?.currentUser {
//                    _ = FIRDatabase.database().reference().child("users").child(user.displayName!).setValue(["uploadedVideos":[imageToUpload]])
                //}
            })
        }
    }
    
    func getAssets(collection: PHAssetCollection) -> [PHAsset] {
        
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        var returnAssets = [PHAsset]()
        for j in 0..<assets.count {
            returnAssets.append(assets[j])
            
            if j > 20 {
                break
            }
        }
        return returnAssets
    }
    
    func getMoments() {
        
        let options = PHFetchOptions()
        let sort = NSSortDescriptor(key: "startDate", ascending: false)
        options.sortDescriptors = [sort]
        let cutoffDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 30 * -1)
        let predicate = NSPredicate(format: "startDate > %@", cutoffDate)
        options.predicate = predicate
        let momentsLists = PHCollectionList.fetchMomentLists(with: .momentListCluster, options: nil)
        for i in 0..<momentsLists.count {
            let moments = momentsLists[i]
            let collectionList = PHCollectionList.fetchCollections(in: moments, options:options)
            for j in 0..<collectionList.count {
                if let collection = collectionList[j] as? PHAssetCollection {
                    assetsArr += getAssets(collection: collection)
                }
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCellIdentifier", for: indexPath) as! ImagesCollectionViewCell
        guard assetsArr.count > 0 else {
            return cell
        }
        let manager = PHImageManager.default()
        let asset = assetsArr[indexPath.row]
        manager.requestImage(for: asset,targetSize: CGSize(width: 400.0, height: 400.0),
                             contentMode: .aspectFill,options: nil) { (result, _) in
                                cell.collectionImageView.image = result
                                cell.setNeedsLayout()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assetsArr[indexPath.row]
        self.picToUpload = assetsArr[indexPath.row]
        let manager = PHImageManager.default()
        manager.requestImage(for: asset,targetSize: CGSize(width: 400.0, height: 400.0), contentMode: .aspectFit, options: nil) { (result, _)  in
            self.selectedImageView.image = result
        }
    }
    
    internal lazy var selectedImageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    internal lazy var topContainerView: UIView! = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primaryColor
        return view
    }()
    
    internal lazy var scrollView: UIScrollView! = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .blue
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    internal lazy var titleTextField: UITextField! = {
        let textField = UITextField()
        textField.placeholder = "TITLE"
        textField.textColor = ColorPalette.accentColor
        // textField.tintColor = ColorPalette.accentColor
        //        var bottomLine = CALayer()
        //        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height-1, width: textField.frame.width, height: 1.0)
        //        bottomLine.backgroundColor = UIColor.white.cgColor
        //        textField.borderStyle = UITextBorderStyle.none
        //        textField.layer.addSublayer(bottomLine)
        
        return textField
    }()
    
    internal lazy var catogorySegmentedControl: UISegmentedControl! = {
        let segmentedControl = UISegmentedControl()
        
        return segmentedControl
    }()
    
}
