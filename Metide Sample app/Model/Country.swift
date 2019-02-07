//
//  Country.swift
//  Metide Sample app
//
//  Created by Umberto Cerrato on 04/02/2019.
//  Copyright © 2019 Umberto Cerrato. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public class Country: NSManagedObject {
    
    // MARK: - Core Data Managed Object
    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var officialName: String?
    @NSManaged var flag: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var zoom: String?
    @NSManaged var note: Note?
    
    /// The Country location from its latitude and longitude values.
    var location: CLLocation {
        let loc = CLLocation(latitude: Double(latitude ?? "0.0") ?? 0.0, longitude: Double(longitude ?? "0.0") ?? 0.0)
        return loc
    }
    
    /// Reads each key-value pair in the JSON dictionary and update the _Country_ class Core Data variables in it.
    ///
    /// - Parameter jsonDictionary: the JSON as _[String: Any]_ dictionary.
    /// - Throws: NSError
    func update(with jsonDictionary: [String: Any]) throws {
        guard let id = jsonDictionary["id"] as? String,
            let name = jsonDictionary["name"] as? String,
            let officialName = jsonDictionary["name_official"] as? String,
            let flag = jsonDictionary["flag"] as? String,
            let latitude = jsonDictionary["latitude"] as? String,
            let longitude = jsonDictionary["longitude"] as? String,
            let zoom = jsonDictionary["zoom"] as? String
            else {
                throw NSError(domain: "", code: 100, userInfo: nil)
        }
        
        self.id = id
        self.name = name
        self.officialName = officialName
        self.flag = flag
        self.latitude = latitude
        self.longitude = longitude
        self.zoom = zoom
    }
    
    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
    }
}
