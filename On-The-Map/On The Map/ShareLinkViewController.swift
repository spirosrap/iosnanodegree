//
//  map.swift
//  test
//
//  Created by Spiros Raptis on 05/04/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import MapKit

class ShareLinkViewController: UIViewController {
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var shareLink: UITextField!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var placeMark: MKPlacemark? = nil
    var locationString: String? = nil
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
<<<<<<< HEAD
    override func viewDidLoad() {
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = UIColor.white()
        submitButton.alpha = 0.8
        shareLink.text = "Enter a Link to Share Here"
        imageView.isHidden = true
        imageView.backgroundColor = UIColor.black().withAlphaComponent(0.70)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: "cancel")
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white()

        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Browse", style: .plain, target: self, action: "browse")
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white()

        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        
        self.navigationItem.hidesBackButton = true
=======
    override func viewDidLoad() {        
        configureUI()
>>>>>>> origin/master
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardDismissRecognizer()
    }
    

    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    //Action to dismiss the keyboard when a tap was performed outside the text view
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardDismissRecognizer()
        let applicationDelegate = (UIApplication.shared().delegate as! AppDelegate)
        if let sl = applicationDelegate.shareLink{
            shareLink.text = sl
        }
        
        //The geocoding
        if let address = locationString{
            let geocoder = CLGeocoder()
            geoCodingStarted() // handles the blackness of the image view and the display of the activity indicator

            geocoder.geocodeAddressString(address, completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if let _ = error {
                    let alert = UIAlertController(title: "", message: "Geocoding failed", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: self.cancel))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if let placemark = placemarks?[0] {
                        self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                        self.placeMark = MKPlacemark(placemark: placemark)
                        //Center the map
                        let p = MKPlacemark(placemark: placemark)
                        let span = MKCoordinateSpanMake(5, 5)
                        let region = MKCoordinateRegion(center: p.location!.coordinate, span: span)
                        self.mapView.setRegion(region, animated: true)
                        self.indicator.startAnimating()
                    }
                }
                self.geoCodingStoped() // handles the blackness of the image view and the display of the activity indicator

            })
        }
    }
    
    //MARK: BUtton Actions
    //Browse for a URL.
    func browse(){
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "SubmitLinkViewController") as! SubmitLinkViewController
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    func cancel(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // Cancel action from an Alert view
    func cancel(_ action:UIAlertAction! ){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //Check for a valid URL
    func checkURL(_ str:String) -> Bool{
        if (str.characters.count < 7){
            return false
        }else{
<<<<<<< HEAD
            return str.substring(with: (str.characters.index(str.startIndex, offsetBy: 0) ..< str.characters.index(str.startIndex, offsetBy: 7))) == "http://"
=======
            return str.substringWithRange(str.startIndex.advancedBy(0) ..< str.startIndex.advancedBy(7)) == "http://"
>>>>>>> origin/master
        }
    }
    
    //Submit the Location and link.
    @IBAction func submitAction(_ sender: UIButton) {
        let networkReachability = Reachability.forInternetConnection()
        let networkStatus = networkReachability?.currentReachabilityStatus()
        if (networkStatus?.rawValue == NotReachable.rawValue) {// Before quering for an existing location check if there is an available internet connection
            displayMessageBox("No Network Connection")
        } else {
            if shareLink.text ==  "Enter a Link to Share Here" || !checkURL(shareLink.text!){
                displayMessageBox("You should enter a Valid URL")
            }else{
                if placeMark == nil{
                    displayMessageBox("We didn't find any location. Try Again")
                }else{
                    //Set the Account's next retrieved fields (First Name,Last Name was already retrieved from loging in)
                    UdacityClient.sharedInstance().account?.mapString = locationString
                    UdacityClient.sharedInstance().account?.mediaURL = shareLink.text
                    UdacityClient.sharedInstance().account?.latitude = placeMark!.coordinate.latitude
                    UdacityClient.sharedInstance().account?.longtitude = placeMark!.coordinate.longitude
                    
                    _ = UdacityClient.sharedInstance().account?.objectId //Get the objectId to update the record
                    if let _ = UdacityClient.sharedInstance().account?.objectId {
                        UdacityClient.sharedInstance().updateAccountLocation(UdacityClient.sharedInstance().account!){ result,error in
                            if error != nil{
                                DispatchQueue.main.async(execute: {
                                    self.displayMessageBox("Could not update Location")
                                })
                            }else if let r = result {
                                if r {
                                    DispatchQueue.main.async(execute: {
                                        let alert = UIAlertController(title: "", message: "Location updated", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: self.cancel))
                                        self.present(alert, animated: true, completion: nil)
                                    })
                                }else{
                                    DispatchQueue.main.async(execute: {
                                        self.displayMessageBox("Could not save Location")
                                    })
                                }
                            }
                        }
                    }else{ //If the record was not present create a new record.
                        UdacityClient.sharedInstance().saveAccountLocation(UdacityClient.sharedInstance().account!){ result,error in
                            if error != nil{
                                DispatchQueue.main.async(execute: {
                                    self.displayMessageBox("Could not save Location")
                                })
                            }else if let r = result {
                                if r {
                                    DispatchQueue.main.async(execute: {
                                        let alert = UIAlertController(title: "", message: "Location Saved", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: self.cancel))
                                        self.present(alert, animated: true, completion: nil)
                                    })
                                }else{
                                    DispatchQueue.main.async(execute: {
                                        self.displayMessageBox("Could not save Location")
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    //MARK: Other
    // Start showing Activity indicator and the black transparent image view
    func geoCodingStarted(){
        imageView.isHidden = false
        indicator.startAnimating()
    }
    
    // Start showing Activity indicator and the black transparent image view
    func geoCodingStoped(){
        imageView.isHidden = true
        indicator.stopAnimating()
    }
    
    
    //Displays a basic alert box with the OK button and a message.
    func displayMessageBox(_ message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func configureUI(){
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = UIColor.whiteColor()
        submitButton.alpha = 0.8
        shareLink.text = "Enter a Link to Share Here"
        imageView.hidden = true
        imageView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.70)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(cancel as Void -> Void))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Browse", style: .Plain, target: self, action: #selector(ShareLinkViewController.browse))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ShareLinkViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        
        
        navigationItem.hidesBackButton = true
    }
    
}
