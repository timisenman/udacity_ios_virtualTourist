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
    
    let locImages = locationImages.shared.imageArray
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        VTClient.shared.getFromLatLong { (success, string) in
            if success {
                print(string!)
                if let imageData = try? Data(contentsOf: URL(string: self.locImages[0])!) {
                    self.mapZoomImage.image = UIImage(data: imageData)
                    print("Zoom image set.")
                }
                print("LocImages Count: \(self.locImages.count)")
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
        
        let locImage = locationImages.shared.imageArray[(indexPath as NSIndexPath).row]
        if let imageData = try? Data(contentsOf: URL(string: locImage)!) {
                cell.cellImageView.image = UIImage(data: imageData)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
    }
    
    
}
