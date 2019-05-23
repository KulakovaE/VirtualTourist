//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Darko Kulakov on 2019-05-22.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import Foundation
import MapKit

class PinAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var pin: Pin
    
    init(coordinate: CLLocationCoordinate2D, pin: Pin) {
        self.coordinate = coordinate
        self.pin = pin
    }
}
