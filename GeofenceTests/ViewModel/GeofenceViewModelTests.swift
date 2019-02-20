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
import CoreLocation

class GeofenceViewModelTests: XCTestCase {

    func testDataPersist() {
        let mock = GeoData.mock()
        
        let viewModel = GeofenceViewModel(input: (latitude: BehaviorRelay(value: 0),
                                                  longitude: BehaviorRelay(value: 0),
                                                  radius: BehaviorRelay(value: 0).asObservable(),
                                                  ssid: BehaviorRelay(value: "").asObservable()),
                                          maxRadius: 0)
        
        UserDefaults.standard.removeObject(forKey: Constant.geoDataKey)
        
        viewModel.saveGeoData(geoData: mock)
        let data = viewModel.getGeoData()
        XCTAssertEqual(data?.id, mock.id)
        XCTAssertEqual(data?.latitude, mock.latitude)
        XCTAssertEqual(data?.longitude, mock.longitude)
        XCTAssertEqual(data?.radius, mock.radius)
        XCTAssertEqual(data?.ssid, mock.ssid)
        
    }
    
    func testGeofenceObservable() {
        let bag = DisposeBag()
        let mock = GeoData.mock()
        
        let latitude = BehaviorRelay<Double>(value: 0)
        let longitude = BehaviorRelay<Double>(value: 0)
        let radius = BehaviorRelay<Double>(value: 0)
        let ssid = BehaviorRelay<String>(value: "")
        let manager = CLLocationManager()
        let tapAction = BehaviorRelay<Void>(value: ())
        
        let viewModel = GeofenceViewModel(input: (latitude: latitude,
                                                  longitude: longitude,
                                                  radius: radius.asObservable(),
                                                  ssid: ssid.asObservable()),
                                          maxRadius: manager.maximumRegionMonitoringDistance)
        
        let result = expectation(description: "view model created")
        
        tapAction
            .skip(1)
            .withLatestFrom(viewModel.geofence)
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
        
        tapAction.accept(())
        wait(for: [result], timeout: 1.0)
    }
    
    func testAddEnabled() {
        let bag = DisposeBag()
        let mock = GeoData.mock()
        
        let radius = BehaviorRelay<Double>(value: 0)
        let ssid = BehaviorRelay<String>(value: "")
        let manager = CLLocationManager()
        
        let viewModel = GeofenceViewModel(input: (latitude: BehaviorRelay(value: 0),
                                                  longitude: BehaviorRelay(value: 0),
                                                  radius: radius.asObservable(),
                                                  ssid: ssid.asObservable()),
                                          maxRadius: manager.maximumRegionMonitoringDistance)
        radius.accept(mock.radius)
        ssid.accept(mock.ssid)
        
        let expect = expectation(description: "button enabled")
        
        viewModel.addEnabled
            .subscribe(onNext: { status in
                XCTAssertTrue(status)
                expect.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [expect], timeout: 1.0)
    }
    
    func testAddDisabled() {
        let bag = DisposeBag()
        let mock = GeoData.mock()
        
        let radius = BehaviorRelay<Double>(value: 0)
        let ssid = BehaviorRelay<String>(value: "")
        let manager = CLLocationManager()
        
        let viewModel = GeofenceViewModel(input: (latitude: BehaviorRelay(value: 0),
                                                  longitude: BehaviorRelay(value: 0),
                                                  radius: radius.asObservable(),
                                                  ssid: ssid.asObservable()),
                                          maxRadius: manager.maximumRegionMonitoringDistance)
//        radius.accept(mock.radius)
        ssid.accept(mock.ssid)
        
        let expect = expectation(description: "button disabled")
        
        viewModel.addEnabled
            .subscribe(onNext: { status in
                XCTAssertFalse(status)
                expect.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [expect], timeout: 1.0)
    }
}
