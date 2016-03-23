//
//  PreferenceViewController.swift
//  Drive Thru
//
//  Created by Nanite Solutions on 2/10/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit

class PreferenceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var setSourceType:String = "Menu"
    var totalAmount:Double = 0.0
    var imageCache:NSCache = NSCache()
    var customizationIndex:Int = Int()
    var isComingFromCustomization = false
    var isPrefereceCancelButtonClicked = false
    var fromCustSourceType: String = ""
    @IBOutlet var merchantImageView: UIImageView!
    @IBOutlet var menuCV: UICollectionView!
    @IBOutlet weak var lblTotalPriceCart: UILabel!
    @IBOutlet var lblDisplayCustomization: UILabel!
    @IBOutlet var segmentCustomizationYesNo: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        menuCV.delegate = self
        menuCV.dataSource = self
        displayMerchantImage()
        
        if isComingFromCustomization
        {
            let value = self.fromCustSourceType
            print(value)
            var arrayOfMappedDictKey = value.characters.split{$0=="_"}.map(String.init)
            let indexPathRow = Int(arrayOfMappedDictKey[0])
            menuCV.reloadData()
            self.menuCV.layoutIfNeeded()
            self.menuCV.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPathRow! , inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
            segmentCustomizationYesNo.selected = false
            lblDisplayCustomization.hidden = false
            if isPrefereceCancelButtonClicked{
                lblDisplayCustomization.text = "Added to your preference list."
            }
            else{
                lblDisplayCustomization.text = "Added to your preference list with personalization."}
            // print(appDelegate.preferenceJson.products[0])
            
            
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCustomization_Click(sender: AnyObject) {
    }
    @IBAction func btnAddPreference_Click(sender: AnyObject) {
    }
    @IBAction func segmentCustomizationYesNo_Click(sender: AnyObject) {
        if(segmentCustomizationYesNo.selectedSegmentIndex == 0){
            let index = appDelegate.preferenceJson.products.count
            appDelegate.menuJson.products[sender.tag].alreadyInPreference = true
            appDelegate.originalMenuJson.products[sender.tag].alreadyInPreference = true
            addToPreference(index)
            lblDisplayCustomization.hidden = false
            segmentCustomizationYesNo.hidden = true
            segmentCustomizationYesNo.selected = false
            lblDisplayCustomization.text = "Added to your preference list."
        }
        else if(segmentCustomizationYesNo.selectedSegmentIndex == 1){
            
            // lblDisplayCustomization.hidden = false
            segmentCustomizationYesNo.hidden = true
            segmentCustomizationYesNo.selected = false
            //  lblDisplayCustomization.text = "Added to your preference list with personalization"
            performSegueWithIdentifier("segPreferencetoCustomize", sender: self)
        }
        segmentCustomizationYesNo.selected = false
        
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.menuJson.products.count
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
           
             return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height-20)
            
         
            
            
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        //let bounds = UIScreen.mainScreen().bounds
        
        
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("menuCell",forIndexPath: indexPath) as UICollectionViewCell
        
        let imageName = appDelegate.menuJson.products[indexPath.row].productImage
        let productName = appDelegate.menuJson.products[indexPath.row].productName
        var productPrice: Double = 0
        
        
        productPrice = appDelegate.menuJson.products[indexPath.row].productPrice
        
        if let menuCell = cell as? menuCollectionViewCell {
            //menuCell.itemsimageview.frame.size.width = cell.frame.size.width
            menuCell.btnAddToPreference.hidden = false
            
            if appDelegate.menuJson.products[indexPath.row].CustomizationAvailable == true
            {
                
                if appDelegate.menuJson.products[indexPath.row].isCustomized == true
                {
                    menuCell.btnCustomization.setImage(UIImage(named: "Customize_Selected.png") ,forState: .Normal)
                }
                else
                {
                    menuCell.btnCustomization.setImage(UIImage(named: "Customize_UnSelected.png") ,forState: .Normal)
                }
                menuCell.btnCustomization.userInteractionEnabled = true
            }
            else
            {
                menuCell.btnCustomization.setImage(UIImage(named: "NoCustomizationAvailable.png") ,forState: .Normal)
                menuCell.btnCustomization.userInteractionEnabled = false
                
            }
            if (appDelegate.menuJson.products[indexPath.row].alreadyInPreference == false)
            {
                menuCell.btnAddToPreference.setImage(UIImage(named: "UnselectedPreference.png"), forState: .Normal)
            }
            else if(appDelegate.menuJson.products[indexPath.row].alreadyInPreference == true)
            {
                menuCell.btnAddToPreference.setImage(UIImage(named: "SelectedPreference.png"), forState: .Normal)
                // lblDisplayCustomization.hidden = false
                //                        if appDelegate.menuJson.products[indexPath.row].isCustomized == true
                //                        {
                //
                //                            lblDisplayCustomization.text = "Added to your preference list with customization"
                //                        }
                //                        else
                //                        {
                //                            lblDisplayCustomization.text = "Added to your preference list"
                //                        }
            }
            let url = NSURL(string: imageName)
            if let img:UIImage = imageCache.objectForKey(url!) as? UIImage {
                // cell.imageView?.image = img as UIImage
                menuCell.productImageView.image = img as UIImage
                
            }
            else {
                // The image isn't cached, download the img data
                // We should perform this in a background thread
                let request: NSURLRequest = NSURLRequest(URL: url!)
                let mainQueue = NSOperationQueue.mainQueue()
                NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                    if error == nil {
                        // Convert the downloaded data in to a UIImage object
                        let image = UIImage(data: data!)
                        // Store the image in to our cache
                        self.imageCache.setObject(image!, forKey: url!)
                        // Update the cell
                        dispatch_async(dispatch_get_main_queue(), {
                            // if let cellToUpdate = menuCV.cellForRowAtIndexPath(indexPath) as? menuCollectionViewCell {
                            // cellToUpdate.imageView?.image = image
                            menuCell.productImageView.image = image
                            
                            // }
                        })
                        
                    }
                    else {
                        print("Error: \(error!.localizedDescription)")
                    }
                })
            }
            
            menuCell.productName.text  = productName
            if appDelegate.menuJson.products[indexPath.row].isCustomized == true
            {
                for indexCatDetails in 0...appDelegate.menuJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails.count-1
                {
                    for index in 0...appDelegate.menuJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue.count-1                       {
                        if (appDelegate.menuJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue[index].customisationIsSelected)
                        {
                            productPrice = productPrice + appDelegate.menuJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue[index].CustomizationPrice
                        }
                        
                    }
                }
            }
            menuCell.productPrice.text = "₹ \(productPrice)"
            menuCell.btnAddToPreference.tag = indexPath.row
            menuCell.btnAddToPreference.addTarget(self, action: "AddOrRemovePreference:", forControlEvents: UIControlEvents.TouchUpInside)
            menuCell.btnCustomization.addTarget(self, action: "Customize:", forControlEvents: UIControlEvents.TouchUpInside)
            menuCell.btnCustomization.tag = indexPath.row
            
            menuCell.btnLeftMenuCell.addTarget(self, action: "ClickLeftArrowScrollButton:", forControlEvents: UIControlEvents.TouchUpInside)
            menuCell.btnLeftMenuCell.tag = indexPath.row
            menuCell.btnRightMenuCell.addTarget(self, action: "ClickRightArrowScrollButton:", forControlEvents: UIControlEvents.TouchUpInside)
            menuCell.btnRightMenuCell.tag = indexPath.row
            if indexPath.row == 0
            {
                menuCell.btnLeftMenuCell.hidden = true
                menuCell.btnRightMenuCell.hidden = false
            }
            else if indexPath.row == (appDelegate.menuJson.products.count)-1
            {
                menuCell.btnLeftMenuCell.hidden = false
                menuCell.btnRightMenuCell.hidden = true
                
            }
            else
            {
                menuCell.btnRightMenuCell.hidden = false
                menuCell.btnLeftMenuCell.hidden = false
                
            }
            if appDelegate.menuJson.products.count == 1
            {
                menuCell.btnRightMenuCell.hidden = true
                menuCell.btnLeftMenuCell.hidden = true
            }
            
            // gridCell.itemsimageview.addGestureRecognizer(DownSwipe)
        }
        
        return cell
    }
    
    
    func AddOrRemovePreference(sender: UIButton)
    {
        lblDisplayCustomization.hidden = true
        segmentCustomizationYesNo.selected = false
        var indexPreference:Int = 0
        var indexMenu:Int = 0
        
        indexMenu = sender.tag
        
        if sender.currentImage  == UIImage(named: "UnselectedPreference.png")
        {
            
            // addToPreference(index)
            checkCustomization(indexMenu)
            appDelegate.isPreferenceChanged = true
        }
        else if sender.currentImage  == UIImage(named: "SelectedPreference.png")
        {
            if (!appDelegate.preferenceJson.products.isEmpty)
            {
                for Index in 0...appDelegate.preferenceJson.products.count-1
                {
                    if appDelegate.menuJson.products[sender.tag].productId == appDelegate.preferenceJson.products[Index].productId
                    {
                        indexPreference = Index
                    }
                    
                }
                appDelegate.menuJson.products[indexMenu].alreadyInPreference = false
                removeFromPreference(indexPreference)
                appDelegate.isPreferenceChanged = true
            }
        }
    }
    func checkCustomization(Index:Int){
        let object = appDelegate.menuJson.products[Index]
        segmentCustomizationYesNo.tag = Index
        if object.CustomizationAvailable == true{
            lblDisplayCustomization.hidden = false
            segmentCustomizationYesNo.hidden = false
            lblDisplayCustomization.text = "Customization is available for this item, do you want to personalize it to your taste?"
        }
        else
        {
            // lblDisplayCustomization.hidden = false
            //            lblDisplayCustomization.text = "Customization is available for this item, do you want to personalize it to your taste?"
            appDelegate.menuJson.products[Index].alreadyInPreference = true
            appDelegate.originalMenuJson.products[Index].alreadyInPreference = true
            lblDisplayCustomization.hidden = false
            segmentCustomizationYesNo.hidden = true
            segmentCustomizationYesNo.selected = false
            lblDisplayCustomization.text = "Added to your preference list."
            addToPreference(Index)
        }
    }
    func addToPreference(Index: Int)
    {
        var object = appDelegate.menuJson.products[Index]
        let index = appDelegate.preferenceJson.products.count
        if object.CustomizationAvailable == true{
            
        }
        if(object.isCustomized == true)
        {
            //            lblDisplayCustomization.hidden = false
            //            segmentCustomizationYesNo.hidden = false
            //            lblDisplayCustomization.text = "Customization is available for this item, do you want to personalize it to your taste"
            object.SourceType = "\(index)_Preference_Cust"
            for index in 0...(object.customizationDetails.CustomizationcategoryDetails.count)-1
            {
                for insideIndex in 0...(object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue.count)-1
                {
                    if object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].customisationIsSelected == true
                    {
                        object.SourceType = (object.SourceType) + "_\((object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].StoreAliasName))"
                        object.isCustomized = true
                        appDelegate.isMenuChanged = true
                    }
                }
            }
        }
        else
        {
            //            lblDisplayCustomization.hidden = true
            //            segmentCustomizationYesNo.hidden = true
            object.SourceType = "\(index)_Preference"
        }
        if (appDelegate.preferenceJson.products.count == 0) {
            appDelegate.preferenceJson.products = [object]
        }
        else
        {
            appDelegate.preferenceJson.products.append(object)
        }
        self.menuCV.reloadData()
    }
    
    func removeFromPreference(Index: Int)
    {
        let alertController = UIAlertController(title: "Drive-Thru", message: "Remove Item from Preference?", preferredStyle: .Alert)
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.appDelegate.preferenceJson.products.removeAtIndex(Index)
                self.menuCV.reloadData()
                // if yes
                // update restful
                
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
                NSLog("No Pressed")
                return
        }
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        // Present the controller
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    func ClickRightArrowScrollButton(sender: UIButton)
    {
        self.menuCV.scrollToItemAtIndexPath(NSIndexPath(forItem: sender.tag+1 , inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        
    }
    
    func ClickLeftArrowScrollButton(sender: UIButton){
        self.menuCV.scrollToItemAtIndexPath(NSIndexPath(forItem: sender.tag-1 , inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        
    }
    func Customize(sender: UIButton){
        customizationIndex = sender.tag
        self.performSegueWithIdentifier("segPreferencetoCustomize", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "segPreferencetoCustomize")
        {
            let destinationVC = segue.destinationViewController as! customizationViewController
            var passingItem = appDelegate.menuJson.products[customizationIndex]
            passingItem.SourceIndex = customizationIndex
            destinationVC.ProductCustomization = passingItem
            destinationVC.isComingFromPreference = true
        }
    }
    
    
}
extension PreferenceViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if(appDelegate.isMenuChanged)
        {
            appDelegate.menuJson = appDelegate.originalMenuJson
            appDelegate.isMenuChanged = false
            menuCV.reloadData()
            
        }
      
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if segmentCustomizationYesNo.hidden == false || lblDisplayCustomization.hidden == false
        {
            segmentCustomizationYesNo.hidden = true
            segmentCustomizationYesNo.selected = false
            lblDisplayCustomization.hidden = true
        }
    }
}
