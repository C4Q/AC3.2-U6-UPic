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

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var imagesCollectionView: UICollectionView!
    
    var assetsArr: [PHAsset] = []
    let reuseIdentifier = "imagesCellIdentifier"
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.view.addSubview(imagesCollectionView)
        self.view.addSubview(selectedImageView)
    }
    
    func configureConstraints() {
        imagesCollectionView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.height.equalTo(200.0)
        }
        selectedImageView.snp.makeConstraints { (view) in
            view.top.leading.trailing.equalToSuperview()
            view.bottom.equalTo(imagesCollectionView.snp.top)
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
    /*
          // MARK: - Navigation
          
          // In a storyboard-based application, you will often want to do a little preparation before navigation
          override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          // Get the new view controller using segue.destinationViewController.
          // Pass the selected object to the new view controller.
          }
     */
}

