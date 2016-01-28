//
//  ViewController.swift
//  Marking Route
//
//  Created by Nivardo Ibarra on 1/26/16.
//  Copyright © 2016 Nivardo Ibarra. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    private let manager = CLLocationManager()
    private var previousLocation : CLLocation!
    private var meters = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        manager.delegate = self
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        map.showsUserLocation = true
        
        let region = MKCoordinateRegionMakeWithDistance(manager.location!.coordinate, 1000, 100)
        map.setRegion(region, animated: true)
        map.showsUserLocation = true
        
        cameraSetup()

        let point: CLLocationCoordinate2D =  CLLocationCoordinate2DMake(manager.location!.coordinate.latitude, manager.location!.coordinate.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = point
        annotation.title = "River Parkway, GA"
        annotation.subtitle = "iOS Developer Swift 2.1"
        map.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
            map.showsUserLocation = true
        }else{
            manager.stopUpdatingLocation()
            map.showsUserLocation = false
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alert = UIAlertController(title: "Error", message: "error \(error.code)", preferredStyle: .Alert)
        let actionOk = UIAlertAction(title: "OK", style: .Default, handler: {
            accion in
            
        })
        alert.addAction(actionOk)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        //drawing path or route covered
        if let oldLocationNew = oldLocation as CLLocation?{
            let oldCoordinates = oldLocationNew.coordinate
            let newCoordinates = newLocation.coordinate
            var area = [oldCoordinates, newCoordinates]
            let polyline = MKPolyline(coordinates: &area, count: area.count)
            map.addOverlay(polyline)
        }
        //calculation for location selection for pointing annoation
        if ((previousLocation as CLLocation?) != nil) {
            //case if previous location exists
            if previousLocation.distanceFromLocation(newLocation) > 50 {
                meters += 50
                addAnnotationsOnMap(newLocation)
                previousLocation = newLocation
            }
        }else{
            //case if previous location doesn't exists
            addAnnotationsOnMap(newLocation)
            previousLocation = newLocation
        }
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.redColor()
            pr.lineWidth = 5
            return pr
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation.classForCoder()) {
            return nil
        }
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinPurple")
        pin.pinTintColor = UIColor.purpleColor()
        pin.canShowCallout = true
        return pin
    }

    func addAnnotationsOnMap(locationToPoint : CLLocation) {
        let pin = MKPointAnnotation()
        pin.coordinate = locationToPoint.coordinate
        pin.title = "Long: \(locationToPoint.coordinate.longitude), lat: \(locationToPoint.coordinate.latitude)"
        pin.subtitle = "Tours meters: \(meters)"
        map?.addAnnotation(pin)
    }
    
    private func cameraSetup() {
        map.camera.altitude = 1400
        map.camera.pitch = 50
        map.camera.heading = 180
    }
    
    @IBAction func segmentControlChange(sender: AnyObject) {
        switch sender.selectedSegmentIndex {
        case 1:
            map.mapType = MKMapType.SatelliteFlyover
        case 2:
            map.mapType = MKMapType.HybridFlyover
        default:
            map.mapType = MKMapType.Standard
        }
        cameraSetup()
    }

    @IBAction func showTraffic(sender: AnyObject) {
        map.showsTraffic = !map.showsTraffic
        
        if map.showsTraffic {
            sender.setTitle("Hide Traffic", forState: UIControlState.Normal)
        }else {
            sender.setTitle("Show Traffic", forState: .Normal)
        }
    }
    
    @IBAction func showCompass(sender: AnyObject) {
        map.showsCompass = !map.showsCompass
        if map.showsCompass {
            sender.setTitle("Hide Compass", forState: .Normal)
        }else {
            sender.setTitle("Show Compas", forState: .Normal)
        }
    }
}

