//
//  GalleryCollectionViewCell.swift
//  UPic
//
//  Created by Eric Chang on 2/7/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {

    var imageView: UIImageView!
    var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        textLabel = UILabel(frame:  CGRect(x: 0, y: imageView.frame.size.height / 2, width: frame.size.width, height: frame.size.height))
        
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        
        textLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        textLabel.textAlignment = .center
        contentView.addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
