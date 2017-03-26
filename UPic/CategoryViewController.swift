//
//  CategoryViewController.swift
//  UPic
//
//  Created by Eric Chang on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseStorage

class CategoryViewController: UITableViewController, CellTitled {
    
    // MARK: - Properties
    let titleForCell = "CATEGORIES"
    let cellIdentifier: String = "CategoryCellIdentifier"
    let storage = FIRStorage.storage()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        self.tableView.rowHeight = 250.0
        
        self.tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.navigationItem.title = titleForCell
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        backBarButtonItem.tintColor = ColorPalette.accentColor
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    // MARK: - Setup View Hierarchy & Constraints
    private func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        navigationController?.navigationBar.backgroundColor = ColorPalette.darkPrimaryColor
        navigationController?.navigationBar.barTintColor = ColorPalette.darkPrimaryColor
        self.view.backgroundColor = ColorPalette.primaryColor
        self.tabBarController?.title = titleForCell
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return GallerySections.numberOfGallerySections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CategoryTableViewCell
        
        switch (indexPath.section) {
        case (0):
            cell.newImage.image = #imageLiteral(resourceName: "woofmeow")
            cell.newLabel.text = "WOOFS & MEOWS"
        case (1):
            cell.newImage.image = #imageLiteral(resourceName: "nature")
            cell.newLabel.text = "NATURE"
        default:
            cell.newImage.image = #imageLiteral(resourceName: "architecture")
            cell.newLabel.text = "ARCHITECTURE"
        }
        
        cell.newLabel.font = UIFont(name: "Optima-Bold", size: 24.0)
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let galleryVC = GalleryCollectionViewController()
        galleryVC.titleForCell = GallerySections.sections[indexPath.section]
        galleryVC.category = GallerySections(rawValue: GallerySections.sections[indexPath.section])
        navigationController?.pushViewController(galleryVC, animated: true)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }       
}

