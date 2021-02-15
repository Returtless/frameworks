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
    let locationManager = LocationManager.instance
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var marker : GMSMarker? = nil
    var img : UIImage? = nil
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var lastButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
    }
    
    func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .bind { [weak self] location in
                guard let location = location else { return }
                self?.routePath?.add(location.coordinate)
                self?.route?.path = self?.routePath
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
                if self?.marker != nil {
                    self?.marker!.map = nil
                }
                self?.marker = GMSMarker(position: location.coordinate)
                if let image = self?.img {
                    self?.marker!.icon =  self?.drawImageWithProfilePic(pp: image, image: GMSMarker.markerImage(with: .red))
                }
                self?.marker!.map = self?.mapView
            }
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
        locationManager.stopUpdatingLocation()
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
        locationManager.startUpdatingLocation()
    }
}

extension MapViewController {
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(hideView(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showView(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func hideView(_ notification: Notification) {
        self.view.isHidden = true
    }
    @objc func showView(_ notification: Notification) {
        self.view.isHidden = false
    }
    
    func drawImageWithProfilePic(pp: UIImage, image: UIImage) -> UIImage {
        
        let imgView = UIImageView(image: image)
        let picImgView = UIImageView(image: pp)
        picImgView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        imgView.addSubview(picImgView)
        picImgView.center.x = imgView.center.x
        picImgView.center.y = imgView.center.y - 7
        picImgView.layer.cornerRadius = picImgView.frame.width/2
        picImgView.clipsToBounds = true
        imgView.setNeedsLayout()
        picImgView.setNeedsLayout()
        
        let newImage = imageWithView(view: imgView)
        return newImage
    }
    
    func imageWithView(view: UIView) -> UIImage {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image ?? UIImage()
    }
    
}
