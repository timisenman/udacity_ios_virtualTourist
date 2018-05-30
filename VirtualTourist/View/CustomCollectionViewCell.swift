//
//  CustomCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Timothy Isenman on 5/12/18.
//  Copyright © 2018 Timothy Isenman. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.cellImageView.alpha = 0.5
            } else {
                self.cellImageView.alpha = 1.0
            }
        }
    }
}
