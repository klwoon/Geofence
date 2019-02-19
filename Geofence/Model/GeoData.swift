//
//  GeoData.swift
//  Geofence
//
//  Created by Woon on 18/02/2019.
//  Copyright © 2019 Woon. All rights reserved.
//

import Foundation
import MapKit

class GeoData: NSObject, Codable, MKAnnotation {
    var id: Int = 0
    var latitude: Double
    var longitude: Double
    var radius: Double
    var ssid: String
    
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    
    enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case radius
        case ssid
    }

    init(id: Int, latitude: Double, longitude: Double, radius: Double, ssid: String) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.ssid = ssid
        
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }  
    
}
