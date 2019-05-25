//
//  HelpTableViewController.swift
//  FastRoute
//
//  Created by apple on 9/9/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit
import MessageUI

class HelpTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, FlipsideViewControllerDelegate {

    var customTransitioningDelegate: SpringTransitioningDelegate!

    var dimView: UIView!

    override func viewDidLoad() {
        DLog("HelpTableViewController.viewDidLoad")
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationItem.title = "Help & Support"
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        customTransitioningDelegate = SpringTransitioningDelegate(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Mail handler
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        var msg = ""
        switch result.value {
            case MFMailComposeResultCancelled.value:
                msg = "Mail cancelled";
                break;
            case MFMailComposeResultSaved.value:
                msg = "Mail saved";
                break;
            case MFMailComposeResultSent.value:
                msg = "Mail sent";
                break;
            case MFMailComposeResultFailed.value:
                msg = error.localizedDescription
                break;
            default:
                break;
        }
        DLog(msg)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showFeedbackButtonPressed(sender: AnyObject) {
        DLog("HelpTableViewController.showFeedbackButtonPressed")
        if MFMailComposeViewController.canSendMail() {
            var mfmController = MFMailComposeViewController()
            mfmController.mailComposeDelegate = self;
            mfmController.navigationBar.setBackgroundImage(UIImage(named: ""), forBarMetrics: UIBarMetrics.Default)
            mfmController.navigationBar.tintColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            mfmController.setSubject("Re: Feedback/Support")
            mfmController.setMessageBody(" ", isHTML: true)
            mfmController.setToRecipients(["support@fastrouteapp.com"])
            
            presentViewController(mfmController, animated: true, completion: nil)
        } else {
            DLog("error handling message")
        }
    }
    
    // MARK: Flip Delegate
    
    func flipsideViewControllerDidFinish(vc: UIViewController) {
        dimView.alpha = 0
        dimView.removeFromSuperview()
        dimView = nil
        
        self.view.userInteractionEnabled = true
        vc.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Transition Initializer
    
    func setupTransition(vc: UIViewController) {
        self.view.userInteractionEnabled = false
        
//        // transparent nav bar
//        var navController = self.parentViewController as! UINavigationController
//        var navBar = navController.navigationBar
//        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        navBar.shadowImage=UIImage()
//        navBar.translucent=true
        
        dimView = UIView(frame: self.view.frame)
        dimView.backgroundColor = UIColor.blackColor()
        dimView.alpha = 0
        view.addSubview(dimView)
        view.bringSubviewToFront(dimView)
        UIView.animateWithDuration(0.3) { () -> Void in
            self.dimView.alpha = 0.7
        }

        customTransitioningDelegate.transitioningDirection = TransitioningDirection.Down
        customTransitioningDelegate.presentViewController(vc)
        
//        transitioningDelegate=customTransitioningDelegate
    }

    @IBAction func showTutorialButtonPressed(sender: AnyObject) {
        var initialViewController: UIViewController!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        initialViewController = storyboard.instantiateViewControllerWithIdentifier("TutorialViewController") as! TutoriaViewController
        presentViewController(initialViewController, animated: true, completion: nil)
    }

    @IBAction func showPrivacyButtonPressed(sender: AnyObject) {
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("PrivacyVC") as! PopupPrivacyViewController
        vc.popDelegate=self
        setupTransition(vc)
    }

    @IBAction func showTermsButtonPressed(sender: AnyObject) {
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfServiceVC") as! PopupViewController
        vc.popDelegate=self
        setupTransition(vc)
    }
}
