//
//  EditorViewController
//  The Editor View to create A Meme or Edit one.
//  Created by Spiros Raptis on 09/03/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    //MARK:- Buttons
    var cameraButton = UIBarButtonItem()
    var flexiblespace = UIBarButtonItem()
    var pickImageButton = UIBarButtonItem()
    var shareButton = UIBarButtonItem()
    var cancelButton = UIBarButtonItem()
    
    //MARK:- Meme data
    var memedImage = UIImage()
    var meme:Meme!
    
    //MARK:- Gestures variables
    let tapRec = UITapGestureRecognizer()
    let panRec = UIPanGestureRecognizer()
    var lastLocation:CGPoint = CGPointMake(0, 0){//This variable will keep track of the last position of a user's touch.
        didSet{
            self.imagePickerView.center = lastLocation
        }
    }

    //MARK:- Keyboard related variables
    var keyboardHidden = true //View starts with the keyboard hidden

    var navandtoolhidden:Bool = false {// variable to keep when the toolbar and navbar are hidden
        didSet{
            hide(navandtoolhidden,animated: true)
        }
    }
    //MARK:-
    //MARK:- View related
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = self.view.frame.size.width;
        _ = self.view.frame.size.height;
        
        self.navigationController?.view.backgroundColor = UIColor.whiteColor() //When zooming the background should be white.
        bottomTextField.sizeToFit()
        
        //Manual add a tap gesture recognizer
        tapRec.addTarget(self, action: #selector(EditorViewController.tapped))
        tapRec.delegate = self
        view.addGestureRecognizer(tapRec)
        //Manual add a pan gesture recognizer
        panRec.addTarget(self, action: #selector(EditorViewController.detectPan(_:)))
        panRec.delegate = self
        panRec.cancelsTouchesInView = false;
        panRec.delaysTouchesEnded = false
        view.addGestureRecognizer(panRec)

        pickImageButton = UIBarButtonItem(title: "Album", style: .Done, target: self, action: #selector(EditorViewController.pickAnImageFromAlbum(_:)))
        cameraButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(EditorViewController.pickAnImageFromCamera(_:)))
        shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(EditorViewController.share))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(EditorViewController.cancel))
        flexiblespace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
      
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "Impact", size: 40)!, //Uses Custom Impact font.
            NSStrokeWidthAttributeName : -3
        ]
        
        topTextField.backgroundColor = UIColor.clearColor()
        bottomTextField.backgroundColor = UIColor.clearColor()
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        if(!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            cameraButton.enabled = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset previous scaling and position of image.
        self.imagePickerView.transform = CGAffineTransformIdentity
        lastLocation = self.imagePickerView.center
        
        //get the current meme for editing purposes
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        self.meme = applicationDelegate.editorMeme
        
        //redraw current meme image
        self.navigationItem.leftBarButtonItem = shareButton
        topTextField.text = meme.topText
        bottomTextField.text = meme.bottomText
        imagePickerView.image = meme.image
        
        //if an image was selected then enable the share button
        if(imagePickerView.image?.size == UIImage().size){
            shareButton.enabled = false
        }else{
            shareButton.enabled = true
        }

        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = cancelButton
        self.toolbarItems = [flexiblespace,cameraButton,flexiblespace,pickImageButton,flexiblespace]
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    //MARK:-

    //Camera button Action
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    //Album button.
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //setup editor image and current editor meme.
            self.imagePickerView.image = image
            meme.image = image
            meme.topText = self.topTextField.text
            meme.bottomText = self.bottomTextField.text
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Dismiss the Image Picker on Cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //After the enter is pressed at we dismiss the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(bottomTextField){
            self.unsubscribeFromKeyboardNotifications()
        }
        return true
    }
    
    //At the begining of Editing if the default text is written We reset it
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField.text == "TOP" || textField.text == "BOTTOM"{
            textField.text = ""
        }
        if textField.isEqual(bottomTextField){
            self.subscribeToKeyboardNotifications()
        }
    }

    //MARK:- KEYBOARD RELATED
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditorViewController.keyboardWillShow(_:))    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditorViewController.keyboardWillHide(_:))    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if(keyboardHidden ){ //If the keyboard was not hidden.(e.g. we change the type of the keyboard on currently displayed keyboard view) there's no need to change the origin.
            self.view.frame.origin.y = -getKeyboardHeight(notification)
            keyboardHidden = false
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if(!keyboardHidden){//If the keyboard was hidden.(e.g. we change the type of the keyboard on currently displayed keyboard view) there's no need to change the origin.
            self.view.frame.origin.y = 0
            keyboardHidden = true
        }
    }
    //MARK:-
    
    //Generates the memed image by grabbing a "screenshot" of the screen
    func generateMemedImage() -> UIImage {
        
        //Hide toolbar and navbar
        hide(true,animated: false)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        hide(false,animated: false)
    
        return memedImage
    }
    
    //Function to save the Meme.It is used only by the share method. It saves the Meme to appdelegate
    func save() {
        //Create the meme
        memedImage = generateMemedImage()
        let meme = Meme(topText:topTextField.text!, bottomText: bottomTextField.text!,  image: imagePickerView.image!,  memedImage: memedImage)
        self.meme = meme
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
    }
    
    //Action for the share button. It displayes the activity view and saves the Meme.
    func share(){
        save()
        _ = [UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypeMessage,UIActivityTypeSaveToCameraRoll]
        let activity = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activity.completionWithItemsHandler = { (activity, success, items, error) in
                let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeTabBarController") as! UITabBarController
            
            self.navigationController!.presentViewController(detailController, animated: true, completion: nil)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.setToolbarHidden(true, animated: false) //Set the toolbar hidden so as to enable the table view's toolbar.
            
            //Reset Editor View.
            let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            applicationDelegate.editorMeme = Meme(topText: "TOP", bottomText: "BOTTOM", image: UIImage(), memedImage: UIImage())
        }

        self.presentViewController(activity, animated: true, completion:nil)
        
    }
    
    //MARK:- GESTURES RELATED

    //For Image croping. Pinching Zooms in or out to crop the image.
    @IBAction func scaleImage(sender: UIPinchGestureRecognizer) {
        self.imagePickerView.transform = CGAffineTransformScale(self.imagePickerView.transform, sender.scale, sender.scale)
        sender.scale = 1
    }
    
    //hide toolbar and navigation bar when tapped
    func tapped(){
        navandtoolhidden = !navandtoolhidden
    }
    
    func detectPan(recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translationInView(self.imagePickerView)
        self.imagePickerView.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Remember original location
        super.touchesBegan(touches, withEvent: event)
        lastLocation = self.imagePickerView.center
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        lastLocation = self.imagePickerView.center
    }
    
    //Update the location(from a pan gesture)
    func updateLocation(){
        self.imagePickerView.center = lastLocation //Update the location(from a pan gesture)
    }
    
    //MARK: -
    //hide toolbar and navigation bar
    func hide(flag:Bool,animated:Bool){
        self.navigationController?.setNavigationBarHidden(flag, animated: animated)
        self.navigationController?.setToolbarHidden(flag, animated: animated)
        self.updateLocation()
    }
    
    //Cancel button action. It goes to the Tabbar(table and collection) view
    func cancel(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)//Dismiss the First-root controller.
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeTabBarController") as! UITabBarController
        self.navigationController?.presentViewController(detailController, animated: true,completion:nil)
    }
    
}