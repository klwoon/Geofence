//
//  GeofenceViewModel.swift
//  Geofence
//
//  Created by Woon on 18/02/2019.
//  Copyright © 2019 Woon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModel {
    var geoData: GeoData { get }
    
    func updateCoordinate(latitude: Double, longitude: Double)
}

protocol PersistData {
    func saveGeoData()
    func getGeoData() -> GeoData?
}

class GeofenceViewModel: ViewModel {
    var geoData: GeoData
    var geofence: Observable<GeoData> = .never()
    
    init() {
        self.geoData = GeoData()
    }
    
    init(geoData: GeoData) {
        self.geoData = geoData
    }
    
    init(input: (latitude: BehaviorRelay<Double>, longitude: BehaviorRelay<Double>, radius: BehaviorRelay<Double>, ssid: BehaviorRelay<String>)) {
        self.geoData = GeoData()
        
        let inputs = Observable
            .combineLatest(input.latitude.asObservable(),
                           input.longitude.asObservable(),
                           input.radius.asObservable(),
                           input.ssid.asObservable())
//            .skip(1)
            .share(replay: 1)
        
        let foo = inputs
            .flatMapLatest { (arg) -> Observable<GeoData> in
            
                let (latitude, longitude, radius, ssid) = arg
                let data = GeoData(id: 0, latitude: latitude, longitude: longitude, radius: radius, ssid: ssid)
                return Observable.just(data)
            }
            .share(replay: 1)
        
        geofence = foo
        
        
    }
    
    func updateCoordinate(latitude: Double, longitude: Double) {
        geoData.latitude = latitude
        geoData.longitude = longitude
    }
}

extension GeofenceViewModel: PersistData {
    
    func saveGeoData() {
        do {
            let data = try JSONEncoder().encode(geoData)
            UserDefaults.standard.set(data, forKey: Constant.geoDataKey)
        } catch {
            print(error)
        }
    }
    
    func getGeoData() -> GeoData? {
        guard let data = UserDefaults.standard.data(forKey: Constant.geoDataKey) else {
            return nil
        }
        do {
            let geoData = try JSONDecoder().decode(GeoData.self, from: data)
            return geoData
        } catch {
            print(error)
        }
        return nil
    }
}
