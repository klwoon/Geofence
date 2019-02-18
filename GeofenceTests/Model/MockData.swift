//
//  MockData.swift
//  GeofenceTests
//
//  Created by Woon on 19/02/2019.
//  Copyright © 2019 Woon. All rights reserved.
//

import Foundation
@testable import Geofence

struct MockData {
    static let id = 123
    static let latitude = 3.140543
    static let longitude = 101.695231
    static let radius = 500
    static let ssid = "Test Wifi"
}

extension GeoData {

    static func mock(with id: Int = MockData.id,
                     latitude: Double = MockData.latitude,
                     longitude: Double = MockData.longitude,
                     radius: Int = MockData.radius,
                     ssid: String = MockData.ssid) -> GeoData {
        return GeoData(id: id,
                       latitude: latitude,
                       longitude: longitude,
                       radius: radius,
                       ssid: ssid)
    }
}
