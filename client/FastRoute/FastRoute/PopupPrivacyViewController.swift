//
//  PopupPrivacyViewController.swift
//  FastRoute
//
//  Created by apple on 9/9/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

class PopupPrivacyViewController: UIViewController {

    @IBOutlet weak var closeModalImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var popDelegate: FlipsideViewControllerDelegate?

    override func viewDidLoad() {
        DLog("PopupViewController.viewDidLoad")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("closeModal"))
        closeModalImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeModal() {
//        DLog("closeModal called")
        popDelegate?.flipsideViewControllerDidFinish(self)
    }
}
