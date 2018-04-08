//
//  CollectionViewController.swift
//  The Collection View Controller for the application. When Click a cell displays a web view 
//  with the media URL of the student
//  Created by Spiros Raptis on 11/03/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    var pinButton = UIBarButtonItem() // THe button that will update/save Student's location and other data
    var logoutButton = UIBarButtonItem()
    var reloadButton = UIBarButtonItem()

    var count = 0 //Keeps track of the number of Students.
    var update = false // Indicates whether the update/save location button will update or create a new entry to in the student's API
    override func viewDidLoad() {
        super.viewDidLoad()
<<<<<<< HEAD
        reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: "reload")
        pinButton = UIBarButtonItem(image: UIImage(named: "mappin_30x30"), landscapeImagePhone:UIImage(named: "mappin_30x30"), style: .plain, target: self, action: "newLocation")
        logoutButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: "logout")
=======
        reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(CollectionViewController.reload))
        pinButton = UIBarButtonItem(image: UIImage(named: "mappin_30x30"), landscapeImagePhone:UIImage(named: "mappin_30x30"), style: .Plain, target: self, action: #selector(CollectionViewController.newLocation))
        logoutButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(CollectionViewController.logout))
>>>>>>> origin/master

        let _ = UIImage(contentsOfFile: "mappin_30x30")
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItems = [logoutButton,reloadButton]
        self.navigationItem.leftBarButtonItems = [pinButton]
        self.navigationItem.title = "On The Map"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let networkReachability = Reachability.forInternetConnection()
        let networkStatus = networkReachability?.currentReachabilityStatus()
        if (networkStatus?.rawValue == NotReachable.rawValue) {
            displayMessageBox("No Network Connection")
        }
    }

    //MARK: Collection View Related
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let s = UdacityClient.sharedInstance().students {
            count = s.count
        }
        return count
    }
    
    //populates the collection view. (First Names and Last Names)
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        var student = Student(uniqueKey: "a",firstName: "a",lastName: "a")
        
        if let s = UdacityClient.sharedInstance().students?[(indexPath as NSIndexPath).row]{
            student = s
        }
        cell.firstName.text = student.firstName
        cell.lastName.text = student.lastName

        // Configure the cell...
        if ((indexPath as NSIndexPath).row == UdacityClient.sharedInstance().students!.count - 1)
        {
            getNextResults()
        }
        
        return cell
    }
    
    //It is used for displaying a web view with the mediaURL when pressed.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath){
    //Uncomment the following 3 lines if you want the browser to be embedded in the application
//        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController")! as! WebViewController
//        detailController.url = NSURL(string: UdacityClient.sharedInstance().students![indexPath.row].mediaURL!)
//        self.navigationController?.pushViewController(detailController, animated: true)

        let request = URLRequest(url: URL(string: UdacityClient.sharedInstance().students![(indexPath as NSIndexPath).row].mediaURL!)!)
        UIApplication.shared().openURL(request.url!)

    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat{
            return CGFloat(10.0)
    }
    
    //Distance between cells in a row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(-8.0)
    }
    //sets the border of the collection cell
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    //MARK: Get Next Results
    //Whenever it is called it retrieves the next batch of 100 records with the help of global variable count
    //We chose 14 because this is the maximum(approximately) rows that a page can display
    func getNextResults(){
        UdacityClient.sharedInstance().getStudentLocations(limit: 14,skip: count){result, errorString in
            if let _ = errorString{
                self.displayMessageBox("Couldn't get Student Details")
            }else{
                DispatchQueue.main.async(execute: {
                    if (result != nil) {
                        if (result!.count > 0 ){
                            self.collectionView?.reloadData()
                        }
                    }
                    return
                })
            }
        }
    }
    //MARK: Button Actions
    
    //Reload all data
    func reload(){
        let networkReachability = Reachability.forInternetConnection()
        let networkStatus = networkReachability?.currentReachabilityStatus()
        if (networkStatus?.rawValue == NotReachable.rawValue) { // Before reloading check if there is an available internet connection
            displayMessageBox("No Network Connection")
        }else{
            // If the reload was pressed all the data will be reloaded and the array of student's should be nullified
            count = 0
            UdacityClient.sharedInstance().students = nil
            getNextResults()
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

    
    //The action of the first new location button(top left)
    func newLocation(){
        let networkReachability = Reachability.forInternetConnection()
        let networkStatus = networkReachability?.currentReachabilityStatus()
        if (networkStatus?.rawValue == NotReachable.rawValue) {// Before quering for an existing location check if there is an available internet connection
            displayMessageBox("No Network Connection")
        }else{
            UdacityClient.sharedInstance().queryStudentLocation(UdacityClient.sharedInstance().account!.uniqueKey){ result,errorString in
                if let _ = errorString {
                    self.displayMessageBox("Couldn't query for Student Location")
                }else{
                    if result != nil{ //THen it is an update
                        DispatchQueue.main.async{
                            
                            let alert = UIAlertController(title: "", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: self.overwrite))
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                            self.navigationController!.present(alert, animated: true){
                                return ()
                            }
                        }
                    }else{//Not an update. New record will be created(update variable remains false)
                        DispatchQueue.main.async{
                            self.presentEnterLocationViewController()
                        }
                    }
                }
            }
        }
    }
    //MARK: other
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

