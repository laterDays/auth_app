//
//  InfoViewController.swift
//  video_test2
//
//  Created by DASON ADAMOS on 12/2/15.
//  Copyright © 2015 DASON ADAMOS. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    @IBOutlet weak var fileLocation: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dragInfoViewController (recognizer: UIPanGestureRecognizer) {
        let translation: CGPoint = recognizer.translationInView(self.view)
        recognizer.view?.center = CGPointMake((recognizer.view?.center.x)! + translation.x, (recognizer.view?.center.y)! + translation.y)
        recognizer.setTranslation(CGPointMake(0, 0), inView: self.view)
    }
}