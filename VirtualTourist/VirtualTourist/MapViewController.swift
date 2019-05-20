//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Darko Kulakov on 2019-05-20.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension MapViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let region = mapView.region
        print("latitude: \(region.center.latitude), longitude: \(region.center.longitude), latitudeDelta: \(region.span.latitudeDelta), longitudeDelta: \(region.span.longitudeDelta)")
    }
}
