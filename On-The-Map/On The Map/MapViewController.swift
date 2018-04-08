//
//  MapViewController.swift
//  On The Map
//
//  Created by Spiros Raptis on 03/04/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    var pinButton = UIBarButtonItem()// THe button that will update/save Student's location and other data
    var logoutButton = UIBarButtonItem()
    var reloadButton = UIBarButtonItem()
    var moreLocationsButton = UIBarButtonItem()
    var annotations = [MKPointAnnotation]()
    var count = 0 //Keeps track of the number of Students
    var update = false // Indicates whether the update/save location button will update or create a new entry to in the student's API
    override func viewDidLoad() {
        super.viewDidLoad()
        
<<<<<<< HEAD
        reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: "reload")
        pinButton = UIBarButtonItem(image: UIImage(named: "mappin_30x30"), landscapeImagePhone:UIImage(named: "mappin_30x30"), style: .plain, target: self, action: "newLocation")
        logoutButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: "logout")
        moreLocationsButton = UIBarButtonItem(title: "More", style: .plain, target: self, action: "moreLocations")
        UIImage(contentsOfFile: "mappin_30x30")
=======
        reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(MapViewController.reload))
        pinButton = UIBarButtonItem(image: UIImage(named: "mappin_30x30"), landscapeImagePhone:UIImage(named: "mappin_30x30"), style: .Plain, target: self, action: #selector(MapViewController.newLocation))
        logoutButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(MapViewController.logout))
        moreLocationsButton = UIBarButtonItem(title: "More", style: .Plain, target: self, action: #selector(MapViewController.moreLocations))
        let _ = UIImage(contentsOfFile: "mappin_30x30")
>>>>>>> origin/master
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItems = [logoutButton,reloadButton]
        self.navigationItem.leftBarButtonItems = [pinButton,moreLocationsButton]
        self.navigationItem.title = "On The Map"
        self.mapView.delegate = self
        
        //Center the map
        let location = CLLocationCoordinate2D(
            latitude: 31.237789,
            longitude: -88.803721
        )
        let span = MKCoordinateSpanMake(80, 80)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
        //---------------
        //First time the view loads, it loads the application in logged in mode. So we need to take the first batch.
        getNextResults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let networkReachability = Reachability.forInternetConnection()
        let networkStatus = networkReachability?.currentReachabilityStatus()
        if (networkStatus?.rawValue == NotReachable.rawValue) {
            displayMessageBox("No Network Connection")
        }else{
            if let _ = UdacityClient.sharedInstance().students{
                self.mapView.removeAnnotations(annotations) //Also remove all the annotations.
                annotations = []
                self.addAnnotations(UdacityClient.sharedInstance().students!)
            }
        }
    }

    //MARK: Map Related
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            //Uncomment the following 3 lines if you want the browser to be embedded in the application
            
//            let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController")! as! WebViewController
//            detailController.url = NSURL(string: annotationView.annotation.subtitle!)
//            self.navigationController?.pushViewController(detailController, animated: true)
            
            let request = URLRequest(url: URL(string: annotationView.annotation!.subtitle!!)!)
            UIApplication.shared().openURL(request.url!)

        }
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .purple
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    //MARK: Get Next Results
    //Whenever it is called it retrieves the next batch of 100 records with the help of global variable count
    func getNextResults(){
        UdacityClient.sharedInstance().getStudentLocations(limit: 100,skip: count){result, errorString in
            if let _ = errorString {
                self.displayMessageBox("Could not download results")
            } else{
                DispatchQueue.main.async(execute: {
                    if (result != nil) {
                        self.count += result!.count
                        self.addAnnotations(result!)
                    }
                    return
                })
            }
        }
    }
    
    //Adding annotations from a Students array of Structs
    func addAnnotations(_ students:[Student]){
        for s in students{
            let annotation = MKPointAnnotation()

            if let lat = s.latitude, long = s.longtitude{
                let location = CLLocationCoordinate2D(
                    latitude: lat,
                    longitude: long
                )
                annotation.coordinate = location

            }
            annotation.title = s.firstName + " " + s.lastName
            annotation.subtitle = s.mediaURL
            self.annotations += [annotation]
            self.mapView.addAnnotation(annotation)
        }
    }
    
    //MARK: Button Actions
    
    //Reload all data
    func reload(){
        let networkReachability = Reachability.forInternetConnection()
        let networkStatus = networkReachability?.currentReachabilityStatus()
        if (networkStatus?.rawValue == NotReachable.rawValue) {
            displayMessageBox("No Network Connection")
        }else{
            // If the reload was pressed all the data will be reloaded and the array of student's should be nullified
            count = 0
            self.mapView.removeAnnotations(annotations) //Also remove all the annotations.
            annotations = []
            UdacityClient.sharedInstance().students = nil
            getNextResults()
        }
    }
    
    //It will fetch more results in a network conscious manner
    func moreLocations(){
        getNextResults()
    }
    
    //The action of the first new location button(top left)
    func newLocation(){
        let networkReachability = Reachability.forInternetConnection()
        let networkStatus = networkReachability?.currentReachabilityStatus()
        if (networkStatus?.rawValue == NotReachable.rawValue) {// Before quering for an existing location check if there is an available internet connection
            displayMessageBox("No Network Connection")
        }else{
            UdacityClient.sharedInstance().authenticateStudentLocationsWithViewController(self){ success,errorString in
                if let _ = errorString{
                    self.displayMessageBox(errorString!)
                }else{
                    if success == [true,true] {
                        DispatchQueue.main.async{
                            let alert = UIAlertController(title: "", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: self.overwrite))
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                            self.navigationController!.present(alert, animated: true,completion:nil)
                        }
                    }else if success == [true,false]{
                        DispatchQueue.main.async{
                            self.presentEnterLocationViewController()
                        }
                    }
                }
            }
                
        }            
    }
    
    
    //logs out of every application(including facebook)
    func logout(){
        // Logout from facebook. It doesn't change if we didn't login before.
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        //Nullify credentials
        UdacityClient.sharedInstance().account = nil
        UdacityClient.sharedInstance().students = nil
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: Other
    
    //presents the Enter Location View
    func presentEnterLocationViewController(){
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "EnterLocationViewController") as! EnterLocationViewController
        detailController.update = self.update // Mark if it is for update or not
        let navController = UINavigationController(rootViewController: detailController) // Creating a navigation controller with detailController at the root of the navigation stack.
        self.navigationController!.present(navController, animated: true) {
            self.navigationController?.popViewController(animated: true)
            return ()
        }
    }
    
    
    //Displays a basic alert box with the OK button and a message.
    func displayMessageBox(_ message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //if it is an overwrite set the apropriate variable to signify the update and present the next view.
    func overwrite(_ alert: UIAlertAction!){
        self.update = true //Mark for overwrite(update)
        self.presentEnterLocationViewController()
    }

}

