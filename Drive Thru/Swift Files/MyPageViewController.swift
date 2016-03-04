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
        
        if orderVC.isOrderPlaced == true
        {
           btnToken.setImage(UIImage(named: "Token.png"), forState: .Normal)
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
    
}
/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
// Get the new view controller using segue.destinationViewController.
// Pass the selected object to the new view controller.
}
*/


