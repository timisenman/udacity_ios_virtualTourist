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
    
    func getImagesFrom(lat: Double, long: Double, pageNumber: Int, perPage: Int?, completionHandler: @escaping(_ data: [[String:AnyObject]], _ success: Bool, _ errorString: String?) -> Void) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest/"
        
        let method = URLQueryItem(name: "method", value: "flickr.photos.search")
        let apiKey = URLQueryItem(name: "api_key", value: "9f2d4591298eeedac39f2af636aebbc9")
        let queryLat = URLQueryItem(name: "lat", value: "\(lat)")
        let queryLong = URLQueryItem(name: "lon", value: "\(long)")
        let extras = URLQueryItem(name: "extras", value: "url_m")
        let format = URLQueryItem(name: "format", value: "json")
        let callBack = URLQueryItem(name: "nojsoncallback", value: "?")
        let itemsPerPage = URLQueryItem(name: "per_page", value: "\(perPage ?? 21)")
        let page = URLQueryItem(name: "page", value: "\(pageNumber)")
        
        components.queryItems = [method, apiKey, queryLat, queryLong, extras, format, callBack, itemsPerPage, page]
        
        let url = components.url
        
        let request = URLRequest(url: url!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Got yoself an error, bruh: \(error?.localizedDescription ?? "Some error")")
                return
            }
            
            guard let data = data else {
                print("Unable to download Flickr data.")
                return
            }

            var parsedResult: [String:AnyObject]!
            do {
                parsedResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
            }
            
            guard let photos = parsedResult["photos"] as? [String:AnyObject] else {
                print("Unable to access data from Flickr.")
                return
            }
            
            guard let photoDict = photos["photo"] as? [[String:AnyObject]] else {
                print("Unable to access the individual photos from Flickr.")
                return
            }
            
            completionHandler(photoDict, true, nil)
        }
        task.resume()
    }
}
