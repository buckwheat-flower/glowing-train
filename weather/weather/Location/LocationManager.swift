//
//  LocationManager.swift
//  weather
//
//  Created by 1 on 11/27/23.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()
    private override init() {
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        super.init()
        
        manager.delegate = self
        
    }
    
    let manager: CLLocationManager
    
    var currentLocationTitle: String? {
        didSet {
            var userInfo = [AnyHashable: Any]()
            if let location = currentLocation {
                userInfo["location"] = location
            }
            
            NotificationCenter.default.post(name: Self.currentLocationDidupdate, object: nil, userInfo: userInfo)
        }
    }
    var currentLocation: CLLocation?
    
    static let currentLocationDidupdate = Notification.Name(rawValue: "currentLocationDidUpdate")

    func updateLocation(){
        let status: CLAuthorizationStatus
        
        status = manager.authorizationStatus
    
    
    switch status{
    case .notDetermined:
        requestAuthorization()
    case .authorizedAlways, .authorizedWhenInUse:
        requestCurrentLocation()
    case .denied, .restricted:
        print("not available")
    default:
        print("unknown")
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    private func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
        
    }
    
    private func requestCurrentLocation() {
        //manager.startUpdatingLocation()
        manager.requestLocation()
    
    }
    
    private func updateAddress(from location: CLLocation){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print(error)
                self?.currentLocationTitle = "Unknown"
                return
            }
            
            if let placemark = placemarks?.first {
                if let gu = placemark.locality, let dong = placemark.subLocality {
                    self?.currentLocationTitle = "\(gu) \(dong)"
                } else {
                    self?.currentLocationTitle = placemark.name ?? "Unknown"
                }
            }
            
            print(self?.currentLocationTitle)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case.notDetermined, .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status{
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case.notDetermined, .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations.last)
        
        if let location = locations.last {
            currentLocation = location
            updateAddress(from: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
