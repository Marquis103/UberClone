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
    
    @IBOutlet var callUberButton: UIButton!
    
    @IBAction func btnCallAnUber(sender: AnyObject) {
        
        if riderRequestActive == false {
            let request = PFObject(className: "Request")
            
            request["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            request["username"] = PFUser.currentUser()?.username
            
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
            
            print("locations = \(locationValue.latitude) \(locationValue.longitude)")
            
            let center = CLLocationCoordinate2D(latitude: locationValue.latitude, longitude: locationValue.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.riderMap.setRegion(region, animated: true)
            
            self.riderMap.removeAnnotations(riderMap.annotations)
            let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationValue.latitude, locationValue.longitude)
            let objectAnnotation = MKPointAnnotation()
            objectAnnotation.coordinate = pinLocation
            objectAnnotation.title = "Your Location"
            self.riderMap.addAnnotation(objectAnnotation)
        }
        
    }
}