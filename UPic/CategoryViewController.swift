//
//  CategoryViewController.swift
//  UPic
//
//  Created by Eric Chang on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit

enum GallerySections: String {
    case woofmeow = "Woofs & Meows"
    case nature = "Nature"
    case architecture = "Architecture"
    
    static let sections: [String] = [GallerySections.woofmeow,
                                     GallerySections.nature,
                                     GallerySections.architecture].map { $0.rawValue }
    
    static func numberOfGallerySections() -> Int {
        return GallerySections.sections.count
    }
}

class CategoryViewController: UITableViewController, CellTitled {
    
    // Gallery View Controllers
    private let woofMeowViewControllers: [CellTitled] = [WoofMeowViewController()]
    private let natureViewControllers: [CellTitled] = [NatureViewController()]
    private let architectureViewControllers: [CellTitled] = [ArchitectureViewController()]
    
    // MARK: - Properties
    let titleForCell = "CATEGORIES"
    let cellIdentifier: String = "IndexCellIdentifier"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        self.tableView.rowHeight = 250.0
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.title = titleForCell
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        backBarButtonItem.tintColor = ColorPalette.accentColor
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    // MARK: - Setup View Hierarchy & Constraints
    func setupViewHierarchy() {
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
        switch section {
        case 0:
            return woofMeowViewControllers.count
        case 1:
            return natureViewControllers.count
        default:
            return architectureViewControllers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let newImage = UIImageView()
        newImage.contentMode = .scaleAspectFit
        
        let newOverlay = UIView()
        newOverlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        let newLabel = UILabel()
        newLabel.textAlignment = .center
        newLabel.textColor = ColorPalette.textIconColor
        newLabel.layer.borderColor = ColorPalette.textIconColor.cgColor
        newLabel.layer.borderWidth = 3.0
        
        setHierarchyAndConstraintsOf(imageView: newImage,
                                     overlay: newOverlay,
                                     label: newLabel,
                                     to: cell)
        
        let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 20)]
        
        switch (indexPath.section, indexPath.row) {
        case (0, let row):
            //TODO: set image, set label
            let boldString = NSMutableAttributedString(string: woofMeowViewControllers[row].titleForCell, attributes: attrs)
            
            newLabel.text = String(describing: boldString)
        case (1, 0):
            let boldString = NSMutableAttributedString(string: natureViewControllers[0].titleForCell, attributes: attrs)

            newLabel.text = String(describing: boldString)
        default:
            let boldString = NSMutableAttributedString(string: architectureViewControllers[0].titleForCell, attributes: attrs)

            newLabel.text = String(describing: boldString)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return GallerySections.sections[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, let row):
            let wmvc = woofMeowViewControllers[row] as! UIViewController
            navigationController?.pushViewController(wmvc, animated: true)
        case (1, 0):
            let nvc = natureViewControllers[0] as! UIViewController
            navigationController?.pushViewController(nvc, animated: true)
        default:
            let avc = architectureViewControllers[0] as! UIViewController
            navigationController?.pushViewController(avc, animated: true)
        }
    }
    
    internal func setHierarchyAndConstraintsOf(imageView: UIImageView, overlay: UIView, label: UILabel, to cell: UITableViewCell) {
        cell.addSubview(imageView)
        cell.addSubview(overlay)
        cell.addSubview(label)
        
        imageView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalTo(cell)
        }
        
        overlay.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalTo(imageView)
        }
        
        label.snp.makeConstraints { (make) in
            make.center.equalTo(overlay)
            make.width.equalTo(200.0)
            make.height.equalTo(80.0)
        }
    }
    
}

