//
//  GeofenceViewModelTests.swift
//  GeofenceTests
//
//  Created by Woon on 18/02/2019.
//  Copyright © 2019 Woon. All rights reserved.
//

import XCTest
@testable import Geofence
import RxSwift
import RxCocoa

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
    
    func testGeofenceObservable() {
        let bag = DisposeBag()
        let mock = GeoData.mock()
        
        let latitude = BehaviorRelay<Double>(value: 0)
        let longitude = BehaviorRelay<Double>(value: 0)
        let radius = BehaviorRelay<Double>(value: 0)
        let ssid = BehaviorRelay<String>(value: "")
        
        let viewModel = GeofenceViewModel(input: (latitude: latitude,
                                                  longitude: longitude,
                                                  radius: radius,
                                                  ssid: ssid))
        
        let result = expectation(description: "view model created")
        
        viewModel.geofence
            .subscribe(onNext: { data in
                XCTAssertEqual(data.latitude, mock.latitude)
                XCTAssertEqual(data.longitude, mock.longitude)
                XCTAssertEqual(data.radius, mock.radius)
                XCTAssertEqual(data.ssid, mock.ssid)
                
                result.fulfill()
            })
            .disposed(by: bag)
        
        latitude.accept(mock.latitude)
        longitude.accept(mock.longitude)
        radius.accept(mock.radius)
        ssid.accept(mock.ssid)
        wait(for: [result], timeout: 1.0)
    }
}
