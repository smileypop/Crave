//
//  MapViewController.swift
//  Crave
//
//  Created by Matthew Laird on 1/14/17.
//  Copyright © 2017 Matthew Laird. All rights reserved.
//

import UIKit
import MapKit

// Class for showing a map in a detail controller - when user taps a collection view cell

class MapViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var mapView: MKMapView!
    weak var photo: FlickrPhoto!

    var hasPhotoPinBeenAddedToMap:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.setMapLocation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    // Setup map
    func setMapLocation() {

        // Find user
        Locator.locate(onDisabled: {

            isDisabled in

            // Handle missing location data
            Alerter.showErrorAlert(message: messageLocationCouldNotBeDetermined)

        }) {

            [weak self] location in

            // Did we find the user?
            if let userLocation = location {

                // Center the map on the user, and zoom to see the photo point as well

                let mapLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)

                let pinLocation = CLLocation(latitude: (self?.photo.location.latitude)!, longitude: (self?.photo.location.longitude)!)

                let distance = pinLocation.distance(from: userLocation) * 4

                let region = MKCoordinateRegionMakeWithDistance( mapLocation, distance, distance)

                self?.mapView.setRegion(region, animated: false)

            }
        }
    }

    // Add a pin to map
    func addPinToMap(location: CLLocationCoordinate2D) {

        let pin = MKPointAnnotation()
        pin.coordinate = location

        mapView.addAnnotation(pin)
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {

        // Make sure we only add the photo pin once - to prevent animation repeat
        if !hasPhotoPinBeenAddedToMap {
            addPinToMap(location: self.photo.location)
            hasPhotoPinBeenAddedToMap = true
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Don't do anything
        if annotation is MKUserLocation {
            return nil
        }

        // Set Heart icon and animate pin drop
        if annotation is MKPointAnnotation {

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as MKAnnotationView!

            if (annotationView == nil) {

                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifierMapAnnotationPin)
                
                annotationView?.image = UIImage(named: imageNameMapPin)
                
                annotationView?.scale(duration: 1.5, startScale: 1.0, endScale: 0.33)
                
            }
            
            return annotationView
        }
        
        return nil
    }
}
