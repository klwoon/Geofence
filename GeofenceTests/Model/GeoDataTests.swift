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
        
        let object = GeoData.mock()
        
        XCTAssertEqual(object.id, MockData.id)
        XCTAssertEqual(object.latitude, MockData.latitude)
        XCTAssertEqual(object.longitude, MockData.longitude)
        XCTAssertEqual(object.radius, MockData.radius)
        XCTAssertEqual(object.ssid, MockData.ssid)
        
    }


}
