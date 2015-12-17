//
//  AccountViewController.swift
//  video_test2
//
//  Created by DASON ADAMOS on 12/4/15.
//  Copyright © 2015 DASON ADAMOS. All rights reserved.
//

import UIKit

class AccountViewController : UIViewController {

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func testOAUTH(sender: AnyObject) {
        OAUTHHelper.Auth1RequestGrant()
    }
    
    @IBAction func register(sender: AnyObject) {
        if let email = userEmail.text
        {
            if let pass = userPassword.text
            {
                let user_data : NSDictionary =
                [
                    "email": "\(email)",
                    "password": "\(pass)"
                ];
                let user : NSMutableDictionary = NSMutableDictionary()
                user.setValue(user_data, forKey: "user")

                OAUTHHelper.SendData("https://auth-api-dev.herokuapp.com/users?", dataDictionary: user, method: "POST", requestContentType: "application/json; charset=utf-8")
            }
        }
    }
}