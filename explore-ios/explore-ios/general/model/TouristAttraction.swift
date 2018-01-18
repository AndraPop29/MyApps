//
//  TouristAttraction.swift
//  explore-ios
//
//  Created by Andra on 08/11/2017.
//  Copyright © 2017 andrapop. All rights reserved.
//

import Foundation
import UIKit
import os.log
import Firebase

//MARK: Types

struct PropertyKey {
    static let id = "id"
    static let name = "name"
    static let country = "country"
    static let city = "city"
    static let image = "image"
    static let ratingAverage = "ratingAverage"
}

class TouristAttraction: NSObject, NSCoding {
 
    var Id: String?
    var name: String
    var country: String
    var city: String
    var image: UIImage?
    var ratingAverage:Double = 0
    let ref: DatabaseReference?
    
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        Id = snapshot.key
        name = snapshotValue["name"] as! String
        country = snapshotValue["country"] as! String
        city = snapshotValue["city"] as! String
        ratingAverage = snapshotValue["ratingAverage"] as! Double
        ref = snapshot.ref
    }
    
    init(id:String?, name: String, country: String, city: String, image: UIImage?, average: Double?) {
        self.Id = id
        self.name = name
        self.country = country
        self.city = city
        self.image = image
        self.ratingAverage = average != nil ? average! : 0.0
        self.ref = nil
    }
    
    init(name: String, country: String, city: String, image: UIImage?) {
        self.name = name
        self.country = country
        self.city = city
        self.image = image
        self.ref = nil
    }
    
    init(name: String, country: String, city: String) {
        self.name = name
        self.country = country
        self.city = city
        self.ref = nil
    }
    
    func rateTouristAttraction(number: Double) {
        if self.ratingAverage != 0 {
            self.ratingAverage = (self.ratingAverage + number)/2
        } else {
            self.ratingAverage = number
        }
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Id, forKey: PropertyKey.id)
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(country, forKey: PropertyKey.country)
        aCoder.encode(city, forKey: PropertyKey.city)
        aCoder.encode(image, forKey: PropertyKey.image)
        aCoder.encode(ratingAverage, forKey: PropertyKey.ratingAverage)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let decodedName = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a attraction object.", log: OSLog.default, type: .debug)
            return nil
        }
        let decodedId = aDecoder.decodeObject(forKey: PropertyKey.id) as? String
        let decodedCountry = aDecoder.decodeObject(forKey: PropertyKey.country) as! String
        let decodedCity = aDecoder.decodeObject(forKey: PropertyKey.city) as! String
        let decodedImage = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage
        let decodedAverage = aDecoder.decodeDouble(forKey:  PropertyKey.ratingAverage)
        self.init(id: decodedId, name: decodedName, country: decodedCountry, city: decodedCity, image: decodedImage, average: decodedAverage)

    }
    
    func toAnyObject() -> Any {
        return [
            "id": Id,
            "name": name,
            "country": country,
            "city": city,
            "ratingAverage": ratingAverage
        ]
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("attractions")

}
