//
//  LocationCollectionViewController.swift
//  VirtualTourist
//
//  Created by Timothy Isenman on 5/4/18.
//  Copyright © 2018 Timothy Isenman. All rights reserved.
//

import UIKit
import CoreData

class LocationCollectionViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var mapZoomImage: UIImageView!
    @IBOutlet weak var collectionViewActionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func confirmImageSelectionAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
