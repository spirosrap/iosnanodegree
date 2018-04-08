//
//  ViewController.swift
//  On The Map
//
//  Created by Spiros Raptis on 30/03/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,FBSDKLoginButtonDelegate,UINavigationControllerDelegate {

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton! // the facebook login button
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet var infoImageView: UIImageView! //Image view to for the nice display of a information message
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var tapRecognizer: UITapGestureRecognizer? = nil // It releases the keyboard if the user taps outside of the textboxes

    //Structures to check for network availability
    var networkReachability:Reachability = Reachability()
    var networkStatus:NetworkStatus = NotReachable

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        infoImageView?.backgroundColor = UIColor.black().withAlphaComponent(0.70)
        infoImageView.isHidden = true
        infoLabel.isHidden = true
        activityIndicator.isHidden = true
        self.fbLoginButton.delegate = self
        self.fbLoginButton.loginBehavior = FBSDKLoginBehavior.web
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)


        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
<<<<<<< HEAD
        NotificationCenter.default().addObserver(self, selector: "onProfileUpdated:", name:NSNotification.Name.FBSDKProfileDidChange, object: nil)
=======
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.onProfileUpdated(_:)), name:FBSDKProfileDidChangeNotification, object: nil)
>>>>>>> origin/master
 
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1

        //Initialize structure for checking network availability
        let networkReachability:Reachability = Reachability.forInternetConnection()
        var _:NetworkStatus = networkReachability.currentReachabilityStatus()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.toolbar.isHidden = true
        
        /* Add tap recognizer to dismiss keyboard */
        self.addKeyboardDismissRecognizer()
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
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    // MARK: - Button Actions
    @IBAction func basicLoginButtonTouch(_ sender: AnyObject) {
        self.view.endEditing(true)
        UdacityClient.sharedInstance().authenticateBasicLoginWithViewController(self) { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                self.displayMessage(errorString!)
            }
        }
    }
    
    
    @IBAction func touched(_ sender: FBSDKLoginButton) {
    }
    //It opens up Safari to create a new Account
    @IBAction func newAccount(_ sender: UIButton) {
        let request = URLRequest(url: URL(string: "https://www.udacity.com/account/auth#!/signup")!)
        UIApplication.shared().openURL(request.url!)
    }

    //MARK: - Other
    func displayError(_ errorString: String?) {
        DispatchQueue.main.async(execute: {
            if let errorString = errorString {
                print(errorString)
            }
        })
    }
    
    func completeLogin(){ // prepares the display of the next view
        DispatchQueue.main.async(execute: {

        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "AppTabBarController") as! UITabBarController
            self.navigationController!.present(detailController, animated: true) {
                self.navigationController?.popViewController(animated: true)
                return ()
            }
        })
       indicator(false)
    }
    
    //For facebook login function. It returns from facebook to check for
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        indicator(true)
        UdacityClient.sharedInstance().authenticateFacebookLoginWithViewController(self) { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                self.displayMessage(errorString!)
            }
        }
    }
    
    func onProfileUpdated(_ notification: Notification)
    {
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
    //Displays a message in a nice manner on top of an image view with alpha value.
    func displayMessage(_ message:String){
        infoImageView.isHidden = false
        infoLabel.isHidden = false
        infoLabel.text = message
        
        let delay = 1.6 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.after(when: time) {
            self.infoImageView.isHidden = true
            self.infoLabel.isHidden = true
        }
    }
    
    //Displays the indicator and an image view with alpha 0.8 to show background shaded
    func indicator(_ animate:Bool){
        if(animate){
            infoImageView.isHidden = false
            infoLabel.isHidden = true
            activityIndicator.startAnimating()
        }else{
            infoImageView.isHidden = true
            infoLabel.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    //Displays a basic alert box with the OK button and a message.
    func displayMessageBox(_ message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    

}
