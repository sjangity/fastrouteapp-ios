//
//  TutorialScreen.swift
//  FastRoute
//
//  Created by apple on 8/18/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

class TutorialScreen: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var screenNumber: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var nibName = "TutorialScreen"
    var view: UIView!
    var itemIndex: Int = 0 {
        didSet {
//            screenNumber.text = "Screen \(itemIndex)"
        }
    
    }
    var imageName: String = "" {
        didSet {
            if let imageView = imageView {
//                DLog("image name set, so lets update image - \(imageName)")
                var image = UIImage(named: imageName)
                imageView.image = image
//                DLog(image)
            } else {
                DLog("no image to set")
            }
            
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // extra logic after init
        setup();
    }

    required init(coder aDecoder: NSCoder) { // storyboard or UI file
        super.init(coder: aDecoder)
        
        setup()
    }
    
    @IBAction func letsGoButtonPressed(sender: AnyObject) {
//        DLog("lets go button pressed")
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKey.TutorialFinishedNotification, object: nil)
    }
    
    func setup() {
//        DLog("loading screen from nib")
    
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(view)
//        view.backgroundColor = UIColor.yellowColor()
//        imageView!.image = UIImage(named: imageName)
        pageControl.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, 100, 100)
        
        styleButtons()
    }

    func styleButtons() {        
        for aView in view.subviews.filter({$0.isKindOfClass(UIButton)}) as! [UIButton] {
            aView.styledGreen()
        }
    }

    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView

        return view
    }
}
