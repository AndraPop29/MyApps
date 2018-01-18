//
//  User.swift
//  explore-ios
//
//  Created by Andra on 04/01/2018.
//  Copyright © 2018 andrapop. All rights reserved.
//

import Foundation
import Firebase

class User {
    var Id: String?
    var email: String
    var role: String
    var ratings: [String: Int]?
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        Id = snapshot.key
        email = snapshotValue["email"] as! String
        role = snapshotValue["role"] as! String
    }
    
    init(email: String, role: String) {
        self.email = email
        self.role = role
    }
    
    func toAnyObject() -> Any {
        return [
            "email": email,
            "role": role,
        ]
    }
    

}
