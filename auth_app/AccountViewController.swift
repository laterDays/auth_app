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
    
    func newLoginStatus(status : OAUTHHelper.LOGIN_STATUS, message : String) {
        userLoginStatus.text = status.rawValue
    }
}