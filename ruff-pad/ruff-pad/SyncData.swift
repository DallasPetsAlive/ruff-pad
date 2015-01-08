//
//  SyncData.swift
//  ruff-pad
//
//  Created by Kirska on 1/6/15.
//  Copyright (c) 2015 dpa. All rights reserved.
//

import Foundation
import Haneke

func sendRGRequest() {
    // create the request & response
    /*var request = NSMutableURLRequest(URL: NSURL(string: "https://api.rescuegroups.org/http/json")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
    var response: NSURLResponse?
    var error: NSError?*/
    
    let jsonRequestString =
    "{\"apikey\" : \"QltdwQc9\"," +
        "\"objectType\" : \"animals\"," +
        "\"objectAction\" : \"publicSearch\"," +
        "\"search\" : {" +
            "\"calcFoundRows\" : \"Yes\"," +
            "\"resultStart\" : 0," +
            "\"resultLimit\" : 500," +
            "\"resultSort\" : \"animalID\"," +
            "\"fields\" :[" +
                "\"animalID\", \"animalOrgID\", \"animalName\", \"animalSpecies\", \"animalBreed\", \"animalThumbnailUrl\"]," +
            "\"filters\" : [" +
                    "{" +
                        "\"fieldName\" : \"animalStatus\"," +
                        "\"operation\" : \"equals\"," +
                        "\"criteria\" : \"Available\"" +
                    "}" +
                "]" +
            "}" +
        "}"
    
    var json : NSObject = post(jsonRequestString, "https://api.rescuegroups.org/http/json")
    
    
    
    
    let cache = Shared.JSONCache
    let URL = NSURL(string: "https://api.github.com/users/haneke")!
    
    cache.fetch(URL: URL).onSuccess { JSON in
        println(JSON.dictionary?["bio"])
    }
}

func post(params : String, url : String) -> NSObject {
    var returnVar :NSObject = NSObject()
    var request = NSMutableURLRequest(URL: NSURL(string: url)!)
    var session = NSURLSession.sharedSession()
    request.HTTPMethod = "POST"
    
    var err: NSError?
    request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    println("Request: \(request)")
    
    var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        println("Response: \(response)")
        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
        //println("Body: \(strData)")
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSObject
        
        // JSONObjectWithData error
        if(err != nil) {
            println(err!.localizedDescription)
            let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Error could not parse JSON: '\(jsonStr)'")
        }
        else {
            // check and make sure that json has a value using optional binding
            if let parseJSON = json {
                println("Successfully fetched data")
                returnVar = json!
            }
            else {
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: \(jsonStr)")
            }
        }
    })
    
    task.resume()
    
    return returnVar
}
