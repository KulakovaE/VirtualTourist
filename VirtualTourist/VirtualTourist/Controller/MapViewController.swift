//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Darko Kulakov on 2019-05-20.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit
import MapKit

let mapStateKey: String = "mapStateKey"

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedRegion = UserDefaults.standard.loadMapState() {
            mapView.setRegion(savedRegion, animated: true)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        UserDefaults.standard.saveMapState(region: mapView.region)
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
