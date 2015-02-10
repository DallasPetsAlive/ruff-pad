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
    
    post(jsonRequestString, "https://api.rescuegroups.org/http/json")
}

func post(params : String, url : String) {
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
                parseResponse(json!)
            }
            else {
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: \(jsonStr)")
            }
        }
    })
    
    task.resume()
}

func parseResponse(jsonObj: NSObject) {
    let json = JSON(jsonObj)

    println("parsing rsp")

    let animalData = json["data"]
    for (animalID: String, subJson: JSON) in animalData {
        println("id: \(animalID)")
    }

    let animalDataStr = animalData.rawString()

    let cache = Shared.stringCache
    
    cache.set(value: animalDataStr!, key: "animalData")
    
    cache.fetch(key: "animalData").onSuccess { cacheData in
        println("fetch: \(cacheData)")
        
        let nsJson = (cacheData as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        let newJson = JSON(data: nsJson!)
        
        for (animalId: String, subJson: JSON) in animalData {
            let animalName = subJson["animalName"].stringValue
            println("name: \(animalName)")
        }
    }
    
    
}