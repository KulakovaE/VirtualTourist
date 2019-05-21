//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Darko Kulakov on 2019-05-20.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

let mapStateKey: String = "mapStateKey"

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    //var pins: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedRegion = UserDefaults.standard.loadMapState() {
            mapView.setRegion(savedRegion, animated: true)
        }
        
        let longPressGestureRecog = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        longPressGestureRecog.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGestureRecog)
    }
    
@objc func addAnnotation(press: UILongPressGestureRecognizer) {
    if press.state == .began {
        let location = press.location(in: mapView)
        let coordinates = mapView.convert(location, toCoordinateFrom: mapView)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        UserDefaults.standard.saveMapState(region: mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView {
            return pinView
        } else {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView.canShowCallout = false
            pinView.animatesDrop = true
            return pinView
        }
    }
}

extension UserDefaults {
    func saveMapState(region: MKCoordinateRegion) {
        let mapState = MapState(longitude: region.center.longitude, latitude: region.center.latitude, longitudeDelta: region.span.longitudeDelta, latitudeDelta: region.span.latitudeDelta)
        if let encodedMapState = try? JSONEncoder().encode(mapState) {
            UserDefaults.standard.set(encodedMapState, forKey: mapStateKey)
        }
    }
    
    func loadMapState() -> MKCoordinateRegion? {
        if let mapStateData = UserDefaults.standard.data(forKey: mapStateKey) {
            if let mapState = try? JSONDecoder().decode(MapState.self, from: mapStateData) {
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: mapState.latitude, longitude: mapState.longitude), span: MKCoordinateSpan(latitudeDelta: mapState.latitudeDelta, longitudeDelta: mapState.longitudeDelta))
            }
        }
        return nil
    }
}

