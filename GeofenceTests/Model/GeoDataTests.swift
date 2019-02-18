//
//  GeoDataTests.swift
//  GeofenceTests
//
//  Created by Woon on 18/02/2019.
//  Copyright © 2019 Woon. All rights reserved.
//

import XCTest
@testable import Geofence

class GeoDataTests: XCTestCase {

    func testGeoDataInit() {
        
        let id = 123
        let latitude = 3.140543
        let longitude = 101.695231
        let radius = 500
        let ssid = "Test Wifi"
        
        let object = GeoData(id: id, latitude: latitude, longitude: longitude, radius: radius, ssid: ssid)
        
        XCTAssertEqual(object.id, id)
        XCTAssertEqual(object.latitude, latitude)
        XCTAssertEqual(object.longitude, longitude)
        XCTAssertEqual(object.radius, radius)
        XCTAssertEqual(object.ssid, ssid)
        
    }


}
