//
//  StoresViewController.swift
//  Drive Thru
//
//  Created by Nanite Solutions on 2/22/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit

class StoresViewController: UIViewController {
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet var imgImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapDetected:"))
        singleTap.numberOfTapsRequired = 1
        imgImageView.addGestureRecognizer(singleTap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapDetected(gestureRecognizer: UITapGestureRecognizer) {
        if let tagSelected:Int = gestureRecognizer.view?.tag
        {
           // getMerchantPreferenceitems(1)
            getMerchantMenuitems(1)
            
        }
    }
    
    
    func getMerchantPreferenceitems(merchantID: Int)
    {
        DataManager.getDataFromRestfullWithSuccess("http://sqweezy.com/DriveThru/Get_Preference.php?merchant_id=\(merchantID)&consumer_id=5") { (data) -> Void in
            var json: [String: AnyObject]!
            
            //  DataManager.getTopAppsDataFromFileWithSuccess { (data) -> Void in
            //      var json: [String: AnyObject]!
            
            
            // 1
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject]
            } catch {
                print(error)
                
            }
            
            // 2
            if let pref = Preference(json: json)
            {
                self.appDelegate.preferenceJson = pref
                for outsideIndex in 0...self.appDelegate.preferenceJson.products.count-1
                {
                    self.appDelegate.preferenceJson.products[outsideIndex].SourceType = "\(outsideIndex)_Preference_Cust"
                    self.appDelegate.preferenceJson.products[outsideIndex].productImage = self.appDelegate.preferenceJson.products[outsideIndex].productImage.stringByReplacingOccurrencesOfString("upload", withString: "upload/h_100,w_100,r_8")
                    self.appDelegate.preferenceJson.products[outsideIndex].productImage = self.appDelegate.preferenceJson.products[outsideIndex].productImage.stringByReplacingOccurrencesOfString("jpg", withString: "png")
                    for index in 0...(self.appDelegate.preferenceJson.products[outsideIndex].customizationDetails.CustomizationcategoryDetails.count)-1
                    {
                        for insideIndex in 0...(self.appDelegate.preferenceJson.products[outsideIndex].customizationDetails.CustomizationcategoryDetails[index].CategoryValue.count)-1
                        {
                            if self.appDelegate.preferenceJson.products[outsideIndex].customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].customisationIsSelected == true
                            {
                                self.appDelegate.preferenceJson.products[outsideIndex].SourceType = (self.appDelegate.preferenceJson.products[outsideIndex].SourceType) + "_\((self.self.appDelegate.preferenceJson.products[outsideIndex].customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].StoreAliasName))"
                                self.appDelegate.preferenceJson.products[outsideIndex].isCustomized = true
                                //self.appDelegate.isMenuChanged = true
                            }
                        }
                        
                    }
                }
            }
            else {
                print("Error initializing object")
                return
            }
            
        }
    }
    func getMerchantMenuitems(merchantID:Int)
    {
        DataManager.getDataFromRestfullWithSuccess("http://sqweezy.com/DriveThru/get_menu.php?merchant_id=\(merchantID)&consumer_id=25") { (data) -> Void in
            var json: [String: AnyObject]!
            // 1
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject]
            } catch {
            }
            // 2
            if let menu = Menu(json: json)
            {
                self.appDelegate.menuJson = menu
                for index in 0...self.appDelegate.menuJson.products.count-1
                {
                    self.appDelegate.menuJson.products[index].SourceType = "\(index)_Menu"
                    self.appDelegate.menuJson.products[index].productImage = self.appDelegate.menuJson.products[index].productImage.stringByReplacingOccurrencesOfString("upload", withString: "upload/h_100,w_100,r_8")
                    self.appDelegate.menuJson.products[index].productImage = self.appDelegate.menuJson.products[index].productImage.stringByReplacingOccurrencesOfString("jpg", withString: "png")
                }
                self.appDelegate.originalMenuJson = self.appDelegate.menuJson
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("segStoretoPreference", sender: self)
                })
            }
            else {
                return
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
    
}
