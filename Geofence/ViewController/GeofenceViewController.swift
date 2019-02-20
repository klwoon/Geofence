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
    @IBOutlet weak var addRegion: UIBarButtonItem!
    @IBOutlet weak var removeRegion: UIBarButtonItem!
    
    @IBOutlet weak var ssid: UITextField!
    @IBOutlet weak var radius: UITextField!
    
    var locationManager = CLLocationManager()
    let bag = DisposeBag()
    var addRegionState = BehaviorRelay<ButtonState>(value: .new)
    
    // Observables
    let latitude = BehaviorRelay<Double>(value: 0)
    let longitude = BehaviorRelay<Double>(value: 0)
    let pinDragged = BehaviorRelay<Void>(value: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupMapView()
        stopGeofenceMonitor()
        
        setupKeyboard()
        setupBinding()
    }
    
    deinit {
        print("deinit: \(String(describing: type(of: self)))")
    }
}

// MARK: Common methods
extension GeofenceViewController {

    func setupKeyboard() {
        radius.keyboardType = .numberPad
        ssid.keyboardType = .default
    }
    
    func setupMapView() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = self
    }
    
    func setupBinding() {
        
        // setup binding between view controller and view model
        let radiusInput = radius.rx.text.orEmpty.map { Double($0) ?? 0 }
        let ssidInput = ssid.rx.text.orEmpty.asObservable()
        
        let viewModel = GeofenceViewModel(input: (latitude: latitude,
                                                  longitude: longitude,
                                                  radius: radiusInput,
                                                  ssid: ssidInput),
                                          maxRadius: locationManager.maximumRegionMonitoringDistance)
        
        // Add/Update button binding
        addRegion.rx.tap
            .withLatestFrom(viewModel.geofence)
            .do(onNext: { geoData in
                viewModel.saveGeoData(geoData: geoData)
            })
            .subscribe(onNext: { [weak self] geoData in
                self?.addAnnotationAndOverlay(with: geoData)
            })
            .disposed(by: bag)
        
        // Annotation dragged binding
        pinDragged
            .skip(1)
            .withLatestFrom(viewModel.geofence)
            .do(onNext: { geoData in
                viewModel.saveGeoData(geoData: geoData)
            })
            .subscribe(onNext: { [weak self] geoData in
                self?.updateOverlay(for: geoData)
                
                self?.stopGeofenceMonitor()
                self?.startGeofenceMonitor(with: geoData)
            })
            .disposed(by: bag)

        // Remove button binding
        removeRegion.rx.tap
            .withLatestFrom(viewModel.geofence)
            .do(onNext: { geoData in
                viewModel.deleteGeoData()
            })
            .subscribe(onNext: { [weak self] geoData in
                
                self?.removeAnnotationAndOverlay()
                self?.stopGeofenceMonitor()
            })
            .disposed(by: bag)
        
        // Validation to enable/disable Add/Update Button
        viewModel.addEnabled
            .bind(to: addRegion.rx.isEnabled)
            .disposed(by: bag)
       
        // A state to track the Add/Update button
        addRegionState
            .asObservable()
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .new:
                    self?.addRegion.title = "Add"
                case .edit:
                    self?.addRegion.title = "Update"
                }
            })
            .disposed(by: bag)
        
        // Check if previous data is available and draw it
        checkSavedData(viewModel)
    }
    
    func updateOverlay(for geoData: GeoData) {
        // Remove all overlay before drawing a new one
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
        mapView.addOverlay(MKCircle(center: geoData.coordinate,
                                    radius: geoData.radius))
    }
    
    func updateAnnotation(for geoData: GeoData) {
        // Remove all pins before adding a new one
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        mapView.addAnnotation(geoData)
    }
    
    func addAnnotationAndOverlay(with geoData: GeoData) {
        updateAnnotation(for: geoData)
        updateOverlay(for: geoData)
        
        // Stop and restart the monitoring service
        stopGeofenceMonitor()
        startGeofenceMonitor(with: geoData)
        
        addRegionState.accept(.edit)
    }

    func removeAnnotationAndOverlay() {
        // Clear all pins/ overlay
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        
        addRegionState.accept(.new)
    }
    
    func zoom(to coordinate: CLLocationCoordinate2D? = nil) {
        // After location is fixed, zoom to it
        let location = coordinate ?? mapView.userLocation.coordinate
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    }
    
    func startGeofenceMonitor(with geoData: GeoData) {
        // Create a circular region
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
        // Stop monitoring
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        view.endEditing(true)
        title = "Status: inactive"
    }
    
    func checkSavedData(_ viewModel: GeofenceViewModel) {
        guard let savedData = viewModel.getGeoData() else { return }
        
        savedData.coordinate = CLLocationCoordinate2D(latitude: savedData.latitude, longitude: savedData.longitude)
        
        // Populate the saved data into UITextFields
        latitude.accept(savedData.latitude)
        longitude.accept(savedData.longitude)
        radius.insertText(String(Int(savedData.radius)))
        ssid.insertText(savedData.ssid)

        // Add the pin and overlay and start the monitoring service
        addAnnotationAndOverlay(with: savedData)

    }
}

// MARK: CLLocationManagerDelegate
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
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        showSingleActionAlert(dialog: AlertContent(title: "Error",
                                                   message: error.localizedDescription,
                                                   okAction: AlertAction(title: "OK")))
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        title = "Status: waiting"
    }
}

// MARK: MKMapViewDelegate
extension GeofenceViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is GeoData else { return nil }
        
        // Recycle the pin if available
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
        // Draw the circular overlay
        let circle = MKCircleRenderer(overlay: overlay)
        circle.lineWidth = 1
        circle.strokeColor = .black
        circle.fillColor = UIColor.green.withAlphaComponent(0.3)
        return circle
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        // Update the view model coordinates when drag action is ended
        if newState == .ending {
            guard let newPin = view.annotation?.coordinate else { return }
            print("new: \(newPin.latitude) \(newPin.longitude)")
            
            latitude.accept(newPin.latitude)
            longitude.accept(newPin.longitude)
            pinDragged.accept(())
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("\(mapView.centerCoordinate)")
        guard addRegionState.value == .new else { return }
        
        // Update the view model coordinates
        latitude.accept(mapView.centerCoordinate.latitude)
        longitude.accept(mapView.centerCoordinate.longitude)
        
    }
}

// MARK: AlertDialogPresenter
extension GeofenceViewController: AlertDialogPresenter {
    // conform to show UIAlertController
}
