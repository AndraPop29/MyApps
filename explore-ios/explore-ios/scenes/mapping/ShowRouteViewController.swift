//
//  ShowRouteViewController.swift
//  Mapping
//
//  Created by Andra on 30/10/2017.
//  Copyright © 2017 servustech. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ShowRouteViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Mapping"

        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsUserLocation = true
        mapView.showsTraffic = true
        addressTextField.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    var destCoordinate: CLLocationCoordinate2D? {
        didSet {
            showRoute()
        }
    }
    func showRoute() {
            let sourceCoordinate = self.locationManager.location?.coordinate
            let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate!)
            if let destination = self.destCoordinate {
                let destPlacemark = MKPlacemark(coordinate: destination)
                let sourceItem = MKMapItem(placemark: sourcePlacemark)
                let destItem = MKMapItem(placemark: destPlacemark)
                
                let directionRequest = MKDirectionsRequest()
                directionRequest.source = sourceItem
                directionRequest.destination = destItem
                directionRequest.transportType = .automobile
                
                let directions = MKDirections(request: directionRequest)
                directions.calculate(completionHandler: {
                    response, error in
                    guard let response = response else {
                        if error != nil {
                            print("Something went wrong, can't generate route")
                        }
                        return
                    }
                    let route = response.routes[0]
                    self.mapView.add(route.polyline, level: .aboveRoads)
                    
                    let rekt = route.polyline.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
                })
            }
        
    }
    func searchForLocation(locationName: String, completion: @escaping (CLLocationCoordinate2D?) -> ()) {
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = locationName
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            if localSearchResponse == nil{
                let geoCoder = CLGeocoder()
                
                geoCoder.geocodeAddressString(locationName) { (placemarks, error) in
                    guard
                            let placemarks = placemarks,
                            let location = placemarks.first?.location
                       else {
                            let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            return
                    }
                    completion(location.coordinate)
                }
            }
            completion(localSearchResponse?.mapItems[0].placemark.coordinate)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        searchForLocation(locationName: addressTextField.text!, completion: {
            coord in
            self.destCoordinate = coord
        })
        textField.resignFirstResponder()
        return true
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
