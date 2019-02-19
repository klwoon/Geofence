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
    var viewModel: GeofenceViewModel?
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupBinding()
        setupMapView()
        
        // test adding annotation
        let data = GeoData(id: 1, latitude: 3.09722, longitude: 101.64444, radius: 1000, ssid: "ssid")
//        data.coordinate = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
        let viewModel = GeofenceViewModel(geoData: data)
        mapView.addAnnotation(viewModel.geoData)
        mapView.addOverlay(MKCircle(center: data.coordinate, radius: data.radius))
        
        self.viewModel = viewModel
    }

    private func setupMapView() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = self
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

extension GeofenceViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is GeoData else { return nil }
        
        let identifier = "geofence_annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
            annotationView?.isDraggable = true
            annotationView?.isEnabled = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKCircle else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let circle = MKCircleRenderer(overlay: overlay)
        circle.lineWidth = 1
        circle.strokeColor = .black
        circle.fillColor = UIColor.green.withAlphaComponent(0.3)
        return circle
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        if newState == .ending {
            guard let newPin = view.annotation?.coordinate else { return }
            print("new: \(newPin.latitude) \(newPin.longitude)")
            
            for overlay in mapView.overlays {
                mapView.removeOverlay(overlay)
            }
            
            viewModel?.updateCoordinate(latitude: newPin.latitude, longitude: newPin.longitude)
            
            guard let data = viewModel?.geoData else { return }
            
            mapView.addOverlay(MKCircle(center: data.coordinate, radius: data.radius))
        }
    }
}

extension GeofenceViewController: AlertDialogPresenter {

}
