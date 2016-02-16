//
//  AccountViewController.swift
//  video_test2
//
//  Created by DASON ADAMOS on 12/4/15.
//  Copyright © 2015 DASON ADAMOS. All rights reserved.
//

import UIKit

class AccountViewController : UIViewController, OAUTHHelperDelegate {

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userLoginStatus: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        OAUTHHelper.Setup(self)
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
                OAUTHHelper.Auth1RegisterUser(email, userPassword: pass)
            }
        }
    }
    
    
    @IBAction func login(sender: AnyObject) {
        if let email = userEmail.text
        {
            if let pass = userPassword.text
            {
                OAUTHHelper.Auth2UserLogin(email, userPassword: pass)
            }
        }
    }
    
    func newLoginStatus(status : OAUTHHelper.LOGIN_STATUS, messages : [String]) {
        var style : STYLES.FontStyle?
        switch status
        {
        case OAUTHHelper.LOGIN_STATUS.Success:
            print("[ ] AccountViewController.newLoginStatus() success.")
            style = STYLES.SUCCESS
        case OAUTHHelper.LOGIN_STATUS.Failure:
            print("[ ] AccountViewController.newLoginStatus() failure.")
            style = STYLES.FAILURE
        default:
            print("[ ] AccountViewController.newLoginStatus() default.")
            style = STYLES.WARNING
        }
        print("[ ] AccountViewController.newLoginStatus() login status: \(status), message: \(messages), style: \(style)")
        NSOperationQueue.mainQueue().addOperationWithBlock({
            var all_msg : String = "\r"
            for msg in messages
            {
                all_msg += msg + "\r"
            }
            self.userLoginStatus.text = all_msg
            STYLES.SetLabelStyle(self.userLoginStatus, style: style!, invert: true)
        })
    }
}