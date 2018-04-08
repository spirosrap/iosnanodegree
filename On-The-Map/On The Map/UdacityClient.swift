//
//  UdacityClient.swift
//  On The Map
//
//  Created by Spiros Raptis on 30/03/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit

class UdacityClient: NSObject {
    
    var session: URLSession
    
    var sessionID: String?
    var uniqueKey: String?
    var account: Student?
    var students: [Student]?

    override init(){
        session = URLSession.shared()
        super.init()
    }
    
    // MARK: - POST
    
    func taskForPOSTMethod(_ method: String,parse: Bool, parameters: [String : AnyObject]?, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var urlString:String
        if let mutableParameters = parameters {
            urlString = method + UdacityClient.escapedParameters(mutableParameters)
        }else{
            urlString = method
        }
        
        /* 2/3. Build the URL and configure the request */

        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
//        var jsonifyError: NSError? = nil
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch _ as NSError {
//            jsonifyError = error
            request.httpBody = nil
        }

        if parse{ // Check it if is for the parse application and apply the keys
            request.addValue(UdacityClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(UdacityClient.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }else{
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        /* 4. Make the request */
        let task = session.dataTask(with: request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                _ = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                var newData = data
                if(!parse){// If it isn't for parse, it is for the Udacity API which it requires to ommit the first 5 characters for security reasons
//                    print(data!.count)
                     newData = data!.subdata(in: Range(5 ..< data!.count )) /* subset response data! */
                }
                UdacityClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    //MARK: PUT
    //The PUT method for updating values
    func taskForPUTMethod(_ method: String, parameters: [String : AnyObject]?, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var urlString:String
        if let mutableParameters = parameters {
            urlString = method + UdacityClient.escapedParameters(mutableParameters)
        }else{
            urlString = method
        }
        
        /* 2/3. Build the URL and configure the request */
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
//        var jsonifyError: NSError? = nil
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(UdacityClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityClient.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch _ as NSError {
//            jsonifyError = error
            request.httpBody = nil
        }
        
        /* 4. Make the request */
        let task = session.dataTask(with: request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                _ = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                UdacityClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    // MARK: - GET
    
    func taskForGETMethod(_ method: String, parse: Bool, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        

        /* 2/3. Build the URL and configure the request */
        var urlString:String
        if let mutableParameters = parameters {
            urlString = method + UdacityClient.escapedParameters(mutableParameters)
        }else{
            urlString = method
        }

        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        if(parse){// Check it if is for the parse application and apply the keys
            request.addValue(UdacityClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(UdacityClient.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        /* 4. Make the request */
        
        let task = session.dataTask(with: request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                _ = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                var newData = data
                if(!parse){// If it isn't for parse, it is for the Udacity API which it requires to ommit the first 5 characters for security reasons
                    
                    //newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */

                    newData = data!.subdata(in: Range(5 ..< data!.count )) /* subset response data! */
                }
                UdacityClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(_ data: Data?, response: URLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "On The Map Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            print(error)
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            _ = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            /* FIX: Replace spaces with '+' */
            let replaceSpaceValue = stringValue.replacingOccurrences(of: " ", with: "+", options: NSString.CompareOptions.literalSearch, range: nil)
            
            /* Append it */
            urlVars += [key + "=" + "\(replaceSpaceValue)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    // MARK: - Shared Instance -- Singleton
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
}

