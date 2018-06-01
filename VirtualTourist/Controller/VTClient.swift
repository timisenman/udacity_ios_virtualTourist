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
    
    func getImagesFrom(lat: Double, long: Double, pageNumber: Int, perPage: Int?, completionHandler: @escaping(_ data: [[String:AnyObject]]?, _ success: Bool?, _ errorString: String?) -> Void) {
        
        let url = URL(string: "https://api.flickr.com/services/rest?method=flickr.photos.search&api_key=9f2d4591298eeedac39f2af636aebbc9&lat=\(lat)&lon=\(long)&extras=url_m&format=json&nojsoncallback=?&per_page=\(perPage ?? 21)&page=\(pageNumber)")
        
        let request = URLRequest(url: url!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completionHandler(nil, false, "Got yoself an error, bruh: \(error?.localizedDescription ?? "Some error")")
                return
            }
            
            guard let data = data else {
                completionHandler(nil, false, "Unable to download Flickr data.")
                return
            }

            var parsedResult: [String:AnyObject]!
            do {
                parsedResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
            }
            
            guard let photos = parsedResult["photos"] as? [String:AnyObject] else {
                completionHandler(nil, false, "Unable to access data from Flickr.")
                return
            }
            
            guard let photoDict = photos["photo"] as? [[String:AnyObject]] else {
                completionHandler(nil, false, "Unable to access the individual photos from Flickr.")
                return
            }
            
            completionHandler(photoDict, true, nil)
        }
        task.resume()
    }
}
