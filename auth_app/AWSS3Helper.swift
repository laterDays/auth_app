//
//  AWSS3Helper.swift
//  video_test2
//
//  Created by DASON ADAMOS on 12/8/15.
//  Copyright © 2015 DASON ADAMOS. All rights reserved.
//

import Foundation

public class AWSS3Helper
{
    static let BUCKET : String = CONFIG_VARS.S3_BUCKET_NAME
    static var COGNITO_IDENTITY_TOKEN : String?
    
    public static func GetCognitoIdentityToken () -> Void
    {
        let response : AnyObject? = OAUTHHelper.Auth3RequestResource("api/v1/aws_cognito_auth/new", contentType: "application/json; charset=utf-8")
        if let response_ = response
        {
            if let response_dictionary = response_ as? NSDictionary
            {
                if let token = response_dictionary["token"]
                {
                    self.COGNITO_IDENTITY_TOKEN = token as! String
                    print("[ ] AWSS3Helper.GetCognitoIdentityToken() got token \(COGNITO_IDENTITY_TOKEN).")
                }
                else
                {
                    print("[ ] AWSS3Helper.GetCognitoIdentityToken() response has no token.")
                }
            }
            else
            {
                print("[ ] AWSS3Helper.GetCognitoIdentityToken() response cannot be converted to dictionary.")
            }
        }
        else
        {
            print("[ ] AWSS3Helper.GetCognitoIdentityToken() has nil response.")
        }
    }
}