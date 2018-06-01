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
    
    //When cells are selected in a collection view, the dim to show that they've been selected
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
