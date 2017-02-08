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
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

enum Catagory: String {
    case animals = "WOOFS & MEOWS"
    case nature = "NATURE"
    case architecture = "ARCHITECTURE"
}

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var imagesCollectionView: UICollectionView!
    var topImagesCollectionView: UICollectionView!
    //var catagories: [Catagory] = [.animals, .nature, .architecture]
    var catagories: [String] = [Catagory.animals, Catagory.nature, Catagory.architecture].map{ $0.rawValue }
    var assetsArr: [PHAsset] = []
    var selectedSegment: Catagory = .animals
    var selectedIndex = 0
    var selectedImage: UIImage?
    
    let reuseIdentifier = "imagesCellIdentifier"
    let bottomCollectionViewItemSize = CGSize(width: 125, height: 175)
    let bottomCollectionViewNibName = "ImagesCollectionViewCell"
    let topCollectionViewIdentifier = "topImagesCellIdentifier"
    let topCollectionViewNibName = "TopCollectionViewCell"
    let topCollectionViewItemSize = CGSize(width: 300, height: 300)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "UPLOAD"
        setupViewHierarchy()
        configureConstraints()
        
        getMoments()
    }
    
    func setupViewHierarchy() {
        
        createBottomCollectionView()
        createTopCollectionView()
        self.view.addSubview(topContainerView)
        titleTextField.textColor = ColorPalette.accentColor
        self.topContainerView.addSubview(titleTextField)
        self.topContainerView.addSubview(scrollView)
        
        self.view.addSubview(imagesCollectionView)
        //        self.view.addSubview(selectedImageView)
        self.view.addSubview(topImagesCollectionView)
        
        navigationController?.navigationBar.backgroundColor = ColorPalette.darkPrimaryColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "up_arrow"), style: .plain, target: self, action: #selector(didTapUpload))
        navigationItem.rightBarButtonItem?.tintColor = ColorPalette.accentColor
        
        catogorySegmentedControl = UISegmentedControl(items: catagories)
        catogorySegmentedControl.selectedSegmentIndex = 0
        catogorySegmentedControl.addTarget(self, action: #selector(didSelectSegment(sender:)), for: .valueChanged)
        catogorySegmentedControl.tintColor = ColorPalette.accentColor
        catogorySegmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: ColorPalette.textIconColor], for: UIControlState.normal)
        catogorySegmentedControl.setDividerImage(imageWithColor(color: ColorPalette.primaryColor), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
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
            view.height.equalTo(175.0)
        }
        topImagesCollectionView.snp.makeConstraints { (view) in
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
    
    func createTopCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        // layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //layout.itemSize = topImagesCollectionView.contentSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        topImagesCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        topImagesCollectionView.delegate = self
        topImagesCollectionView.dataSource = self
        //        topImagesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //        let nib = UINib(nibName: bottomCollectionViewNibName, bundle:nil)
        //        topImagesCollectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        topImagesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: topCollectionViewIdentifier)
        let nib = UINib(nibName: topCollectionViewNibName, bundle:nil)
        topImagesCollectionView.register(nib, forCellWithReuseIdentifier: topCollectionViewIdentifier)
        topImagesCollectionView.backgroundColor = .white
    }
    
    internal func didSelectSegment(sender: UISegmentedControl) {
        selectedSegment = Catagory(rawValue: catagories[sender.selectedSegmentIndex])!
        
        print(selectedSegment)
        
    }
    
    /*
    let storage = FIRStorage.storage()
    let data: NSData = myImageData
    let userProfilePic =
    let userProfilePic = storageRef.child("users/abc/profileimage.jpg")
    
    let uploadTask = userProfilePic.putData(data, metadata: nil) { metadata, error in
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            let downloadURL = metadata!.downloadURL
            // store downloadURL in db
            storeUserProfileInDB(downloadURL)
        }
    }
    
    func storeUserProfileInDB(profileImgUrl: NSURL) {
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        let dictionaryUser = [ "userName"    : name! ,
                               "imageUrl" : profileImgUrl.absoluteString,
                               ]
        
        let childUpdates = ["/users/\(key)": dictionaryTodo]
        ref.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) -> Void in
            //save
        })
        
    }
    */
    internal func didTapUpload(sender: UIButton) {
        print("From upload, users UID \(FIRAuth.auth()?.currentUser?.uid)")
        print("From upload, users display name \(FIRAuth.auth()?.currentUser?.displayName)")
        let imageName = NSUUID().uuidString
        let user = FIRAuth.auth()?.currentUser
        if user?.uid != nil {
        let storageRef = FIRStorage.storage().reference().child(self.catogorySegmentedControl.titleForSegment(at: self.catogorySegmentedControl.selectedSegmentIndex)!).child("\(imageName).png")
        if let uploadData = UIImagePNGRepresentation(self.selectedImage!) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                }
               
//                FIRDatabase.database().reference().child("users").child((user?.uid)!).updateChildValues(["uploadedImages": [String(describing: metadata!.downloadURL()!)]])
                
            })
        }
    }
        else {
            let alert = UIAlertController(title: "Error", message: "You need to log in to upload images", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func getAssets(collection: PHAssetCollection) -> [PHAsset] {
        
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        var returnAssets = [PHAsset]()
        for j in 0..<assets.count {
            if assets[j].mediaType == .image {
                returnAssets.append(assets[j])
                
            }
        }
        return returnAssets
    }
    
    func getMoments() {
        
        let options = PHFetchOptions()
        let sort = NSSortDescriptor(key: "startDate", ascending: false)
        options.sortDescriptors = [sort]
        //        let cutoffDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 30 * 12 * 2 * -1)
        //        let predicate = NSPredicate(format: "startDate > %@", cutoffDate)
        //        options.predicate = predicate
        
        let momentsLists = PHCollectionList.fetchMomentLists(with: .momentListCluster, options: nil)
        for i in (0..<momentsLists.count).reversed() {
            let moments = momentsLists[i]
            let collectionList = PHCollectionList.fetchCollections(in: moments, options:options)
            for j in 0..<collectionList.count {
                if let collection = collectionList[j] as? PHAssetCollection {
                    
                    assetsArr += getAssets(collection: collection)
                    
                    if assetsArr.count > 200 {
                        break
                    }
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
        
        guard assetsArr.count > 0 else {
            return UICollectionViewCell()
        }
        
        let manager = PHImageManager.default()
        let asset = assetsArr[indexPath.row]
        
        
        if collectionView == self.imagesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImagesCollectionViewCell
            cell.collectionImageView.image = nil
            
            manager.requestImage(for: asset,targetSize: CGSize(width: 400.0, height: 400.0),
                                 contentMode: .aspectFill,options: nil) { (result, _) in
                                    cell.collectionImageView.image = result
                                    self.selectedImage = result
                                    cell.setNeedsLayout()
                                    
            }
            return cell
        }
            
        else if collectionView == self.topImagesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topCollectionViewIdentifier, for: indexPath) as! TopCollectionViewCell
            
            cell.frame.size = topImagesCollectionView.frame.size
            cell.imageView.image = nil
            
            manager.requestImage(for: asset,targetSize: CGSize(width: 400.0, height: 400.0),
                                 contentMode: .aspectFill,options: nil) { (result, _) in
                                    cell.imageView.image = result
                                    self.selectedImage = result
                                    cell.setNeedsLayout()
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == imagesCollectionView {
            
            for _ in imagesCollectionView.visibleCells {
                let indexPath = self.imagesCollectionView.indexPathsForVisibleItems
                topImagesCollectionView.scrollToItem(at: indexPath[1], at: .centeredHorizontally, animated: false)
            }
        }
            
        else if scrollView == topImagesCollectionView {
            for _ in topImagesCollectionView.visibleCells {
                let indexPath = self.topImagesCollectionView.indexPathsForVisibleItems
                imagesCollectionView.scrollToItem(at: indexPath[0], at: .left, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == topImagesCollectionView {
            return collectionView.frame.size
        }
        else {
            let height = collectionView.frame.size.height
            let width = height.multiplied(by: 0.75)
            return CGSize(width: width, height: height)
        }
    }
    
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 15.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        topImagesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        let asset = assetsArr[indexPath.row]
        let manager = PHImageManager.default()
        manager.requestImage(for: asset,targetSize: CGSize(width: 400.0, height: 400.0), contentMode: .aspectFit, options: nil) { (result, _)  in
            //uploading the selected photo to the database
            
            
            //dump(result)
        }
        
        
    }
    
    internal lazy var topContainerView: UIView! = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primaryColor
        return view
    }()
    
    internal lazy var scrollView: UIScrollView! = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    internal lazy var titleTextField: UITextField! = {
        let textField = UITextField()
        textField.placeholder = "TITLE"
        
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
