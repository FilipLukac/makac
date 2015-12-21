//
//  ActivityViewController.swift
//  Makac
//
//  Created by Filip Lukac on 13/12/15.
//  Copyright © 2015 Hardsun. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class ActivityViewController: UIViewController, CLLocationManagerDelegate {
    
    let API_URL = "http://212.57.38.86:4000/place";
    
    var locationManager: CLLocationManager!
    var lastCoords = CLLocationCoordinate2D()
    var locationUpdated = false
    var foundLocation = false
    var path: GMSMutablePath!
    var polyLine: GMSPolyline!
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?

    
    var startTime = NSTimeInterval()
    var totalTime = NSTimeInterval()
    var timer = NSTimer()
    
    var currentTime = NSDate.timeIntervalSinceReferenceDate()
    var stopped = false
    let aSelector : Selector = "updateTime"
    
    var runDistance = 0.0;
    var firstLocation: CLLocation!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var stopWatchLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var distanceLabel: UILabel!

    
    @IBAction func start(sender: UIButton) {
        stopped = false
        resumeButton.hidden = !stopped
        resetButton.hidden = !stopped
        if !timer.valid {
            sender.hidden = true
            stopButton.hidden = false
            self.startTime = NSDate.timeIntervalSinceReferenceDate()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: self.aSelector, userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func stop(sender: UIButton) {
        sender.hidden = true
        stopped = true
        startButton.hidden = stopped
        resumeButton.hidden = !stopped
        resetButton.hidden = !stopped
        timer.invalidate()
    }
    
    @IBAction func resume(sender: UIButton) {
        startTime = NSDate.timeIntervalSinceReferenceDate() - totalTime
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
        stopped = false
        resetButton.hidden = !stopped
        resumeButton.hidden = !stopped
        startButton.hidden = !stopped
        stopButton.hidden = stopped
        
    }
    
    @IBAction func reset(sender: UIButton) {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Save workout", message: "Name your workout below", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Enter name of your workout"
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let workoutName = textField.text
            let workoutTimer = self.timer.timeInterval
        
            let parameters : [String : AnyObject] = [
                "name": workoutName!,
                "distance": "1.3km",
                "duration": workoutTimer
            ]
            
            
            Alamofire.request(.POST, self.API_URL, parameters: parameters, encoding: .JSON)
            
            
            self.stopWatchLabel.text = "00:00:00"
            self.stopButton.hidden = true
            self.resetButton.hidden = true
            self.resumeButton.hidden = true
            self.startButton.hidden = false
            
            self.timer.invalidate()

        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runDistance = 0.0
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        self.path = GMSMutablePath()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        stopButton.hidden = !stopped
        startButton.hidden = stopped
        resumeButton.hidden = !stopped
        resetButton.hidden = !stopped
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(48.857165, longitude: 2.354613, zoom: 8.0)
        
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways {
            mapView.myLocationEnabled = true
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = CLLocation(latitude: lastCoords.latitude, longitude: lastCoords.longitude)
        let distance = manager.location?.distanceFromLocation(currentLocation)
        if !foundLocation {
            mapView.animateToLocation((manager.location?.coordinate)!)
            mapView.animateToZoom(16.0)
            foundLocation = true
            firstLocation = currentLocation
        }

        if  distance > 2.0 {
            let runDistance = manager.location?.distanceFromLocation(firstLocation)
            distanceLabel.text = String(format: "Distance: %.f", runDistance!)
            locationUpdated = true
            lastCoords = (manager.location?.coordinate)!
            mapView.animateToLocation((manager.location?.coordinate)!)
            mapView.animateToZoom(16.0)
        }
        
        if locationUpdated {
            if !stopped {
                self.path.addCoordinate((manager.location?.coordinate)!);
                polyLine = GMSPolyline(path: self.path)
                polyLine.strokeWidth = 5.0
                polyLine.geodesic = true
                polyLine.map = mapView
            }
            locationUpdated = false
        }
    }
    

    func updateTime() {
        
        currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        totalTime = elapsedTime
        
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        
        stopWatchLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }
}
