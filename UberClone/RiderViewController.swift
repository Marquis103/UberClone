//
//  RiderViewController.swift
//  UberClone
//
//  Created by Marquis Dennis on 12/20/15.
//  Copyright © 2015 Marquis Dennis. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController {

    @IBOutlet var riderMap: MKMapView!
    
    let locationManager = CLLocationManager()
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var riderRequestActive = false
    var driverOnTheWay = false
    
    @IBOutlet var callUberButton: UIButton!
    
    @IBAction func btnCallAnUber(sender: AnyObject) {
        
        if riderRequestActive == false {
            let request = PFObject(className: "Request")
            
            request["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            request["username"] = PFUser.currentUser()?.username
            let acl = PFACL()
            acl.publicWriteAccess = true
            acl.publicReadAccess = true
            
            request.ACL = acl
            
            request.saveInBackgroundWithBlock { (success, error) -> Void in
                if success == true {
                    self.callUberButton.setTitle("Cancel Uber", forState: UIControlState.Normal)
                    self.riderRequestActive = true
                    
                } else {
                    //want to display a message to the user
                    let alert = UIAlertController(title: "Could not call Uber", message: "Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        } else {
                riderRequestActive = true
                
                let requestQuery = PFQuery(className: "Request")
                requestQuery.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
                
                requestQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        if let objects = objects {
                            for object in objects {
                                object.deleteInBackground()
                            }
                        }
                        
                        self.callUberButton.setTitle("Call An Uber", forState: UIControlState.Normal)
                        self.riderRequestActive = false
                    }
                })
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Ask for Authorisation from the User.
        //self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        //self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logoutRider" {
            PFUser.logOutInBackground()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RiderViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let locationValue:CLLocationCoordinate2D = coord
            
            latitude = locationValue.latitude
            longitude = locationValue.longitude
            
            
            //check if the rider request has been responded to
            let query = PFQuery(className:"Request")
            if let username = PFUser.currentUser()?.username {
                query.whereKey("username", equalTo: username)
                query.whereKeyExists("driverResponded")
                query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        if let objects = objects {
                            if objects.count > 0 {
                                for object in objects {
                                    let query = PFQuery(className: "DriverLocation")
                                    query.whereKey("username", equalTo: (object["driverResponded"] as? String)!)
                                    
                                    query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                        if error != nil {
                                            print(error)
                                        } else {
                                            if let objects = objects {
                                                for object in objects {
                                                    if let driverLocation = object["driverLocation"] as? PFGeoPoint {
                                                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                                        let userCLLocation = CLLocation(latitude: locationValue.latitude, longitude: locationValue.longitude)
                                                        let distance = (driverCLLocation.distanceFromLocation(userCLLocation) * 0.00062137)
                                                        let roundedDistance = Double(round(distance * 1000) / 1000)
                                                        self.callUberButton.setTitle("Driver is \(roundedDistance) away!", forState: .Normal)
                                                        
                                                        self.driverOnTheWay = true
                                                        
                                                        let center = CLLocationCoordinate2D(latitude: locationValue.latitude, longitude: locationValue.longitude)
                                                        
                                                        //distance between the driver and user location
                                                        let latDelta = abs(driverLocation.latitude - locationValue.latitude) * 2 + 0.005
                                                        let longDelta = abs(driverLocation.longitude - locationValue.longitude) * 2 + 0.005
                                                        
                                                        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta))
                                                        
                                                        self.riderMap.setRegion(region, animated: true)
                                                        
                                                        self.riderMap.removeAnnotations(self.riderMap.annotations)
                                                        var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationValue.latitude, locationValue.longitude)
                                                        var objectAnnotation = MKPointAnnotation()
                                                        objectAnnotation.coordinate = pinLocation
                                                        objectAnnotation.title = "Your Location"
                                                        self.riderMap.addAnnotation(objectAnnotation)
                                                        
                                                        self.riderMap.removeAnnotations(self.riderMap.annotations)
                                                        pinLocation = CLLocationCoordinate2DMake(driverLocation.latitude, driverLocation.longitude)
                                                        objectAnnotation = MKPointAnnotation()
                                                        objectAnnotation.coordinate = pinLocation
                                                        objectAnnotation.title = "Driver Location"
                                                        self.riderMap.addAnnotation(objectAnnotation)
                                                    }
                                                }
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
                })
            }
            
            /*print("locations = \(locationValue.latitude) \(locationValue.longitude)")
            
            let center = CLLocationCoordinate2D(latitude: locationValue.latitude, longitude: locationValue.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.riderMap.setRegion(region, animated: true)*/
            
            
        }
        
    }
}