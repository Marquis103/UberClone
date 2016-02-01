# UberClone
Uber clone is an app that simulates the Uber business flow from the aspect of the rider and the driver, using Parse as an online storage platform to store users, requests and updated locations.

### WorkFlow

#### Rider
The rider opens the application and after logging in successfully can request an Uber.  The request is submitted to the system and the request will be populated in a queue for near by uber drivers.  When a driver has selected to answer their request, the rider screen will be updated with how far away the driver is from their location.  The rider also has the option to cancel the uber request.

#### Driver
The driver waits for a request to be enqueued, and then selects the best rider they find available in the queue (usually the closest and easiest to get to is the best).  When the driver responds to a request, the rider's location is used to start the diretions portion of the Maps application.

###### Images Describing the Workflow
![Alt text](https://github.com/Marquis103/UberClone/blob/master/screenshots/driverlogin.png)
![Alt text](https://github.com/Marquis103/UberClone/blob/master/screenshots/ridercalluber.png)
![Alt text](https://github.com/Marquis103/UberClone/blob/master/screenshots/driverrequestsview.png)
![Alt text](https://github.com/Marquis103/UberClone/blob/master/screenshots/driverrespondtorider.png)
![Alt text](https://github.com/Marquis103/UberClone/blob/master/screenshots/driverdirectionstorider.png)
![Alt text](https://github.com/Marquis103/UberClone/blob/master/screenshots/driverIsClose.png)
