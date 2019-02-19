//
//  GeofenceViewModel.swift
//  Geofence
//
//  Created by Woon on 18/02/2019.
//  Copyright © 2019 Woon. All rights reserved.
//

import Foundation

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
    
    init(geoData: GeoData) {
        self.geoData = geoData
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
