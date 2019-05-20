//
//  MapState.swift
//  VirtualTourist
//
//  Created by Darko Kulakov on 2019-05-20.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import Foundation

struct MapState: Codable {
    var longitude: Double
    var latitude: Double
    var longitudeDelta: Double
    var latitudeDelta: Double
}
