//
//  DriverViewController.swift
//  UberClone
//
//  Created by Marquis Dennis on 12/21/15.
//  Copyright © 2015 Marquis Dennis. All rights reserved.
//

import UIKit
import Parse
import MapKit

class DriverViewController: UITableViewController {

    //var requests = [String : CLLocationCoordinate2D]()
    var locationManager = CLLocationManager()
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var distances = [CLLocationDistance]()
    var requestObjects = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //get driver location to determine which requests are close
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return self.requests.keys.count
        return self.requestObjects.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logoutDriver" {
            navigationController?.setNavigationBarHidden(true, animated: false)
            PFUser.logOutInBackground()
        } else if segue.identifier == "showViewRequests" {
            //get the row of table selected and parse the information and pass on the information
            
            //get destination view controller
            if let destination = segue.destinationViewController as? RequestsViewController {
                destination.requestObject = requestObjects[(tableView.indexPathForSelectedRow?.row)!]
            }
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let username = requestObjects[indexPath.row]["username"] as! String
        
        let roundedDistance = Double(round(distances[indexPath.row] * 1000) / 1000)
        
        cell.textLabel?.text = username + " - " + String(roundedDistance) + " miles away"

        return cell
    }
    
    func createAlert(title: String, message: String) {
        //want to display a message to the user
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DriverViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let locationValue:CLLocationCoordinate2D = coord
            
            latitude = locationValue.latitude
            longitude = locationValue.longitude
            
            //print("locations = \(locationValue.latitude) \(locationValue.longitude)")
            
            let requestQuery = PFQuery(className: "Request")
            requestQuery.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: locationValue.latitude, longitude: locationValue.longitude))
            requestQuery.whereKeyDoesNotExist("driverResponded")
            requestQuery.limit = 10
            requestQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error != nil {
                    self.createAlert("Getting Requests Failed", message: "There was an error retrieving requests")
                } else {
                    if let objects = objects {
                        
                        self.requestObjects.removeAll()
                        self.distances.removeAll()
                        
                        for object in objects {
                            if let location = object["location"] as? PFGeoPoint {
                                let requestLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                self.requestObjects.append(object)
                                
                                //self.requests[object["username"]! as! String] = requestLocation
                                
                                //calculate distance between driver and request location
                                let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                                let driverCLLocation = CLLocation(latitude: locationValue.latitude, longitude: locationValue.longitude)
                                
                                let distance = driverCLLocation.distanceFromLocation(requestCLLocation)
                                self.distances.append(distance * 0.00062137)
                                
                            }
                        }
                        
                        //reload table data
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
}
