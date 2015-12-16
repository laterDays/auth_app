//
//  ApiHelper.swift
//  video_test2
//
//  Created by DASON ADAMOS on 12/4/15.
//  Copyright © 2015 DASON ADAMOS. All rights reserved.
//

import Foundation
import UIKit

public class OAUTHHelper
{
    enum STATE {
        case Begin, GrantRequested, CodeGiven, AccessTokenAcquired
    }
    
    static let REDIRECT_URI : String = "video-test2://home"
    static var ACCESS_TOKEN : String?
    static var State_ : STATE = STATE.Begin
    
    public static func Auth0ResetState ()
    {
        State_ = STATE.Begin
    }

    public static func SendData (url : String, method : String, requestContentType : String) -> NSString?
    {
        if let url_ = NSURL(string: url)
        {
            let request : NSMutableURLRequest = NSMutableURLRequest(URL: url_)
            request.HTTPMethod = method
            request.setValue(requestContentType, forHTTPHeaderField: "Content-Type")
            
            var data_string : NSString?
            let session : NSURLSession = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
                print("[ ] OAUTHHelper.SendData() Response: \(response)")
                if data != nil
                {
                    data_string = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("[ ] OAUTHHelper.Auth2GetToken() Body: \(data_string)")
                }
                else
                {
                    print("[ ] OAUTHHelper.Auth2GetToken() Body: no response.")
                }
            })
            task.resume()
            
