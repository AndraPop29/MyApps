//
//  ViewController.swift
//  Mapping
//
//  Created by Andra on 25/10/2017.
//  Copyright © 2017 servustech. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        annotationList.append(CustomPointAnnotation(imageName: "customPin", coordinate: CLLocationCoordinate2DMake(46.781874, 23.626368), title: "Panemar"))
        annotationList.append(CustomPointAnnotation(imageName: "customPin", coordinate: CLLocationCoordinate2DMake(46.783679, 23.624232), title: "Servus"))
        annotationList.append(CustomPointAnnotation(imageName: "customPin", coordinate: CLLocationCoordinate2DMake(46.781842, 23.625756), title: "BRD"))
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        determineCurrentLocation()
    }
    
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization() // prompt with permission(info.plist message)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let cpa = annotation as! CustomPointAnnotation
        annotationView?.image = UIImage(named:cpa.imageName)
        annotationView?.rightCalloutAccessoryView = getAnnotationButton()
        return annotationView
    }
    
    func getAnnotationButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .purple
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitle("0987837283", for: .normal)
        button.addTarget(self, action: #selector(callTapped(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func callTapped(sender: UIButton) {
        let stringUrl = "tel://"+(sender.titleLabel?.text)!+")"
        if let url = URL(string: stringUrl), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    var annotationList = [CustomPointAnnotation()]
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)) // which portion of the map to display

        mapView.setRegion(region, animated: true) // map view zooms into the region
        mapView.addAnnotation(annotationList[1])
        mapView.addAnnotation(annotationList[2])
        mapView.addAnnotation(annotationList[3])
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
}


