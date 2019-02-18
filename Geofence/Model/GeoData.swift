//
//  GeoData.swift
//  Geofence
//
//  Created by Woon on 18/02/2019.
//  Copyright © 2019 Woon. All rights reserved.
//

import Foundation

struct GeoData {
    var id: Int = 0
    var latitude: Double
    var longitude: Double
    var radius: Int
    var ssid: String
    
    init(id: Int, latitude: Double, longitude: Double, radius: Int, ssid: String) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.ssid = ssid
    }
}