            return data_string
        }
        else
        {
            print("[ ] OAUTHHelper.SendData() url error.")
            return nil
        }
    }
    
    public static func Auth1RequestGrant ()
    {
        State_ = STATE.Begin
        let url : NSURL? = NSURL(string: CONFIG_VARS.API_DOMAIN_URL + "oauth/authorize?client_id=" + CONFIG_VARS.API_CLIENT_ID + "&response_type=code&redirect_uri=" + REDIRECT_URI)
        if let url_ = url
        {
            UIApplication.sharedApplication().openURL(url_)
            print("[ ] OAUTHHelper.Auth1RequestGrant() opened url to request grant.")
            State_ = STATE.GrantRequested
        }
    }
    
    public static func Auth2UserAuthorized (url : NSURL, follow_up_function : (() -> Void)) -> Bool
    {
        if State_ == STATE.GrantRequested
        {
            if url.host == nil
            {
                return false
            }
            
            let urlComponents : NSURLComponents = NSURLComponents(string: url.absoluteString)!
            
            print("[ ] OAUTHHelper.Auth2GetCode() url: \(url)")
            
            if urlComponents.host == "home"
            {
                if let queryItems_ = urlComponents.queryItems
                {
                    if let code_ = queryItems_[0].value
                    {
                        print("[ ] OAUTHHelper.Auth2GetCode () at home, code: \(code_)")
                        State_ = STATE.CodeGiven
                        OAUTHHelper.Auth2GetToken(code_, follow_up_function: follow_up_function)
                        return true
                    }
                }
            }
            else
            {
                print("[ ] OAUTHHelper.Auth2GetCode () no auth callback at url: \(url)")
            }
            return true
        }
        else
        {
            print("[ ] OAUTHHelper.Auth2GetCode() called on incorrect state: \(State_)")
            return false
        }
    }
    
    public static func Auth2GetCode (url : NSURL, follow_up_function : (() -> Void)) -> Bool
    {
        if State_ == STATE.GrantRequested
        {
            if url.host == nil
            {
                return false
            }
            
            let urlComponents : NSURLComponents = NSURLComponents(string: url.absoluteString)!
            
            print("[ ] OAUTHHelper.Auth2GetCode() host: \(urlComponents.host)")
            
            // OAuth callback is video-test2://home
            // if this app recieves this uri callback
            // the following test is true
            if urlComponents.host == "home"
            {
                if let queryItems_ = urlComponents.queryItems
                {
                    if let code_ = queryItems_[0].value
                    {
                        print("[ ] OAUTHHelper.Auth2GetCode () at home, code: \(code_)")
                        State_ = STATE.CodeGiven
                        OAUTHHelper.Auth2GetToken(code_, follow_up_function: follow_up_function)
                        return true
                    }
                }
            }
            else
            {
                print("[ ] OAUTHHelper.Auth2GetCode () no auth callback at url: \(url)")
            }
            return false
        }
        else
        {
            print("[ ] OAUTHHelper.Auth2GetCode () called on incorrect state: \(State_)")
            return false
        }
    }
    
    private static func Auth2GetToken (code : NSString, follow_up_function : (() -> Void)) -> Bool
    {
        if State_ == STATE.CodeGiven
        {
            let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: CONFIG_VARS.API_DOMAIN_URL + "oauth/token")!)
            
            let dataDictionary : NSDictionary =
            [
                "client_id": "\(CONFIG_VARS.API_CLIENT_ID)",
                "redirect_uri": "\(REDIRECT_URI)",
                "grant_type": "authorization_code",
                "code": "\(code)"
            ];
            
            request.HTTPMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            do
            {
                try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(dataDictionary, options: NSJSONWritingOptions.init(rawValue: 0))
            
                let session : NSURLSession = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
                    print("[ ] OAUTHHelper.Auth2GetToken() Response: \(response)")
                    let dataStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("[ ] OAUTHHelper.Auth2GetToken() Body: \(dataStr)")
                    
                    if let bodyDictionary = GetObject(data) as! NSDictionary?
                    {
                        print("[ ] OAUTHHelper.Auth2GetToken() bodyDictionary: \(bodyDictionary)")
                        self.ACCESS_TOKEN = bodyDictionary["access_token"] as? String
                        follow_up_function()
                    }
                    else
                    {
                        print("[ ] OAUTHHelper.Auth2GetToken() no dictionary from data.")
                    }
                })
                task.resume()
            }
            catch
            {
                print("[ ] OAUTHHelper.Auth2GetToken() no JSON from \(dataDictionary).")
            }
            
            // Check if the request recieved an access token
            if ACCESS_TOKEN != nil
            {
                State_ = STATE.AccessTokenAcquired
                print("[ ] OAUTHHelper.Auth2GetToken() success.")
                return true
            }
            else
            {
                print("[ ] OAUTHHelper.Auth2GetToken() failure.")
                return false
            }
        }
        else
        {
            print("[ ] OAUTHHelper.Auth2GetToken() called on incorrect state: \(State_)")
            return false
        }
    }
    
    public static func Auth3RequestResource (relativePath : String, contentType : String) -> AnyObject?
    {
        if let ACCESS_TOKEN_ = ACCESS_TOKEN
        {
            let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: (CONFIG_VARS.API_DOMAIN_URL + relativePath))!)
            request.setValue("Bearer " + ACCESS_TOKEN_, forHTTPHeaderField: "Authorization")
            request.setValue(ACCESS_TOKEN_, forHTTPHeaderField: "AuthorizationToken")
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "GET"
            
            print("[ ] OAUTHHelper.Auth3RequestResource() to: \(relativePath), contentType: \(contentType)")
            
            var data_obj : AnyObject?
            let session : NSURLSession = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
                print("[ ] OAUTHHelper.Auth3RequestResource() Response: \(response)")
                let dataStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("[ ] OAUTHHelper.Auth3RequestResource() Body: \(dataStr)")
                data_obj = GetObject(data)
            })
            task.resume()
            return data_obj
        }
        else
        {
            print("[ ] OAUTHHelper.Auth3RequestResource() No token, in state \(State_)")
            return nil
        }
    }
    
    private static func GetObject (JSON_data : NSData?) -> AnyObject?
    {
        // Check if data exists
        if let JSON_data_ = JSON_data {
            do
            {
                // check if it can be read
                if let JSON: AnyObject = try NSJSONSerialization.JSONObjectWithData(JSON_data_, options: NSJSONReadingOptions.MutableContainers) {
                    
                    // Check if it can be converted to NSDictionary
                    if let JSON_dictionary = JSON as? NSDictionary
                    {
                        print("[ ] OAUTHHelper.GetObject(), dictionary: \(JSON_dictionary)")
                        return JSON_dictionary
                    }
                    else
                    {
                        if let JSON_array = JSON as? NSArray
                        {
                            print("[ ] OAUTHHelper.GetObject(), array: \(JSON_array)")
                            return JSON_array
                        }
                        
                        if let JSON_string = NSString(data: JSON_data_, encoding: NSUTF8StringEncoding) {
                            print("[ ] OAUTHHelper.GetObject(), no dictionary for: \(JSON_string)")
                        }
                    }
                }
                else {
                    print("[ ] OAUTHHelper.GetObject(), cannot parse: \(JSON_data_)")
                }
            }
            catch
            {
                
            }
        }
        else {
            print("[ ] OAUTHHelper.GetDictionary(), data is nil.")
        }
        return nil
    }
}