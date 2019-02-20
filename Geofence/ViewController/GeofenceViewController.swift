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
    @IBOutlet weak var addRegion: UIBarButtonItem!
    @IBOutlet weak var removeRegion: UIBarButtonItem!
    
    var locationManager = CLLocationManager()
    var viewModel = GeofenceViewModel()
    let bag = DisposeBag()
    
    // Observables
    let latitude = BehaviorRelay<Double>(value: 0)
    let longitude = BehaviorRelay<Double>(value: 0)
    let radius = BehaviorRelay<Double>(value: 0)
    let ssid = BehaviorRelay<String>(value: "")
    let pinDragged = BehaviorRelay<Void>(value: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupBinding()
        setupMapView()
        
//        self.viewModel = viewModel
    }

    private func setupMapView() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = self
        
        radius.accept(1000)
        ssid.accept("test 123")
    }
    
    private func setupBinding() {
        updateButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let controller = UIStoryboard(name: StoryboardId.main, bundle: nil).instantiateViewController(withIdentifier: StoryboardId.updateGeofenceViewController) as? UpdateGeofenceViewController else { return }
                let navController = UINavigationController(rootViewController: controller)
                self?.present(navController, animated: true, completion: nil)
            })
            .disposed(by: bag)
                
        let vm = GeofenceViewModel(input: (latitude: latitude,
                                                  longitude: longitude,
                                                  radius: radius,
                                                  ssid: ssid))
        
        addRegion.rx.tap
            .withLatestFrom(vm.geofence)
            .subscribe(onNext: { [weak self] geoData in
                self?.updateAnnotation(for: geoData)
                self?.updateOverlay(for: geoData)
                
                self?.stopGeofenceMonitor()
                self?.startGeofenceMonitor(with: geoData)
            })
            .disposed(by: bag)
        
        pinDragged
            .skip(1)
            .withLatestFrom(vm.geofence)
            .subscribe(onNext: { [weak self] geoData in
                self?.updateOverlay(for: geoData)
                
                self?.stopGeofenceMonitor()
                self?.startGeofenceMonitor(with: geoData)
            })
            .disposed(by: bag)

        removeRegion.rx.tap
            .withLatestFrom(vm.geofence)
            .subscribe(onNext: { [weak self] geoData in
                self?.removeAnnotationAndOverlay()
                self?.stopGeofenceMonitor()
            })
            .disposed(by: bag)
        
        
    }
    
    private func updateOverlay(for geoData: GeoData) {
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
        mapView.addOverlay(MKCircle(center: geoData.coordinate,
                                    radius: geoData.radius))
    }
    
    private func updateAnnotation(for geoData: GeoData) {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        mapView.addAnnotation(geoData)
    }
    
    private func removeAnnotationAndOverlay() {
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func zoom(to coordinate: CLLocationCoordinate2D? = nil) {
        let location = coordinate ?? mapView.userLocation.coordinate
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    }
    
    func startGeofenceMonitor(with geoData: GeoData) {
        
        let region = CLCircularRegion(center: geoData.coordinate,
                                      radius: geoData.radius,
                                      identifier: geoData.ssid)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self),
            CLLocationManager.authorizationStatus() == .authorizedAlways
        else {
            showSingleActionAlert(dialog: AlertContent(title: "Error",
                                                       message: "Monitoring not available",
                                                       okAction: AlertAction(title: "OK") ))
            return
        }
        locationManager.startMonitoring(for: region)
    }
    
    func stopGeofenceMonitor() {
        
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
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
            annotationView?.animatesDrop = false
            
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
            
            latitude.accept(newPin.latitude)
            longitude.accept(newPin.longitude)
            pinDragged.accept(())
//            stopGeofenceMonitor()
//            startGeofenceMonitor()
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("\(mapView.centerCoordinate)")
        latitude.accept(mapView.centerCoordinate.latitude)
        longitude.accept(mapView.centerCoordinate.longitude)
    }
}

extension GeofenceViewController: AlertDialogPresenter {

}
