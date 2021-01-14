//
//  MapViewController.swift
//  frameworks
//
//  Created by Владислав Лихачев on 14.01.2021.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager: CLLocationManager?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationManager()
        locationManager?.startUpdatingLocation()
        
    }
    
    func configureLocationManager() {
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.distanceFilter = 100.0;
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager?.requestWhenInUseAuthorization()
    }
    
    
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        mapView.camera = camera
        
        let marker = GMSMarker(position: location.coordinate)
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.map = mapView
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
}
