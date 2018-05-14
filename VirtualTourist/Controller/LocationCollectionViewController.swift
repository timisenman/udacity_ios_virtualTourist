//
//  LocationCollectionViewController.swift
//  VirtualTourist
//
//  Created by Timothy Isenman on 5/4/18.
//  Copyright © 2018 Timothy Isenman. All rights reserved.
//

import UIKit
import CoreData

class LocationCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mapZoomImage: UIImageView!
    @IBOutlet weak var collectionViewActionButton: UIButton!
    @IBOutlet weak var photoTableView: UICollectionView!
    
    
//    let locImages = locationImages.shared.imageArray
    var locImages: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        VTClient.shared.getFromLatLong { (data, success, string) in
            if success {
                print(string!)
                DispatchQueue.main.async {
                    self.locImages = data
                    print("LocImages Count: \(data.count)")
                    self.photoTableView.reloadData()
                    
                    if let imageData = try? Data(contentsOf: URL(string: self.locImages[0])!) {
                        self.mapZoomImage.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }

    
    @IBAction func confirmImageSelectionAction(_ sender: Any) {
        print("Confirm button pressed.")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseID = Constants.StoryboardIDs.CellReuseID
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CustomCollectionViewCell
        
        let locImage = locImages[(indexPath as NSIndexPath).row]
        print(locImage)
        if let imageData = try? Data(contentsOf: URL(string: locImage)!) {
                cell.cellImageView.image = UIImage(data: imageData)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
    }
    
    
}
