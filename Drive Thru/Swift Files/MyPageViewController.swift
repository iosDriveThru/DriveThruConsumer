//
//  MyPageViewController.swift
//  Drive Thru
//
//  Created by Nanite Solutions on 1/2/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit
import CoreData
class MyPageViewController: UIViewController {
    var userDetailsObject = [NSManagedObject]()
    let defaults = NSUserDefaults.standardUserDefaults()
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var orderVC = OrderPlacementViewController()
    @IBOutlet var imgUserProfileImage: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblMailId: UILabel!
    @IBOutlet var btnToken: UIButton!
    @IBOutlet var merchantImageView: UIImageView!
    @IBOutlet var btnTokenMenu: UIButton!
    
    @IBAction func ClickTokenMenu(sender: AnyObject) {
        self.appDelegate.cartJson.products = []
        if btnTokenMenu.currentImage  == UIImage(named: "Token.png")
        {
            
            self.performSegueWithIdentifier("segueMyProfileToToken", sender: self)
        }
        else
            
        {
            
            let alertController = UIAlertController(title: "Drive-Thru", message: "No Active Token!", preferredStyle: .Alert)
            
            // Create the actions
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
                
                {
                    
                    UIAlertAction in
                    
            }
            
            
            
            // Add the actions
            
            alertController.addAction(okAction)
            
            // Present the controller
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if appDelegate.isPreferenceChanged
        {
            DataManager.setPreference()
        }
        imgUserProfileImage.layer.cornerRadius = self.imgUserProfileImage.frame.size.width / 2
        imgUserProfileImage.clipsToBounds = true
        getUserDetails()
        displayMerchantImage()
        if let orderProgress:Bool = defaults.objectForKey("isOrderInProgress") as? Bool
        {
            if orderProgress == true
            {
                btnToken.setImage(UIImage(named: "Token.png"), forState: .Normal)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func  getUserDetails()
    {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        //2
        let fetchRequest = NSFetchRequest(entityName: "UserDetails")
        //3
        do {
            let results:NSArray =
            try managedContext.executeFetchRequest(fetchRequest)
            userDetailsObject = results as! [NSManagedObject]
            if results.count > 0{
                let res = results[results.count-1] as! NSManagedObject
                if let name:String =  res.valueForKey("userName") as? String
                {
                    lblUserName.text = name
                }
                if let EmailId:String =  res.valueForKey("email") as? String
                {
                    lblMailId.text = EmailId
                }
                if let userProfilePicture:String =  res.valueForKey("userProfileImage") as? String
                {
                    if let url = NSURL(string: userProfilePicture) {
                        if let data = NSData(contentsOfURL: url){
                            self.imgUserProfileImage.image = UIImage(data: data)
                            defaults.setValue(data, forKey: "userProfilePicture")
                        }
                    }
                }
                
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    func displayMerchantImage()
    {
        let imageName = self.appDelegate.MerchantImageUrlString
        let url = NSURL(string: imageName)
        let request: NSURLRequest = NSURLRequest(URL: url!)
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                // Convert the downloaded data in to a UIImage object
                let image = UIImage(data: data!)
                // Store the image in to our cache
                // Update the cell
                dispatch_async(dispatch_get_main_queue(), {
                    // if let cellToUpdate = menuCV.cellForRowAtIndexPath(indexPath) as? menuCollectionViewCell {
                    // cellToUpdate.imageView?.image = image
                    self.merchantImageView.image = image
                    
                    // }
                })
                
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
        })
        
        
    }
    
}

/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
// Get the new view controller using segue.destinationViewController.
// Pass the selected object to the new view controller.
}
*/


