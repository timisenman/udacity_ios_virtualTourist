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
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<LocationPhoto>!
    var tappedPin: LocationPin!
    
    var savedPhotos: [LocationPhoto] = [LocationPhoto]()
    var photosToDelete: [LocationPhoto] = [LocationPhoto]()
    var mapViewLat: Double?
    var mapViewLong: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoTableView.delegate = self
        locationZoomIn.delegate = self
        fetchPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureMapZoom()
        fetchPhotos()
        
        if savedPhotos.count < 1 {
            downloadNewImagesAt(page: 1)
            print("Downloading new images at viewWillAppear. Image Count: \(savedPhotos.count)")
        } else {
            fetchPhotos()
            print("Saved photos count at viewWillAppear: \(savedPhotos.count)")
        }
        
    }
    
    @IBAction func confirmImageSelectionAction(_ sender: Any) {
        self.deleteAndGetNewPhotos()
        print("Confirm button pressed.")
    }
    
    //MARK: Core Data Protocols
    func fetchPhotos() {
        let fetchRequest: NSFetchRequest<LocationPhoto> = LocationPhoto.fetchRequest()
        let predicate = NSPredicate(format: "locationPin == %@", tappedPin)
        fetchRequest.predicate = predicate
        let sortDescriptors = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptors]
        
        //Assign photos to local array
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            savedPhotos = results
        }
    }
    
    func downloadNewImagesAt(page: Int) {
        VTClient.shared.getImagesFrom(lat: tappedPin.latitude, long: tappedPin.longitude, pageNumber: page) { (dictionary, success, string) in
            
            if success {
                for photoDict in dictionary {
                    let photo = LocationPhoto(context: self.dataController.viewContext)
                    photo.locationPin = self.tappedPin
                    photo.url_m = photoDict["url_m"] as? String
                    photo.id = photoDict["id"] as? String
                    self.savedPhotos.append(photo)
                    print(photo)
                }
                
                DispatchQueue.main.async {
                    self.photoTableView.reloadData()
                }
            }
            try? self.dataController.viewContext.save()
        }
    }
    
    //Deletes and pulls new images upon user request.
    func deleteAndGetNewPhotos() {
        if savedPhotos.count >= 1 {
            for photo in savedPhotos {
                dataController.viewContext.delete(photo)
            }
        } else {
            downloadNewImagesAt(page: 2)
        }
    }

    //MARK: Collection View Protocols
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseID = Constants.StoryboardIDs.CellReuseID
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CustomCollectionViewCell
        
        //Iterate through the saves images and download their data before assigning the images in the Collection View
        for photo in savedPhotos {
            if photo.imageData == nil {
                if let imageData = try? Data(contentsOf: URL(string: photo.url_m!)!) {
                    print("Saving images while on page.")
                    photo.imageData = imageData
                }
            }
        }
        
        let cellPhoto = savedPhotos[(indexPath as NSIndexPath).row]
        
        //Try showing images from memory
        if let imageData = cellPhoto.imageData {
            print("Assignment from memory")
            cell.cellImageView.image = UIImage(data: imageData)
        } else {
            //Default to showing images through calling the URL
            if let imageData = try? Data(contentsOf: URL(string: cellPhoto.url_m!)!) {
                print("Assignment from url conversion.")
                cell.cellImageView.image = UIImage(data: imageData)
                cellPhoto.imageData = imageData
            }
        }
        
        try? dataController.viewContext.save()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reuseID = Constants.StoryboardIDs.CellReuseID
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CustomCollectionViewCell
        let cellPhoto = savedPhotos[(indexPath as NSIndexPath).row]
        
        //Delete image functionality
        
    }
    
    //MARK: Zoomed Map Configuration
    func configureMapZoom() {
        let zoomCoordinates = CLLocationCoordinate2DMake(tappedPin.latitude, tappedPin.longitude)
        let mapSpan = MKCoordinateSpanMake(0.05, 0.05)
        let mapRegion = MKCoordinateRegionMake(zoomCoordinates, mapSpan)
        self.locationZoomIn.setRegion(mapRegion, animated: false)
        
        let coodinates = CLLocationCoordinate2D(latitude: tappedPin.latitude, longitude: tappedPin.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coodinates
        self.locationZoomIn.addAnnotation(annotation)
        locationZoomIn.isUserInteractionEnabled = false
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
