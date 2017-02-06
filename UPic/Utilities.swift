//
//  Utilities.swift
//  UPic
//
//  Created by Eric Chang on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit

protocol CellTitled {
    var titleForCell: String { get }
}

struct ColorPalette {
    static let darkPrimaryColor: UIColor = UIColor(red:0.27, green:0.35, blue:0.39, alpha:1.0)
    static let primaryColor: UIColor = UIColor(red:0.38, green:0.49, blue:0.55, alpha:1.0)
    static let lightPrimaryColor: UIColor = UIColor(red:0.81, green:0.85, blue:0.86, alpha:1.0)
    static let textIconColor: UIColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
    static let accentColor: UIColor = UIColor(red:1.00, green:0.84, blue:0.25, alpha:1.0)
    static let primaryTextColor: UIColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
    static let secondaryTextColor: UIColor = UIColor(red:0.45, green:0.45, blue:0.45, alpha:1.0)
    static let dividerColor: UIColor = UIColor(red:0.71, green:0.71, blue:0.71, alpha:1.0)
    
}
