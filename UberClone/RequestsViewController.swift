//
//  RequestsViewController.swift
//  UberClone
//
//  Created by Marquis Dennis on 12/21/15.
//  Copyright © 2015 Marquis Dennis. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RequestsViewController: UIViewController {

    var requestLocation:CLLocationCoordinate2D?
    var requestUsername:String?
    var requestObject:PFObject?
    
    @IBAction func pickUpRider(sender: AnyObject) {
        if let request = requestObject {
            
            request["driverResponded"] = PFUser.currentUser()?.username

            request.saveInBackground()
            
            //get directions in apple maps
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: (requestLocation?.latitude)!, longitude: (requestLocation?.longitude)!), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                } else {
                    if let placemarks = placemarks {
                        let pm = placemarks[0] as CLPlacemark
                        
                        let mkpm = MKPlacemark(placemark: pm)
                        
                        let mapItem = MKMapItem(placemark: mkpm)
                        
                        mapItem.name = self.requestUsername!
                        
                        //You could also choose: MKLaunchOptionsDirectionsModeWalking
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        
                        mapItem.openInMapsWithLaunchOptions(launchOptions)
                    } else {
                        print("Problem with the data received from geocoder")
                    }
                }
            })
        }
    }
    
    @IBOutlet var requestMap: MKMapView!
    var latitude:CLLocationDegrees = 0
    var longitude:CLLocationDegrees = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let request = requestObject {
            
            if let location = request["location"] as? PFGeoPoint {
                requestLocation = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                    
                latitude = requestLocation!.latitude
                longitude = requestLocation!.longitude
                
                //print("locations = \(locationValue.latitude) \(locationValue.longitude)")
                
                let region = MKCoordinateRegion(center: requestLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                requestMap.setRegion(region, animated: true)
                requestUsername = request["username"] as? String
                let objectAnnotation = MKPointAnnotation()
                objectAnnotation.coordinate = requestLocation!
                objectAnnotation.title = requestUsername
                requestMap.addAnnotation(objectAnnotation)
                
            }
            
            print(requestLocation)
            print(requestUsername)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension RequestsViewController : CLLocationManagerDelegate {
    
}
