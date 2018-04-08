//
//  ViewController.swift
//  test
//
//  Created by Spiros Raptis on 04/04/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import MapKit
class EnterLocationViewController: UIViewController {
    var tapRecognizer: UITapGestureRecognizer? = nil


    @IBOutlet var button: UIButton!
    @IBOutlet weak var locationString: UITextField! // The String location for geocoding
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var update = false // Indicates whether the update/save location button will update or create a new entry to in the student's API
    override func viewDidLoad() {
        super.viewDidLoad()

        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = UIColor.white()
        button.alpha = 0.8
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
<<<<<<< HEAD
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: "cancel")
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.darkGray()
=======
        self.navigationController?.navigationBar.translucent = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(EnterLocationViewController.cancel))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.darkGrayColor()
>>>>>>> origin/master
        self.navigationItem.hidesBackButton = true
        self.navigationController?.toolbar.isHidden = true
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(EnterLocationViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardDismissRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardDismissRecognizer()
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
    //MARK: -
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if let _ = segue.identifier {
            let detailController = segue.destinationViewController as! ShareLinkViewController
            detailController.locationString = locationString.text
        }
    }
    //MARK: - Button Action
    func cancel(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

