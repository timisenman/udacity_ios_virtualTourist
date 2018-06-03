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
    var photosToDelete: [IndexPath] = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Delegates
        photoTableView.delegate = self
        locationZoomIn.delegate = self
        
        //Configure UI
        buttonConfiguration()
        photoTableView.allowsMultipleSelection = true
        
        //Download Image Data from CoreData
        fetchPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureMapZoom()
        fetchPhotos()
        
        //Fetch the LocationPhotos if they exist, otherwise download the photos of that location
        if savedPhotos.count < 1 {
            downloadNewImagesAt(page: 1)
        } else {
            fetchPhotos()
        }
    }
    
    //MARK: User Experience
    @IBAction func confirmImageSelectionAction(_ sender: Any) {
        deleteAndGetNewPhotos()
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
        VTClient.shared.getImagesFrom(lat: tappedPin.latitude, long: tappedPin.longitude, pageNumber: page, perPage: nil) { (dictionary, success, string) in
            
            guard let successfulDownload = success else {
                fatalError("Unsuccessful download Flickr Data.")
            }
            
            guard let flickrDictionary = dictionary else {
                fatalError("No photos available in Flickr request.")
            }
            
            if successfulDownload {
                
                if flickrDictionary.count == 0 {
                    print("Dictionary item count: \(flickrDictionary.count)")
                    self.displayUIAlert(with: "Sorry, there are no images from this place.")
                }
                //Parse the dictionary of data downloaded from Flickr and assign the properties of the individual photos
                for photoDict in flickrDictionary {
                    let photo = LocationPhoto(context: self.dataController.viewContext)
                    photo.locationPin = self.tappedPin!
                    photo.url_m = photoDict["url_m"] as? String
                    photo.id = photoDict["id"] as? String
                    self.savedPhotos.append(photo)
                }
                
                //Reload the data after it's received by the ViewController
                DispatchQueue.main.async {
                    self.photoTableView.reloadData()
                }
            }
            try? self.dataController.viewContext.save()
        }
    }
    
    //Deletes and pulls new images upon user request.
    func deleteAndGetNewPhotos() {
        if photosToDelete.count == 0 {
            for photo in savedPhotos {
                dataController.viewContext.delete(photo)
            }
            savedPhotos.removeAll()
            photosToDelete.removeAll()
            
            //Pulls new photos from the next page, then the next page, rather than a random number which might be out of range
            var page = 2
            downloadNewImagesAt(page: page)
            page += 1
            
            try? dataController.viewContext.save()
            photoTableView.reloadData()
            print("Saved photos after a new page request: \(savedPhotos.count)")
        } else {
            for photo in photosToDelete {
                let index = photo.row
                dataController.viewContext.delete(savedPhotos[index])
                savedPhotos.remove(at: index)
            }
            photoTableView.deleteItems(at: photosToDelete)
            photoTableView.reloadData()
            photosToDelete.removeAll()
            try? dataController.viewContext.save()
            defaultButtonStyle()
            print("Saved photos after deleting selected photos: \(savedPhotos.count)")
        }
    }
    

    //MARK: Collection View Protocols
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseID = Constants.StoryboardIDs.CellReuseID
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CustomCollectionViewCell
        
        for photo in savedPhotos {
            if photo.imageData == nil {
                if let urlString = photo.url_m {
                    if let imageData = try? Data(contentsOf: URL(string: urlString)!) {
                        photo.imageData = imageData
                    }
                }
            }
        }
        
        let cellPhoto = savedPhotos[(indexPath as NSIndexPath).row]
        
        //Try showing images from memory
        if let imageData = cellPhoto.imageData {
            cell.cellImageView.image = UIImage(data: imageData)
        } else {
            //Default to showing images through calling the URL
            if let urlString = cellPhoto.url_m {
                if let imageData = try? Data(contentsOf: URL(string: urlString)!) {
                    cell.cellImageView.image = UIImage(data: imageData)
                    cellPhoto.imageData = imageData
                }
            }
        }
        
        try? dataController.viewContext.save()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Toggle the state of the Delete Photos confirmation button
        deleteImagesState()
        photosToDelete.append(indexPath)
        print("Photos to delete: \(photosToDelete.count)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = photosToDelete.index(of: indexPath) {
            photosToDelete.remove(at: index)
        }
        
        //Set the style of the button if a user deselects all of the images they initially selected to delete
        if photosToDelete.isEmpty {
            defaultButtonStyle()
        }
        
        print("Photos to delete, after deselect: \(photosToDelete.count)")
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
    
    //MARK: UI Configurations
    func defaultButtonStyle() {
        collectionViewActionButton.setTitle("Get New Images", for: .normal)
        collectionViewActionButton.backgroundColor = UIColor.blue
    }
    
    func deleteImagesState() {
        collectionViewActionButton.setTitle("Delete Selected Images", for: .normal)
        collectionViewActionButton.backgroundColor = UIColor.red
    }
    
    func buttonConfiguration() {
        collectionViewActionButton.setTitle("Get New Images", for: .normal)
        collectionViewActionButton.backgroundColor = UIColor.blue
        collectionViewActionButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    //MARK: UI Alert Configuration
    func displayUIAlert(with message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
