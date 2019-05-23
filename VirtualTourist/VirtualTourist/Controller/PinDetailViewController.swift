//
//  PinDetailViewController.swift
//  VirtualTourist
//
//  Created by Darko Kulakov on 2019-05-22.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit
import MapKit

class PinDetailViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    var pinAnnotation: PinAnnotation?
    var imageUrls: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let pinAnnotation = pinAnnotation {
            mapView.addAnnotation(pinAnnotation)
            let region = MKCoordinateRegion(center: pinAnnotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
}

extension PinDetailViewController: MKMapViewDelegate {
    
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

extension PinDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else {
           
            fatalError("Unable to dequeue PhotoCollectionViewCell.")
        }
        //TO DO: cell.imageView
        return cell
    }
    
    
}
