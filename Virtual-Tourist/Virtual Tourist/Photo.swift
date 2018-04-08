//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Spiros Raptis on 19/04/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation
import CoreData
import UIKit


@objc(Photo)
class Photo: NSManagedObject{

    struct Keys {
        static let Title = "title"
        static let ImagePath = "imagePath"
    }

    
    @NSManaged var title: String
    @NSManaged var imagePath: String
    @NSManaged var location:Location?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        title = dictionary[Keys.Title] as! String
        
        if let pathForImage = dictionary[Keys.ImagePath] as? String {
            imagePath = pathForImage
        }
        
    }
    
    var image: UIImage? {
        get {
            return Flickr.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        set {
            Flickr.Caches.imageCache.storeImage(image, withIdentifier: imagePath)
        }
    }

}