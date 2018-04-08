//
//  UdacityTableViewController.swift
//  On The Map
//
//  Created by Spiros Raptis on 02/04/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var pinButton = UIBarButtonItem()// THe button that will update/save Student's location and other data
    var logoutButton = UIBarButtonItem()
    var reloadButton = UIBarButtonItem()
    var count = 0 //Keeps track of the number of Students
    var update = false // Indicates whether the update/save location button will update or create a new entry to in the student's API
    override func viewDidLoad() {
        super.viewDidLoad()
        
<<<<<<< HEAD
        reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: "reload")
        pinButton = UIBarButtonItem(image: UIImage(named: "mappin_30x30"), landscapeImagePhone:UIImage(named: "mappin_30x30"), style: .plain, target: self, action: "newLocation")
        logoutButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: "logout")
        UIImage(contentsOfFile: "mappin_30x30")
=======
        reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(TableViewController.reload))
        pinButton = UIBarButtonItem(image: UIImage(named: "mappin_30x30"), landscapeImagePhone:UIImage(named: "mappin_30x30"), style: .Plain, target: self, action: #selector(TableViewController.newLocation))
        logoutButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(TableViewController.logout))
        let _ = UIImage(contentsOfFile: "mappin_30x30")
>>>>>>> origin/master
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItems = [logoutButton,reloadButton]
        self.navigationItem.leftBarButtonItem = pinButton
        self.navigationItem.title = "On The Map"
    }

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isEditing = false
        let networkReachability = Reachability.forInternetConnection()
        let networkStatus = networkReachability?.currentReachabilityStatus()
        if (networkStatus?.rawValue == NotReachable.rawValue) {
            displayMessageBox("No Network Connection")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view Related
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = UdacityClient.sharedInstance().students {
            count = s.count
        }
        
        return count
    }

    //populates the table view. (First Names and Last Names)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) 

        var student = Student(uniqueKey: "a",firstName: "a",lastName: "a")//Dummy struct. It will be updated next

        if let s = UdacityClient.sharedInstance().students?[(indexPath as NSIndexPath).row]{
            student = s
        }
        cell.textLabel?.text = student.firstName + " " + student.lastName
        cell.imageView?.image = UIImage(named: "mappin_18x18")
        // Configure the cell...
        if ((indexPath as NSIndexPath).row == UdacityClient.sharedInstance().students!.count - 1){
            getNextResults()
        }

        return cell
    }
    
    //didUnhighlightRowAtIndexPath works better than didSelectRowAtIndexPath because didSelectRowAtIndexPath didn't worked as expected.
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    //        Uncomment the following 3 lines if you want the browser to be embedded in the application
    
    //        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController")! as! WebViewController
    //        detailController.url = NSURL(string: UdacityClient.sharedInstance().students![indexPath.row].mediaURL!)
    //        self.navigationController?.pushViewController(detailController, animated: true)
        if let string = (UdacityClient.sharedInstance().students![(indexPath as NSIndexPath).row].mediaURL),url = URL(string:string){
            let request = URLRequest(url: url)
            UIApplication.shared().openURL(request.url!)
            
            //        if let request = NSURLRequest(URL: NSURL(string: (UdacityClient.sharedInstance().students[indexPath.row].mediaURL))){
            //            UIApplication.sharedApplication().openURL(request.URL!)

        }

    }

    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false}

    
    //MARK: Get Next Results
    //Whenever it is called it retrieves the next batch of 14 records with the help of global variable count
    //We chose 14 because this is the maximum(approximately) that a page can display
    func getNextResults(){
        UdacityClient.sharedInstance().getStudentLocations(limit: 14,skip: count){result, errorString in
            if let _ = errorString{
                self.displayMessageBox("Couldn't get Student Details")
            }else{
                DispatchQueue.main.async(execute: {
                    if (result != nil) {
                        if (result!.count > 0 ){
                            self.tableView.reloadData()
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
        if (networkStatus?.rawValue == NotReachable.rawValue) {// Before reloading check if there is an available internet connection
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
                    if result != nil{//THen it is an update
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
    
    //MARK: Other
    
    //if it is an overwrite set the apropriate variable to signify the update and present the next view.
    func overwrite(_ alert: UIAlertAction!){
        self.update = true //Mark for overwrite(update)
        self.presentEnterLocationViewController()
    }
    
    
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


}
