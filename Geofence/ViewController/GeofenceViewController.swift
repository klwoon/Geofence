//
//  GeofenceViewController.swift
//  Geofence
//
//  Created by Woon on 18/02/2019.
//  Copyright © 2019 Woon. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class GeofenceViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var updateButton: UIBarButtonItem!
    
    var locationManager = CLLocationManager()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupBinding()
        setupMapView()
        
    }

    private func setupMapView() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    private func setupBinding() {
        updateButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let controller = UIStoryboard(name: StoryboardId.main, bundle: nil).instantiateViewController(withIdentifier: StoryboardId.updateGeofenceViewController) as? UpdateGeofenceViewController else { return }
                let navController = UINavigationController(rootViewController: controller)
                self?.present(navController, animated: true, completion: nil)
            })
            .disposed(by: bag)
        
    }
    
    func zoom(to coordinate: CLLocationCoordinate2D? = nil) {
        let location = coordinate ?? mapView.userLocation.coordinate
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    }
    
    deinit {
        print("deinit: \(String(describing: type(of: self)))")
    }

}

extension GeofenceViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.requestLocation()
            
        case .denied:
            let alert = AlertContent(title: "Permission Denied",
                                     message: "Please go to Settings to enable Location.",
                                     okAction: AlertAction(title: "Setting",
                                                           action: { UIApplication.openAppSettings() }),
                                     cancelAction: AlertAction(title: "Cancel"))
            showDoubleActionAlert(dialog: alert)
            
        default:
            break
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        zoom(to: locations.first?.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showSingleActionAlert(dialog: AlertContent(title: "Error",
                                                   message: error.localizedDescription,
                                                   okAction: AlertAction(title: "OK")))
    }
}

extension GeofenceViewController: AlertDialogPresenter {

}
