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
    }
    
    func configureMap() {
        let location = CLLocationCoordinate2DMake(37.00, -120.00)
        let mapSpan = MKCoordinateSpanMake(25.0, 25.0)
        let region = MKCoordinateRegionMake(location, mapSpan)
        self.mapView.setRegion(region, animated: true)
        
    }
    

}

