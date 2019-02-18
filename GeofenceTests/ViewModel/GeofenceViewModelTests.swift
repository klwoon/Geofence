//
//  GeofenceViewModelTests.swift
//  GeofenceTests
//
//  Created by Woon on 18/02/2019.
//  Copyright © 2019 Woon. All rights reserved.
//

import XCTest
@testable import Geofence

class GeofenceViewModelTests: XCTestCase {

    func testDataPersist() {
        let geoData = GeoData.mock()
        let viewModel = GeofenceViewModel(geoData: geoData)

        UserDefaults.standard.removeObject(forKey: Constant.geoDataKey)
        
        viewModel.saveGeoData()
        let data = viewModel.getGeoData()
        XCTAssertEqual(data?.id, geoData.id)
        XCTAssertEqual(data?.latitude, geoData.latitude)
        XCTAssertEqual(data?.longitude, geoData.longitude)
        XCTAssertEqual(data?.radius, geoData.radius)
        XCTAssertEqual(data?.ssid, geoData.ssid)
        
    }
}
