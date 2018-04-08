//
//  CoreDataStackManager.swift
//  instaexplorer
//
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import CoreData

/**
* The CoreDataStackManager contains the code that was previously living in the
* AppDelegate in Lesson 3. Apple puts the code in the AppDelegate in many of their
* Xcode templates. But they put it in a convenience class like this in sample code
* like the "Earthquakes" project.
*
*/

private let SQLITE_FILE_NAME = "app.sqlite"

class CoreDataStackManager {
    
    
    // MARK: - Shared Instance
    
    /**
    *  This class variable provides an easy way to get access
    *  to a shared instance of the CoreDataStackManager class.
    */
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
        
        return Static.instance
    }
    
    // MARK: - The Core Data stack. The code has been moved, unaltered, from the AppDelegate.
    
    lazy var applicationDocumentsDirectory: NSURL = {
        
        //        println("Instantiating the applicationDocumentsDirectory property")
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        
        print("Instantiating the managedObjectModel property")
        
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    /**
    * The Persistent Store Coordinator is an object that the Context uses to interact with the underlying file system. Usually
    * the persistent store coordinator object uses an SQLite database file to save the managed objects. But it is possible to
    * configure it to use XML or other formats.
    *
    * Typically you will construct your persistent store manager exactly like this. It needs two pieces of information in order
    * to be set up:
    *
    * - The path to the sqlite file that will be used. Usually in the documents directory
    * - A configured Managed Object Model. See the next property for details.
    */
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        print("Instantiating the persistentStoreCoordinator property")
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        print("sqlite path: \(url.path!)")
        
        var error: NSError? = nil
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [NSObject : AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            
            // Left in for development development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        print("Instantiating the managedObjectContext property")
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    lazy var favoritesManagedObjectContext: NSManagedObjectContext? = {
        
        print("Instantiating the managedObjectContext property")
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        
        if let context = self.managedObjectContext {
            
            var error: NSError? = nil
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    func favoritesSaveContext(){
        if let context = self.favoritesManagedObjectContext {
            var error: NSError? = nil
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    func favoritesdeleteObject(photo:InstaMedia){
        if let context = self.favoritesManagedObjectContext {
            var error: NSError? = nil
            deleteFile(InstaClient.sharedInstance().imagePath(photo.imagePath!))
            deleteFile(InstaClient.sharedInstance().imagePath(photo.profileImagePath!))
            context.deleteObject(photo)
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

    
    func deleteObject(location:Location){
        if let context = self.managedObjectContext {
            
            var error: NSError? = nil
            context.deleteObject(location)
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    func deleteObject(tag:Tag){
        if let context = self.managedObjectContext {
            
            var error: NSError? = nil
            context.deleteObject(tag)
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

    
    //Delete a file(an image in our case) using NSFileManager
    func deleteFile(let filePath:String) {
        let manager = NSFileManager.defaultManager()
        do{
            try manager.removeItemAtPath(filePath)
        } catch{
            print("Not succesfully deleted \(filePath)")
        }
        
    }
    
    //Deletes the Photo from context And the underlying image files
    func deleteObject(photo:InstaMedia){
        if let context = self.managedObjectContext {
            
            var error: NSError? = nil
            
            let changedThumbnailPath = photo.thumbnailPath!.stringByReplacingOccurrencesOfString("/", withString: "")//Because instagram returns the same lastpathcomponent for images and thumbnails I introduced this hack(replaced all "/" characters) to enable different paths for the same lastpathcomponents.
            let changedImagePath = photo.imagePath!.stringByReplacingOccurrencesOfString("/", withString: "")
            let changedProfileImagePath = photo.profileImagePath!.stringByReplacingOccurrencesOfString("/", withString: "")
            
            
            //Deleting all image assets for that media
            deleteFile(InstaClient.sharedInstance().imagePath(changedThumbnailPath))
            deleteFile(InstaClient.sharedInstance().imagePath(changedImagePath))
            deleteFile(InstaClient.sharedInstance().imagePath(changedProfileImagePath))
            
            
            context.deleteObject(photo)
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
}