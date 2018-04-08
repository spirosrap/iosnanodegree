//
//  Student.swift
//  On The Map
//  The Student Struct
//  Created by Spiros Raptis on 31/03/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation


struct Student{
    var objectId:String?
    var uniqueKey:String
    var firstName:String
    var lastName: String
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longtitude: Double?
    
    //Initialize a Student Object with only three attributes because at the point of login no other attributes are known
    init(uniqueKey:String, firstName: String, lastName:String){ //Initialize the required fields
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
    }
    
    //Initialiser without using a dictionary.Might be used at some point
    init(objectId:String,uniqueKey:String, firstName: String, lastName:String,mapString:String, mediaURL:String, latitude:Double, longtitude:Double){ //Initialize the required fields
        self.init(uniqueKey: uniqueKey,firstName: lastName,lastName: firstName)
        self.objectId = objectId
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longtitude = longtitude
    }
    
    //Initialise from dictionary
    init(dictionary: [String : AnyObject]) {
        
        objectId = dictionary[UdacityClient.JSONBody.objectId] as! String?
        if let uq = dictionary[UdacityClient.JSONBody.uniqueKey] as? String{
            uniqueKey = uq
        }else{
            uniqueKey = ""
        }
        if let fn = dictionary[UdacityClient.JSONBody.firstName] as? String{
            firstName = fn
        }else{
            firstName = ""
        }
        
        if let ln = dictionary[UdacityClient.JSONBody.lastName] as? String{
            lastName = ln
        }else{
            lastName = ""
        }
        
        if let ms = dictionary[UdacityClient.JSONBody.mapString] as? String?{
            mapString = ms
        }else{
            mapString = ""
        }

        if let mu = dictionary[UdacityClient.JSONBody.mediaURL] as? String?{
            mediaURL = mu
        }else{
            mediaURL = ""
        }

        if let lat = dictionary[UdacityClient.JSONBody.latitude] as? Double?{
            latitude = lat
        }else{
            latitude = 0
        }

        
        if let long = dictionary[UdacityClient.JSONBody.longitude] as? Double?{
            longtitude = long
        }else{
            longtitude = 0
        }

    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of Student objects */
    static func studentsFromResults(_ results: [[String : AnyObject]]) -> [Student] {
        var students = [Student]()
        
        for result in results {
            if let r = result["uniqueKey"] as? String where r != ""{
                students.append(Student(dictionary: result))
            }
        }
        
        return students
    }

}
