//
//  ViewController.swift
//  video_test2
//
//  Created by DASON ADAMOS on 12/2/15.
//  Copyright © 2015 DASON ADAMOS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var infoView : UIViewController?
    
    let VIEW_WIDTH : CGFloat = UIScreen.mainScreen().bounds.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.grayColor()
        print("[ ] ViewController.viewDidLoad()")
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Get an instance of the view to overlay (InfoViewController), then
        // put it in the view, attaching it to the view hierarchy in an appropriate manner
        //
        infoView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("InfoViewController")
        if let infoView_ = infoView
        {
            addChildViewController(infoView_)
            let infoViewFrame = CGRectMake(VIEW_WIDTH - 10, 0, VIEW_WIDTH, self.view.frame.height)
            infoView_.view.frame = infoViewFrame
            self.view.addSubview(infoView_.view)
            infoView_.didMoveToParentViewController(self)
        }

        
        // Now attach gesture recognizer to allow user to swipe the
        // InfoViewController into the view
        let panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "swipeInfoViewController:")
        self.view.addGestureRecognizer(panRecognizer)
    }
    
    /*
    
    swipeInfoViewController() - handle the motion of swiping. This moves the InfoViewController into
        the view from the right as the user swipes to the left and handles moving InfoViewController
        back to the right when the user swipes to the right.
    
    */
    func swipeInfoViewController (recognizer : UIPanGestureRecognizer) {
        let translation : CGPoint = recognizer.translationInView(self.view)
        print("[ ] ViewController.swipeInfoViewController: \(translation) \(self)")
        if let infoView_ = infoView
        {
            // If the user is swiping the view to the left
            if translation.x < 0
            {
                // Pull the view all the way to the left if
                // it is already halfway through
                if infoView_.view.frame.origin.x < (VIEW_WIDTH / 2)
                {
                    // Animate the rest of the motion
                    UIView.animateWithDuration(0.25, animations: {
                        infoView_.view.frame.origin.x = 0
                    })
                }
                else
                {
                    infoView_.view.frame.offsetInPlace(dx: translation.x, dy: 0)
                }
            }
            // If the user is swiping to the right
            else
            {
                // If it is halfway to the right, pull the 
                // view all the way to the right and hide it
                if infoView_.view.frame.origin.x > (VIEW_WIDTH / 2)
                {
                    // Animate this view's motion
                    UIView.animateWithDuration(0.25, animations: {
                        infoView_.view.frame.origin.x = self.VIEW_WIDTH
                    })
                }
                else
                {
                    infoView_.view.frame.offsetInPlace(dx: translation.x, dy: 0)
                }

            }


        }
        recognizer.setTranslation(CGPointMake(0,0), inView: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

