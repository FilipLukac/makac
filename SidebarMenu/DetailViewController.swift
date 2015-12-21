//
//  ActivityViewController.swift
//  Makac
//
//  Created by Filip Lukac on 13/12/15.
//  Copyright © 2015 Hardsun. All rights reserved.
//

import UIKit
import Social

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    @IBAction func shareTwitter(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            if let detail = self.detailItem {
                let name = detail["name"] as! String
                let distance = detail["distance"] as! String
                let duration = detail["duration"] as! String
                let string = "[" + name + "] I ran " + distance + " and my time was " + duration;
                
                twitterSheet.setInitialText(string)
                self.presentViewController(twitterSheet, animated: true, completion: nil)
            }
            
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func shareFacebook(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            if let detail = self.detailItem {
                let name = detail["name"] as! String
                let distance = detail["distance"] as! String
                let duration = detail["duration"] as! String
                let string = "[" + name + "] I ran " + distance + " and my time was " + duration;
                
                facebookSheet.setInitialText(string)
                self.presentViewController(facebookSheet, animated: true, completion: nil)
            }
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    var detailItem: AnyObject? {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            let name = detail["name"] as! String
            let distance = detail["distance"] as! String
            let duration = detail["duration"] as! String
            
            self.title = name
            self.detailDescriptionLabel?.text = name
            self.durationLabel?.text = duration
            self.distanceLabel?.text = distance
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}