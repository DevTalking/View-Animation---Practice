//
//  ViewController.swift
//  View Animation - Practice
//
//  Created by JaceFu on 15/7/10.
//  Copyright © 2015年 DevTalking. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var devtalkingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func start(sender: AnyObject) {
        let devtalkingLabelCopy = UILabel(frame: self.devtalkingLabel.frame)
        devtalkingLabelCopy.alpha = 0
        devtalkingLabelCopy.text = self.devtalkingLabel.text
        devtalkingLabelCopy.font = self.devtalkingLabel.font
        devtalkingLabelCopy.textAlignment = self.devtalkingLabel.textAlignment
        devtalkingLabelCopy.textColor = self.devtalkingLabel.textColor
        devtalkingLabelCopy.backgroundColor = UIColor.clearColor()
        devtalkingLabelCopy.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.1), CGAffineTransformMakeTranslation(1.0, self.devtalkingLabel.frame.height / 2))
        self.view.addSubview(devtalkingLabelCopy)
        UIView.animateWithDuration(1, animations: {
            self.devtalkingLabel.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.5), CGAffineTransformMakeTranslation(1.0, -self.devtalkingLabel.frame.height / 2))
            self.devtalkingLabel.alpha = 0
            devtalkingLabelCopy.alpha = 1
            devtalkingLabelCopy.transform = CGAffineTransformIdentity
        })
    }
}

