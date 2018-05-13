//
//  StoredData.swift
//  VirtualTourist
//
//  Created by Timothy Isenman on 5/4/18.
//  Copyright © 2018 Timothy Isenman. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class locationImages {
    static let shared = locationImages()
    var imageArray: [String] = [String]()
}

class mapLocations {
    static let shared = mapLocations()
    var pins: [MKAnnotation] = [MKAnnotation]()
    
}

