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

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureGestureRecognizer()
    }
    
    func configureMap() {
        mapView.delegate = self
        let location = CLLocationCoordinate2DMake(35.6895, 139.6917)
        let mapSpan = MKCoordinateSpanMake(25.0, 25.0)
        let region = MKCoordinateRegionMake(location, mapSpan)
        self.mapView.setRegion(region, animated: true)
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
        print("Pin tapped.")
        let reuseId = "pin"
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if control == view.rightCalloutAccessoryView {
            print("Control tapped.")
            storyBoardSegue()
        }
    }
    
    //MARK: Gesture Recognition Functions
    @objc func addMapAnnotation(press: UILongPressGestureRecognizer) {
        if press.state == .began {
            let location = press.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = "Lat/Long:"
            annotation.subtitle = "\(annotation.coordinate.latitude)\n\(annotation.coordinate.longitude)"
            
            mapView.addAnnotation(annotation)
        }
    }
    
    func configureGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addMapAnnotation(press:)))
        gesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(gesture)
    }
    

}

extension MapViewController {
    func storyBoardSegue() {
        performSegue(withIdentifier: Constants.StoryboardIDs.SegueID, sender: self)
        print("Segue performed.")
    }
}
