//
//  MapViewController.swift
//  frameworks
//
//  Created by Владислав Лихачев on 14.01.2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import Realm
import RealmSwift
class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager: CLLocationManager?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var lastButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.distanceFilter = 100.0;
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startMonitoringSignificantLocationChanges()
        
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestAlwaysAuthorization()
    }
    
    @IBAction func stopButtonWasTapped(_ sender: UIBarButtonItem) {
        var arr : [CoordsModel]  = []
        for i in 0..<(routePath!.count() ) {
            let model = CoordsModel()
            model.lat = routePath?.coordinate(at: i).latitude.description
            model.long = routePath?.coordinate(at: i).longitude.description
            arr.append(model)
        }
        RealmService.saveDataToRealm(arr)
        locationManager?.stopUpdatingLocation()
    }
    
    @IBAction func lastRouteButtonWasTapped(_ sender: UIBarButtonItem) {
        let coords : [CoordsModel] = RealmService.getDataFromRealm()
        routePath = GMSMutablePath()
        coords.forEach(
            {
                i in
                if let lat = Double(i.lat!), let long = Double(i.long!) {
                    let c = CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(long))
                    routePath?.add(c)
                }
                
            }
        )
        route?.path = routePath
        let position = GMSCameraPosition.camera(withTarget: routePath!.coordinate(at: routePath!.count()-1), zoom: 17)
        mapView.animate(to: position)
    }
    
    @IBAction func addButtonWasTapped(_ sender: UIBarButtonItem) {
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        locationManager?.startUpdatingLocation()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        routePath?.add(location.coordinate)
        route?.path = routePath
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        mapView.animate(to: position)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
}
