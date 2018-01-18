//
//  UserDataManager.swift
//  explore-ios
//
//  Created by Andra on 04/01/2018.
//  Copyright © 2018 andrapop. All rights reserved.
//

import Foundation
import FirebaseDatabase
import PromiseKit

class UserDataManager {
    static let shared = UserDataManager()
    private init () {}
    private let firDatabaseReference = Database.database().reference()
    
    func retrieve(withEmail email : String) -> Promise<(User?)>{
        return Promise{ fulfill, reject in
            
            let query = firDatabaseReference.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email)
            
            query.observeSingleEvent(of: .value, with: {
                snapshot in
                
                if snapshot.children.allObjects.count == 1,
                    let userSnapshot = snapshot.children.allObjects.first as? DataSnapshot {
                        let user = User(snapshot: userSnapshot)
                        return fulfill(user)
                    }
                
                return fulfill(nil)
                
            }, withCancel: {
                error in
                return reject(error)
            })
        }
    }
    
    func getRatingFor(attractionId: String) -> Promise<Int?> { // rating given by current user
        return Promise{
            fulfill, reject in
            
            let query = firDatabaseReference.child("users").child(UserDefaults.standard.string(forKey: "userId")!).child("ratings").child(attractionId)
            
            query.observeSingleEvent(of: .value, with: {
                snapshot in
                if let rating = snapshot.value as? Int {
                   // let rating = snapshot.value as! Int
                    return fulfill(rating)
                }
                return fulfill(nil)
                
            }, withCancel: {
                error in
                return reject(error)
            })
        }
    }
    
    func calculateRatingAverage() -> Promise<[TouristAttraction]>{
        return Promise {
            fulfill, reject in
            for attr in TouristAttractions.shared.attractionsList {
                // var newAttr = attr
                attr.ratingAverage = 0.0
                TouristAttractions.shared.updateAttraction(withId: attr.Id!, attraction: attr)
                
            }
            firDatabaseReference.child("users").observeSingleEvent(of: .value, with: {
                snapshot in
                
                for item in snapshot.children {
                    guard let value = item as? DataSnapshot else{
                        assertionFailure()
                        return
                    }
                    guard let snapValue = value.value as? NSDictionary else{
                        assertionFailure()
                        return
                    }
                    guard let ratings = snapValue["ratings"] as? NSDictionary else {
                        assertionFailure()
                        return
                    }
                    for (key, value) in ratings {
                        if let intVal = value as? Int {
                            if intVal != 0 {
                                TouristAttractions.shared.rateAttraction(withId: key as! String, with: Double(intVal))
                            }
                        }
                    }
                    
                }
                fulfill(TouristAttractions.shared.getTop5Attractions())
                
            })
           
        }
       
    }
    
    func updateRatings(for userId: String, ratings: [String: Int], completion: @escaping (Error?) -> Void = {_ in }){
        Database.database().reference().child("users").child(UserDefaults.standard.string(forKey: "userId")!).child("ratings").updateChildValues(ratings){
            error, reference in
            
            completion(error)
        }
    }
}

