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
    var pins: [Pin] = []
    let spinner = SpinnerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedRegion = UserDefaults.standard.loadMapState() {
            mapView.setRegion(savedRegion, animated: true)
        }
        
        let longPressGestureRecog = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        longPressGestureRecog.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGestureRecog)
        
        self.pins = fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayData(pins: self.pins)
        
    }
    
    func fetchData() -> [Pin] {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? DataController.shared.viewContext.fetch(fetchRequest) {
            return result
        } else {
            return []
        }
    }
    
    func saveData(annotation: MKPointAnnotation) {
        let pin = Pin(context: DataController.shared.viewContext)
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        self.pins.insert(pin, at: 0)
        try? DataController.shared.viewContext.save()
    }
    
    func displayData(pins: [Pin]) {
        let annotations = pins.map { pin -> PinAnnotation in
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            let annotation = PinAnnotation(coordinate: coordinate, pin: pin)
            return annotation
        }
        
        let currentAnnotations = mapView.annotations
        mapView.removeAnnotations(currentAnnotations)
        mapView.addAnnotations(annotations)
    }
    
    @objc func addAnnotation(press: UILongPressGestureRecognizer) {
        if press.state == .began {
            let location = press.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let newPin = Pin(context: DataController.shared.viewContext)
            newPin.latitude = coordinate.latitude
            newPin.longitude = coordinate.longitude
            
            if let _ = try? DataController.shared.viewContext.save() {
                self.pins.append(newPin)
                let annotation = PinAnnotation(coordinate: coordinate, pin: newPin)
                mapView.addAnnotation(annotation)
            } else {
                //TO DO: show Error Message
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func showSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    
    func hideSpinner(){
        DispatchQueue.main.async {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pinAnnotation = view.annotation as? PinAnnotation,
            let pinDetailViewController = storyboard?.instantiateViewController(withIdentifier: "PinDetailViewController") as? PinDetailViewController {
            
            if let images = pinAnnotation.pin.images, images.count > 0 {
                pinDetailViewController.pinAnnotation = pinAnnotation
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(pinDetailViewController, animated: true)
                }
                return
            }
             DispatchQueue.main.async {
                self.showSpinner()
            }
            NetworkClient.searchPhotosFor(latitude: pinAnnotation.coordinate.latitude, longitude: pinAnnotation.coordinate.longitude) { (response, error) in
                if response.count > 0 {
                    for imageUrl in response {
                        let photo = Photo(context: DataController.shared.viewContext)
                        photo.imageUrl = imageUrl
                        
                        
                        if let imageData = try? Data(contentsOf: imageUrl)  {
                            photo.image = imageData
                            pinAnnotation.pin.addToImages(photo)
                            try? DataController.shared.viewContext.save()
                        }
                    }
                    
                    pinDetailViewController.pinAnnotation = pinAnnotation
                    
                    DispatchQueue.main.async {
                        self.hideSpinner()
                        self.navigationController?.pushViewController(pinDetailViewController, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.hideSpinner()
                        self.showAlert(title: "Sorry", message: "No images were found for this location or something went wrong.")
                    }
                }
            }
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

