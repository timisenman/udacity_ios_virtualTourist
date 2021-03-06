//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Timothy Isenman on 5/4/18.
//  Copyright © 2018 Timothy Isenman. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    
    var dataController: DataController!
    var mapPins: [LocationPin] = [LocationPin]()
    var fetchedResultsController: NSFetchedResultsController<LocationPin>!
    
    var pinTappedToView: LocationPin?
    
    var editState: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //View Configuration
        navigationBar.title = "Press to Add A Pin"
        configureMap()
        configureGestureRecognizer()
        
        //Access user's data
        fetchSavedPins()
    }
    
    //MARK: User Experience
    @objc func addMapAnnotation(press: UILongPressGestureRecognizer) {
        if press.state == .began {
            let location = press.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            
            let mapPin = LocationPin(context: dataController.viewContext)
            mapPin.creationDate = Date()
            mapPin.latitude = coordinates.latitude
            mapPin.longitude = coordinates.longitude
            
            annotation.coordinate = coordinates
            getLocationName(annotation.coordinate) { (locationName) in
                annotation.title = locationName
                mapPin.cityName = locationName
            }
            
            mapView.addAnnotation(annotation)
            mapPins.append(mapPin)
            try? dataController.viewContext.save()
        }
    }
    
    @IBAction func removePins(_ sender: Any) {
        //Toggle the UI during Map editing
        changeEditState()
    }
    
    //MARK: Edit State Configuration
    func changeEditState() {
        editState = !editState
        
        if editState == true {
            editPinsButton.title = "Done"
            navigationBar.title = "Tap To Remove"
        } else {
            editPinsButton.title = "Edit"
            navigationBar.title = "Press to Add A Pin"
        }
    }
    
    //MARK: Core Data Protocols
    fileprivate func fetchSavedPins() {
        let fetchRequest: NSFetchRequest<LocationPin> = LocationPin.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptors]
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            mapPins = results
        }
        
        var savedPins: [MKPointAnnotation] = [MKPointAnnotation]()
        for pin in mapPins {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = pin.cityName
            savedPins.append(annotation)
        }
       self.mapView.addAnnotations(savedPins)
    }
    
    //MARK: Map View Protocols
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let reuseId = "pin"
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        //When a user presses the "Edit" button, the result of tapping a Pin's callout changes
        if editState {
            for pin in mapPins {
                if pin.latitude == view.annotation?.coordinate.latitude {
                    mapView.removeAnnotation(view.annotation!)
                    mapPins.remove(at: mapPins.index(of: pin)!)
                    dataController.viewContext.delete(pin)
                    try? dataController.viewContext.save()
                }
            }
        } else {
            if control == view.rightCalloutAccessoryView {
                for pin in mapPins {
                    if pin.latitude == view.annotation?.coordinate.latitude {
                        pinTappedToView = pin
                    }
                }
                try? dataController.viewContext.save()
                self.performSegue(withIdentifier: Constants.StoryboardIDs.SegueID, sender: self)
            }
        }
    }
    
    //MARK: Callout Display Logic
    func getLocationName(_ location: CLLocationCoordinate2D, completionHandler: @escaping(_ locationName: String?) -> Void) {
        let geocoder = CLGeocoder()
        let mapLat: CLLocationDegrees = location.latitude
        let mapLong: CLLocationDegrees = location.longitude
        let newLocation = CLLocation(latitude: mapLat, longitude: mapLong)
        
        //Get the city name of a location
        geocoder.reverseGeocodeLocation(newLocation) { (placemark, error) in
            if error == nil {
                if let newLocationString = placemark?[0] {
                    //If no Locality or Country exist, show "Unknown"
                    completionHandler("\(newLocationString.locality ?? "Unknown"), \(newLocationString.country ?? "Unknown")")
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    
    //MARK: General Configurations
    func configureMap() {
        mapView.delegate = self
        let location = CLLocationCoordinate2DMake(35.6895, 139.6917)
        let mapSpan = MKCoordinateSpanMake(25.0, 25.0)
        let region = MKCoordinateRegionMake(location, mapSpan)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    func configureGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addMapAnnotation(press:)))
        gesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(gesture)
    }
}

extension MapViewController {
    //Send the selected Pin to the Photo Collection View Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let locationView = segue.destination as? LocationCollectionViewController {
            locationView.dataController = dataController
            locationView.tappedPin = pinTappedToView
            try? dataController.viewContext.save()
        }
    }
}
