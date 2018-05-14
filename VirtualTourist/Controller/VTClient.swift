//
//  VTClient.swift
//  VirtualTourist
//
//  Created by Timothy Isenman on 5/4/18.
//  Copyright © 2018 Timothy Isenman. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VTClient: NSObject {
    
    static let shared = VTClient()
    
    override init() {
        super.init()
    }
    
    func getFromLatLong(/*lat: Float, lon: Float,*/ completionHandler: @escaping(_ data: [String], _ success: Bool, _ errorString: String?) -> Void) {
        var urlArray: [String] = [String]()
        let url = URL(string: "https://api.flickr.com/services/rest?method=flickr.photos.search&api_key=9f2d4591298eeedac39f2af636aebbc9&lat=35.708145&lon=139.732445&extras=url_m&format=json&nojsoncallback=?&per_page=25")
        let request = URLRequest(url: url!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Got yoself an error, bruh: \(error?.localizedDescription ?? "Some error")")
                return
            }
            
            guard let data = data else {
                print("Data says to fuck yourself.")
                return
            }

            var parsedResult: [String:AnyObject]!
            do {
                parsedResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
            }
            
            guard let photos = parsedResult["photos"] as? [String:AnyObject] else {
                print("No photos, hoe.")
                return
            }
            
            guard let photoDict = photos["photo"] as? [[String:AnyObject]] else {
                print("No photo, hoe.")
                return
            }
            
            for photo in photoDict {
                if let imageUrl = photo["url_m"] as? String {
                    DispatchQueue.main.sync {
                        urlArray.append(imageUrl)
//                        locationImages.shared.imageArray.append(imageUrl)
                    }
                }
            }
            completionHandler(urlArray, true, "Try these images")
//            print("Image count after parsing: \(locationImages.shared.imageArray.count)")
            
        }
        task.resume()
    }
}
