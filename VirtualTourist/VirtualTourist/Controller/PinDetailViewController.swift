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
    @IBOutlet var collectionView: UICollectionView!
    var pinAnnotation: PinAnnotation?
    let spinner = SpinnerViewController()
    
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
   
    @IBAction func getNewCollection(_ sender: Any) {
        guard let pinAnnotation = pinAnnotation else { return }
        showSpinner()
        NetworkClient.searchPhotosFor(latitude: pinAnnotation.coordinate.latitude, longitude: pinAnnotation.coordinate.longitude) { (response, error) in
            if response.count > 0 {
                if let currentImages = pinAnnotation.pin.images {
                    pinAnnotation.pin.removeFromImages(currentImages)
                    try? DataController.shared.viewContext.save()
                }
            
                for imageUrl in response {
                    let photo = Photo(context: DataController.shared.viewContext)
                    photo.imageUrl = imageUrl
                    
                    
                    if let imageData = try? Data(contentsOf: imageUrl) {
                        photo.image = imageData
                        pinAnnotation.pin.addToImages(photo)
                        try? DataController.shared.viewContext.save()
                    }
                }
                
                self.pinAnnotation = pinAnnotation
                
                DispatchQueue.main.async {
                    self.hideSpinner()
                    self.collectionView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.hideSpinner()
                    self.showAlert(title: "Sorry", message: "No images were found for this location or something went wrong.")
                }
            }
        }
        
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
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
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
        return pinAnnotation?.pin.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell, let pinAnnotation = pinAnnotation else {
            fatalError("Unable to dequeue PhotoCollectionViewCell.")
        }
        if let imageData = pinAnnotation.pin.images?.allObjects[indexPath.row] as? Data, let image = UIImage(data: imageData) {
           cell.imageView.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        <#code#>
    }
    
    
}
