//
//  LocationCollectionViewController.swift
//  VirtualTourist
//
//  Created by Timothy Isenman on 5/4/18.
//  Copyright © 2018 Timothy Isenman. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var collectionViewActionButton: UIButton!
    @IBOutlet weak var photoTableView: UICollectionView!
    @IBOutlet weak var locationZoomIn: MKMapView!
    
//    let locImages = locationImages.shared.imageArray
    var locImages: [String] = [String]()
    var mapViewLat: Double?
    var mapViewLong: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoTableView.delegate = self
        locationZoomIn.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureMapZoom()
        
        if let latitude = mapViewLat, let longitude = mapViewLong {
            VTClient.shared.getFromLatLong(lat:latitude, long: longitude) { (data, success, string) in
                if success {
                    print(string!)
                    DispatchQueue.main.async {
                        self.locImages = data
                        print("LocImages Count: \(data.count)")
                        self.photoTableView.reloadData()
                        
                    }
                }
            }
        }
    }

    
    @IBAction func confirmImageSelectionAction(_ sender: Any) {
        print("Confirm button pressed.")
    }
    
    func configureMapZoom() {
        if let latitude = mapViewLat, let longitude = mapViewLong {
            let zoomCoordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let mapSpan = MKCoordinateSpanMake(0.05, 0.05)
            let mapRegion = MKCoordinateRegionMake(zoomCoordinates, mapSpan)
            self.locationZoomIn.setRegion(mapRegion, animated: false)
            
            let coodinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coodinates
            self.locationZoomIn.addAnnotation(annotation)
        }
        locationZoomIn.isUserInteractionEnabled = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseID = Constants.StoryboardIDs.CellReuseID
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CustomCollectionViewCell
        
        let locImage = locImages[(indexPath as NSIndexPath).row]
        if let imageData = try? Data(contentsOf: URL(string: locImage)!) {
                cell.cellImageView.image = UIImage(data: imageData)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
}
