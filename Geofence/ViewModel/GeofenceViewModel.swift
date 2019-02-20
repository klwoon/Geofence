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
    var geofence: Observable<GeoData> { get }
    var addEnabled: Observable<Bool> { get }
}

protocol PersistData {
    func saveGeoData(geoData: GeoData)
    func getGeoData() -> GeoData?
}

class GeofenceViewModel: ViewModel {
    var geofence: Observable<GeoData> = .never()
    var addEnabled: Observable<Bool>
    
    init(input: (latitude: BehaviorRelay<Double>, longitude: BehaviorRelay<Double>, radius: Observable<Double>, ssid: Observable<String>),
         maxRadius: Double) {
        
        let inputs = Observable
            .combineLatest(input.latitude.asObservable(),
                           input.longitude.asObservable(),
                           input.radius,
                           input.ssid)
            .share(replay: 1)
        
        geofence = inputs
            .flatMapLatest { (arg) -> Observable<GeoData> in
            
                let (latitude, longitude, radius, ssid) = arg
                let data = GeoData(id: 0, latitude: latitude, longitude: longitude, radius: radius, ssid: ssid)
                return Observable.just(data)
            }
            .share(replay: 1)
 
        let isRadiusValid = input.radius
            .map { value -> Bool in
                guard value > 0, value < maxRadius else {
                    return false
                }
                return true
            }
            .share(replay: 1)
        
        let isSSIDValid = input.ssid
            .map { $0.count > 0 }
            .share(replay: 1)

        addEnabled = Observable
            .combineLatest(isRadiusValid, isSSIDValid) { $0 && $1 }
            .distinctUntilChanged()
            .share(replay: 1)
       
    }
}

extension GeofenceViewModel: PersistData {
    
    func saveGeoData(geoData: GeoData) {
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
