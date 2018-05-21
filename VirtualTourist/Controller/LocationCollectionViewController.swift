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
    var locImages: [String] = [String]()
    var savedPhotos: [LocationPhoto] = [LocationPhoto]()
    var fetchedResultsController: NSFetchedResultsController<LocationPhoto>!
    var tappedPin: LocationPin!
    
    var mapViewLat: Double?
    var mapViewLong: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoTableView.delegate = self
        locationZoomIn.delegate = self
        
        let fetchRequest: NSFetchRequest<LocationPhoto> = LocationPhoto.fetchRequest()
        let predicate = NSPredicate(format: "locationPin == %@", arguments: tappedPin)
        fetchRequest.predicate = predicate
        if let photos = try? dataController.viewContext.fetch(fetchRequest) {
            savedPhotos = photos
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureMapZoom()
        
        //TODO: If statement for when savedPhotos is empty
        downloadNewLocationPhotos()
    }
    
    
    @IBAction func confirmImageSelectionAction(_ sender: Any) {
        
        //Get images function, but with a random page.
        print("Confirm button pressed.")
    }
    
    //MARK: Core Data Protocols
    func fetchPhotos() {
        let fetchRequest: NSFetchRequest<LocationPhoto> = LocationPhoto.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "id", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptors]
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            photosToSave = results
        }
    }
    
    func downloadNewLocationPhotos() {
        VTClient.shared.getFromLatLong(lat: tappedPin.latitude, long: tappedPin.longitude) { (dictionary, success, string) in
            if success {
                DispatchQueue.main.async {
                    let photos = LocationPhoto(context: self.dataController.viewContext)
                    for photoDict in dictionary {
                        let imageData = try? Data(contentsOf: URL(fileURLWithPath: photos.url_m!))
                        photos.imageData = imageData
                        photos.url_m = photoDict["url_m"] as? String
                        photos.height_m = photoDict["height_m"] as? String
                        photos.width_m = photoDict["width_m"] as? String
                        photos.title = photoDict["title"] as? String
                        photos.id = photoDict["id"] as? String
                    }
                    
                    try? self.dataController.viewContext.save()
                    self.photoTableView.reloadData()
                }
            }
        }
    }

    
    func addPhotoToCoreData() {
        //Save the images downloaded from the request to the pin's photo array
    }
    
    //MARK: Collection View Protocols
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseID = Constants.StoryboardIDs.CellReuseID
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CustomCollectionViewCell
        
        //
        let locImage = photosToSave[(indexPath as NSIndexPath).row]
        cell.cellImageView.image = UIImage(data: locImage.imageData!)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
    }
    
    //MARK: Zoomed Map Configuration
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
