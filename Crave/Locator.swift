//
//  Locator.swift
//  Crave
//
//  Created by Matthew Laird on 1/12/17.
//  Copyright © 2017 Matthew Laird. All rights reserved.
//

import Foundation
import CoreLocation

// Class for locating user
class Locator: NSObject, CLLocationManagerDelegate {

    static let shared = Locator()

    fileprivate override init() {
        super.init()
    }

    typealias OnLocationDisabled = (Bool) -> Void
    typealias OnLocationResult = (CLLocation?) -> Void

    fileprivate var onLocationDisabled: OnLocationDisabled? = nil
    fileprivate var onLocationResult: OnLocationResult? = nil

    class func locate(onDisabled: @escaping OnLocationDisabled, onResult: @escaping OnLocationResult) {

        shared.onLocationDisabled = onDisabled

        shared.onLocationResult = onResult

        shared.locationManager.requestLocation()
    }

    class func makeLocationCoordinate2D(lat: String, lon: String) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lat.toDouble(), lon.toDouble())
    }

    lazy var locationManager: CLLocationManager = {
        let newLocationmanager = CLLocationManager()
        newLocationmanager.delegate = self
        newLocationmanager.requestWhenInUseAuthorization()
        // ...
        return newLocationmanager
    }()

    // MARK: - Delegate Methods

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            self.onLocationDisabled?(true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        self.locationManager.stopUpdatingLocation()

        if let location = locations.first {
            print("Found user's location: \(location)")
            self.onLocationResult?(location)
        }

        self.onLocationResult = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")

        self.locationManager.stopUpdatingLocation()

        self.onLocationResult?(nil)

        self.onLocationResult = nil
    }
    
}
