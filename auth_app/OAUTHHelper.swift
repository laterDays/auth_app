//
//  ApiHelper.swift
//  video_test2
//
//  Created by DASON ADAMOS on 12/4/15.
//  Copyright © 2015 DASON ADAMOS. All rights reserved.
//

import Foundation
import UIKit

public protocol OAUTHHelperDelegate
{
    func newLoginStatus (status : OAUTHHelper.LOGIN_STATUS, messages : [String])
}

public class OAUTHHelper
{
    enum STATE {
        case Begin, DelegateIsSet, UserRegistered, UserLoggedIn, GrantRequested, CodeGiven, AccessTokenAcquired
    }
    public enum LOGIN_STATUS : String {
        case Success, Failure
    }
    
    static let REDIRECT_URI : String = "auth-app://home"
    static var ACCESS_TOKEN : String?
    static var State_ : STATE = STATE.Begin
    static var delegate : OAUTHHelperDelegate?
    
    public static func Setup (delegate : OAUTHHelperDelegate)
    {
        if State_ == STATE.Begin
        {
            self.delegate = delegate
            State_ = STATE.DelegateIsSet
            print("[ ] OAUTHHelper.Setup() delegate set up.")
        }
        else
        {
            print("[ ] OAUTHHelper.Setup() called in incorrect state: \(State_).")
        }
    }
    
    public static func Auth0ResetState ()
    {
        if delegate != nil
        {
            State_ = STATE.DelegateIsSet
        }
        else
        {
            State_ = STATE.Begin
        }
        print("[ ] OAUTHHelper.Auth0ResetState() state set to \(State_).")
    }

    /*
        SendData () - sends data to a url with the following parameters. The data that is returned will
        be handled by the last parameter.
            url : String - location to send data (e.g. "https://sub.domain.com/place?")
            dataDictionary : NSDictionary? - data you would like to send to the url
            method : String - (e.g. "POST", "GET", ...)
            requestContentType : String - (e.g. "application/json; charset=utf-8")
            operationOnResponse: (NSData)->Void) -> AnyObject - function that will handle response.
    */
    public static func SendData (url : String, dataDictionary : NSDictionary?, method : String, requestContentType : String, operationOnResponse: (NSData)->Void) -> AnyObject?
    {
        if let url_ = NSURL(string: url)
        {
            let request : NSMutableURLRequest = NSMutableURLRequest(URL: url_)
            request.HTTPMethod = method
            request.setValue(requestContentType, forHTTPHeaderField: "Content-Type")
            
            if let dataDictionary_ = dataDictionary
            {
                var data : NSData?
                do
                {
                    data = try NSJSONSerialization.dataWithJSONObject(dataDictionary_, options: NSJSONWritingOptions.init(rawValue: 0))
                }
                catch
                {
                    
                }
                if let data_ = data
                {
                    request.HTTPBody = data_
                }
            }
            print("[ ] OAUTHHelper.SendData() request: \(request.URL)")

            let session : NSURLSession = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
                print("[ ] OAUTHHelper.SendData() Response: \(response)")
                if let data_ = data
                {
                    print("[ ] OAUTHHelper.SendData() Body: \(NSString(data: data_, encoding: NSUTF8StringEncoding))")
                    operationOnResponse(data_)
                }
                else
                {
                    print("[ ] OAUTHHelper.SendData() Body: no response.")
                }
            })
            task.resume()
        }
        else
        {
            print("[ ] OAUTHHelper.SendData() url error.")
        }
        return nil
    }
    
    
    /*
        Auth0RegisterUser() - register a new user.
            userEmail : String
            userPassword : String

    */
    public static func Auth1RegisterUser (userEmail : String, userPassword : String)
    {
        if State_ == STATE.DelegateIsSet
        {
            let user_data : NSDictionary =
            [
                "email": "\(userEmail)",
                "password": "\(userPassword)"
            ];
            let user : NSMutableDictionary = NSMutableDictionary()
            user.setValue(user_data, forKey: "user")
            
            print("[ ] OAUTHHelper.Auth1RegisterUser() sending: \(user_data)")
            
            OAUTHHelper.SendData("https://auth-api-dev.herokuapp.com/users?", dataDictionary: user, method: "POST", requestContentType: "application/json; charset=utf-8", operationOnResponse: Auth0UserRegistered)
        }
        else
        {
            print("[ ] OAUTHHelper.Auth1RegisterUser() called in incorrect state: \(State_)")
        }
    }
    
    /*
        Auth0UserRegistered () - handles the data recieved by Auth0RegisterUser().
    */
    private static func Auth0UserRegistered (data : NSData)
    {
        if let response = GetObject(data) as! NSDictionary?
        {
            print("[ ] OAUTHHelper.Auth0UserRegistered() dictionary: \(response)")
            let code = response["state"]!["code"] as! Int
            switch code
            {
            case 0:
                print("[ ] OAUTHHelper.Auth0UserRegistered() email: \(response["data"]!["email"])")
                State_ = STATE.UserRegistered
                delegate?.newLoginStatus(LOGIN_STATUS.Success, messages: ["\(response["data"]!["email"]) registered!"])
            case 1:
                print("[ ] OAUTHHelper.Auth0UserRegistered() Error: \(response["state"]!["messages"])")
                Auth0ResetState()
                delegate?.newLoginStatus(LOGIN_STATUS.Failure, messages: response["state"]!["messages"] as! [String])
            default:
                 break
            }
        }
        else
        {
            print("[ ] OAUTHHelper.Auth0UserRegistered() no dictionary.")
            delegate?.newLoginStatus(LOGIN_STATUS.Failure, messages: ["Error: cannot create dictionary from response."])
            Auth0ResetState()
        }
    }
    
    public static func Auth2UserLogin (userEmail : String, userPassword : String)
    {
        if State_ == STATE.DelegateIsSet || State_ == STATE.UserRegistered
        {
            let user_data : NSDictionary =
            [
                "email": "\(userEmail)",
                "password": "\(userPassword)"
            ];
            let user : NSMutableDictionary = NSMutableDictionary()
            user.setValue(user_data, forKey: "user")
            
            print("[ ] OAUTHHelper.Auth2UserLogin() sending: \(user_data)")
            
            OAUTHHelper.SendData("https://auth-api-dev.herokuapp.com/users/sign_in?", dataDictionary: user, method: "POST", requestContentType: "application/json; charset=utf-8", operationOnResponse: Auth2UserLoggedIn)
        }
        else
        {
            print("[ ] OAUTHHelper.Auth2UserLogin() called in incorrect state: \(State_)")
        }
    }
    
    private static func Auth2UserLoggedIn (data : NSData)
    {
        if let response = GetObject(data) as! NSDictionary?
        {
            print("[ ] OAUTHHelper.Auth2UserLoggedIn() dictionary: \(response)")
            let code = response["state"]!["code"] as! Int
            switch code{
            case 0:
                print("[ ] OAUTHHelper.Auth2UserLoggedIn() email: \(response["data"]!["email"])")
                State_ = STATE.UserLoggedIn
                delegate?.newLoginStatus(LOGIN_STATUS.Success, messages: ["\(response["data"]!["email"]) logged in!"])
            case 1:
                print("[ ] OAUTHHelper.Auth2UserLoggedIn() Error: \(response["state"]!["messages"])")
                Auth0ResetState()
                delegate?.newLoginStatus(LOGIN_STATUS.Failure, messages: response["state"]!["messages"] as! [String])
            default:
                break
            }
            
        }
        else
        {
            print("[ ] OAUTHHelper.Auth2UserLoggedIn() no dictionary.")
            Auth0ResetState()
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
                    return JSON
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