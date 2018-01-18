//
//  CustomPointAnnotation.swift
//  Mapping
//
//  Created by Andra on 26/10/2017.
//  Copyright © 2017 servustech. All rights reserved.
//

import Foundation
import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
    override init() {}
    
    init(imageName: String, coordinate: CLLocationCoordinate2D, title: String) {
        super.init()
        self.coordinate = coordinate
        self.title = title
        self.imageName = imageName
    }
}
