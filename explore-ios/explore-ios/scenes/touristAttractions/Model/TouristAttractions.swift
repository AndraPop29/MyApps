//
//  TouristAttractions.swift
//  explore-ios
//
//  Created by Andra Pop on 2017-11-13.
//  Copyright © 2017 andrapop. All rights reserved.
//

import Foundation
import os.log
import FirebaseDatabase
import PromiseKit

class TouristAttractions {
    var attractionsList = [TouristAttraction]()
    static let shared = TouristAttractions()
    let ref = Database.database().reference()
    private init(){}
    func getCountries() -> [String] {
        return Array(Set(attractionsList.map {$0.country}));
    }
    func getAttractions(fromCountry country: String) -> [TouristAttraction] {
        return attractionsList.filter ({ return $0.country == country})
    }
    func updateAttraction(withId id: String, attraction: TouristAttraction) {
//        if let i = attractionsList.index(where: { $0.Id == id}) {
//            attractionsList[i] = attraction
//        }
        let attr = attraction.toAnyObject()
        ref.child("touristAttractions").child(id).setValue(attr)
    }
    func addAttraction(attraction: TouristAttraction) {
        let key = ref.child("touristAttractions").childByAutoId().key
        attraction.Id = key
        let databaseRef = Database.database().reference(withPath: "touristAttractions")
    
        let touristAttrRef = databaseRef.child(String(describing: attraction.Id!))
        touristAttrRef.setValue(attraction.toAnyObject())
    }
    func saveAttractions() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(attractionsList, toFile:TouristAttraction.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Attractions successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save attractions...", log: OSLog.default, type: .error)
        }
    }
    func loadAttractionsFromFirebase() -> Promise<[TouristAttraction]>{
        return Promise { fulfill, reject in
            ref.child("touristAttractions").observeSingleEvent(of: .value, with: { (snapshot) in
                var newItems: [TouristAttraction] = []
                for item in snapshot.children {
                    let attr = TouristAttraction(snapshot: item as! DataSnapshot)
                    newItems.append(attr)
                }
                fulfill(newItems)
                self.attractionsList = newItems
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
       
    }
    func loadAttractions() -> [TouristAttraction]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: TouristAttraction.ArchiveURL.path) as? [TouristAttraction]
    }
    
    func getTop5Attractions() -> Array<TouristAttraction> {
        let sortedAttractions = attractionsList.sorted(by: {lhs, rhs in
            return lhs.ratingAverage > rhs.ratingAverage
        })
        if(sortedAttractions.count <= 5) {
            return Array(sortedAttractions.prefix(sortedAttractions.count)).filter({$0.ratingAverage != 0})
        } else {
            return Array(sortedAttractions.prefix(5)).filter({$0.ratingAverage != 0})
        }
        
    }
    func remove(attraction: TouristAttraction) {
        attraction.ref?.removeValue()
    }
    func removeBy(id: String) {
        var i = 0
        while(i<attractionsList.count) {
            if attractionsList[i].Id == id {
                attractionsList.remove(at: i)
            }
            i = i+1
        }
    }
    func getAttr(withId id: String) -> TouristAttraction {
        return attractionsList.filter { $0.Id! == id }.first!
    }
    func rateAttraction(withId id: String, with rating: Double) {
        if let i = attractionsList.index(where: { $0.Id == id}) {
            attractionsList[i].rateTouristAttraction(number: rating)
            ref.child("touristAttractions").child(id).setValue(attractionsList[i].toAnyObject())
        }
    }
    func rateAttraction(named name: String, with rating: Double) {
        if let i = attractionsList.index(where: { $0.name ==  name}) {
            attractionsList[i].rateTouristAttraction(number: rating)
        }
    }
}
