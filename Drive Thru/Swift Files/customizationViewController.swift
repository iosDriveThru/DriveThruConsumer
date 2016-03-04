//
//  customizationViewController.swift
//  Drive Thru
//
//  Created by Nanite on 22/01/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit

class customizationViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var ProductCustomization:productDetails?
    var storedOffsets = [Int: CGFloat]()
    let cBufferWidth:Int = 5
    var selected:Bool = false
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var customCell:customTableViewCell = customTableViewCell()
    var isComingFromPreference:Bool = false
    var arrayCustomizationSelected:[Bool] = []
    
    @IBOutlet var merchantImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var imgItem: UIImageView!
    @IBOutlet var btnComplete: UIButton!
    @IBOutlet var lblTotal: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        displayMerchantImage()
        displayProductImage()
        tableView.dataSource = self
        tableView.delegate = self
        btnComplete.layer.borderWidth = 1.0
        btnComplete.layer.cornerRadius = 5.0
        btnComplete.layer.borderColor = UIColor(red: 46/255, green: 115/255, blue: 252/255, alpha: 1.0).CGColor
        lblProductName.text = ProductCustomization?.productName
        lblProductName.layer.cornerRadius = 6
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayProductImage()
    {
        let imageName = ProductCustomization?.productImage
        let url = NSURL(string: imageName!)
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
                    self.imgItem.image = image
                    
                    // }
                })
                
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
        })
        
        
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

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath) as! customTableViewCell
        var labelToRemove: UIView!
        for aLabel: UIView in cell.subviews{
            if (aLabel is UILabel) {
                labelToRemove = aLabel
            }
        }
        if let subview = labelToRemove
        {
            subview.removeFromSuperview()
        }
        cell.lblCategory.text = self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[indexPath.row].ProductCategoryName
        var customizationPrice:Double = 0.0
        for index in 0...(self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails.count)!-1
        {
            for insideIndex in 0...(self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue.count)!-1
            {
                if self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].customisationIsSelected == true
                {
                    customizationPrice = customizationPrice + (self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].CustomizationPrice)!
                }
            }
        }
        lblTotal.text =  "Total ₹\(customizationPrice)"
        
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var Count: Int = 0
        
        if let countValue: Int = Int((self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails.count)!)
        {
            Count = countValue
        }
        
        return Count
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let tableViewCell = cell as? customTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let tableViewCell = cell as? customTableViewCell else { return }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
}
extension customizationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[collectionView.tag].CategoryValue.count)!
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! collectionViewCell
        var labelToRemove: UIView!
        for aLabel: UIView in cell.subviews{
            if (aLabel is UILabel) {
                labelToRemove = aLabel
            }
        }
        if let subview = labelToRemove
        {
            subview.removeFromSuperview()
        }
        
        for object in cell.contentView.subviews
        {
            object.removeFromSuperview();
        }
        collectionView.pagingEnabled = true
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 0.3
        btnComplete.layer.borderColor = UIColor.lightGrayColor().CGColor
        let lblLabel:UILabel = UILabel()
        lblLabel.font = lblLabel.font.fontWithSize(12)
        lblLabel.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)
        lblLabel.text = self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[collectionView.tag].CategoryValue[indexPath.row].StoreAliasName
        if self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[collectionView.tag].CategoryValue[indexPath.row].customisationIsSelected == true
        {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = cell.bounds
            gradient.colors = [UIColor(red: 153/255, green: 102/255, blue: 50/255, alpha: 1).CGColor, UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).CGColor]
            cell.layer.insertSublayer(gradient, atIndex: 0)
            cell.layer.cornerRadius = 8
            
            
        }
        else if self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[collectionView.tag].CategoryValue[indexPath.row].customisationIsSelected == false
        {
            var layerToRemove: CAGradientLayer!
            for aLayer: CALayer in cell.layer.sublayers! {
                if (aLayer is CAGradientLayer) {
                    layerToRemove = aLayer as! CAGradientLayer
                }
            }
            if let layer = layerToRemove
            {
                layer.removeFromSuperlayer()
            }
            
        }
        
        lblLabel.textAlignment = .Center
        cell.addSubview(lblLabel)
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        
        let collectionViewWidth = ((collectionView.frame.width) - 15)
        let totalBufferLength = (self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[collectionView.tag].CategoryValue.count)! * cBufferWidth
        let usableCollectionViewWidth = collectionViewWidth - CGFloat(totalBufferLength)
        return CGSize(width: Int(usableCollectionViewWidth)/(self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[collectionView.tag].CategoryValue.count)!, height: Int(collectionView.frame.size.height))
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell : UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)!
        if self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[collectionView.tag].CategoryValue[indexPath.row].customisationIsSelected == false
        {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = cell.bounds
            gradient.colors = [UIColor(red: 153/255, green: 102/255, blue: 50/255, alpha: 1).CGColor, UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).CGColor]
            cell.layer.insertSublayer(gradient, atIndex: 0)
            cell.layer.cornerRadius = 8
            print("Collection view at row \(collectionView.tag) selected index path \([indexPath.item])")
            cell.layer.cornerRadius = 8
            self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[collectionView.tag].CategoryValue[indexPath.row].customisationIsSelected = true
            
        }
        else if self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[collectionView.tag].CategoryValue[indexPath.row].customisationIsSelected == true
        {
            var layerToRemove: CAGradientLayer!
            for aLayer: CALayer in cell.layer.sublayers! {
                if (aLayer is CAGradientLayer) {
                    layerToRemove = aLayer as! CAGradientLayer
                }
            }
            if let layer = layerToRemove
            {
                layer.removeFromSuperlayer()
            }
            self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[collectionView.tag].CategoryValue[indexPath.row].customisationIsSelected = false
        }
        var customizationPrice:Double = 0.0
        for index in 0...(self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails.count)!-1
        {
            for insideIndex in 0...(self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue.count)!-1
            {
                if self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].customisationIsSelected == true
                {
                    customizationPrice = customizationPrice + (self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].CustomizationPrice)!
                }
            }
        }
        lblTotal.text =  "Total ₹\(customizationPrice)"
        //  productcustomizationvalue.Selected = true
        
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let Cell = collectionView.cellForItemAtIndexPath(indexPath)!
        selected = false
        self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[collectionView.tag].CategoryValue[indexPath.row].customisationIsSelected = false
        Cell.backgroundColor = UIColor .whiteColor()
        //  productcustomizationvalue.Selected = false
        var layerToRemove: CAGradientLayer!
        for aLayer: CALayer in Cell.layer.sublayers! {
            if (aLayer is CAGradientLayer) {
                layerToRemove = aLayer as! CAGradientLayer
            }
        }
        if let layer = layerToRemove
        {
            layer.removeFromSuperlayer()
        }
        
    }
    @IBAction func custComplete(sender: AnyObject) {
        let value = ProductCustomization!.SourceType
        var arrayOfMappedDictKey = value.characters.split{$0=="_"}.map(String.init)
        let source = arrayOfMappedDictKey[1]
        
        if source == "Menu"
        {
            ProductCustomization?.SourceType = "\(ProductCustomization!.SourceIndex)_Menu_Cust"
        }
        else if source == "Preference"{
            ProductCustomization?.SourceType = "\(ProductCustomization!.SourceIndex)_Preference_Cust"
        }
        
        for index in 0...(self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails.count)!-1
        {
            for insideIndex in 0...(self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue.count)!-1
            {
                arrayCustomizationSelected.append((self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].customisationIsSelected)!)
                if self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].customisationIsSelected == true
                {
                    ProductCustomization?.SourceType = (ProductCustomization?.SourceType)! + "_\((self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].StoreAliasName)!)"
                    ProductCustomization?.isCustomized = true
                    appDelegate.isMenuChanged = true
                }
            }
        }
        
        
        if arrayCustomizationSelected.contains(true)
        {
            ProductCustomization?.isCustomized = true
            appDelegate.isMenuChanged = true
        }
        else
        {
            ProductCustomization?.isCustomized = false
            appDelegate.isMenuChanged = false
            
        }
        
        if source == "Menu"
        {
            self.appDelegate.menuJson.products[(ProductCustomization?.SourceIndex)!] = ProductCustomization!
        }
        else if source == "Preference"{
            self.appDelegate.preferenceJson.products[(ProductCustomization?.SourceIndex)!] = ProductCustomization!
        }
        if !isComingFromPreference{
            self.performSegueWithIdentifier("SegueCustomizationToOrderPlacement", sender: self)
        }
        else{
            self.appDelegate.menuJson.products[(ProductCustomization?.SourceIndex)!].alreadyInPreference = true
            appDelegate.originalMenuJson.products[(ProductCustomization?.SourceIndex)!].alreadyInPreference = true
            self.appDelegate.preferenceJson.products.append(ProductCustomization!)
            performSegueWithIdentifier("segCustomizationToPreference", sender: self)
        }
    }
    
    @IBAction func custCancel(sender: AnyObject) {
        if !isComingFromPreference{
            self.performSegueWithIdentifier("SegueCustomizationToOrderPlacement", sender: self)
        }
        else{
            self.appDelegate.menuJson.products[(ProductCustomization?.SourceIndex)!] = ProductCustomization!
            performSegueWithIdentifier("segCustomizationToPreference", sender: self)
        }
    }
    
    @IBAction func customizationClear(sender: AnyObject) {
        ProductCustomization?.isCustomized = false
        
        for index in 0...(self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails.count)!-1
        {
            for insideIndex in 0...(self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue.count)!-1
            {
                self.ProductCustomization?.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[insideIndex].customisationIsSelected = false
            }
            
        }
        
        let value = ProductCustomization!.SourceType
        var arrayOfMappedDictKey = value.characters.split{$0=="_"}.map(String.init)
        let source = arrayOfMappedDictKey[1]
        
        if source == "Menu"
        {
            
            appDelegate.menuJson.products[(ProductCustomization?.SourceIndex)!] = ProductCustomization!
        }
        else if source == "Preference"
        {
            appDelegate.preferenceJson.products[(ProductCustomization?.SourceIndex)!] = ProductCustomization!
        }
        tableView.clearsContextBeforeDrawing = true
        // customCell.cv.clearsContextBeforeDrawing = true
        tableView.reloadData()
        
        
        
        
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "SegueCustomizationToOrderPlacement")
        {
            let value = ProductCustomization!.SourceType
            var arrayOfMappedDictKey = value.characters.split{$0=="_"}.map(String.init)
            let sourceIndex = arrayOfMappedDictKey[0]
            let source = arrayOfMappedDictKey[1]
            
            let destinationVC = segue.destinationViewController as! OrderPlacementViewController
            destinationVC.fromCustSourceType = (ProductCustomization?.SourceType)!
            destinationVC.segueCustomization = true
            if source == "Menu"
            {
                destinationVC.setSourceType = ProductCustomization!.SourceType
            }
            else if source == "Preference"
            {
                destinationVC.setSourceType = ProductCustomization!.SourceType
            }
        }
        
        if (segue.identifier == "segCustomizationToPreference")
        {
            let value = ProductCustomization!.SourceType
            var arrayOfMappedDictKey = value.characters.split{$0=="_"}.map(String.init)
            let sourceIndex = arrayOfMappedDictKey[0]
            let source = arrayOfMappedDictKey[1]
            let destinationVC = segue.destinationViewController as! PreferenceViewController
            destinationVC.fromCustSourceType = (ProductCustomization?.SourceType)!
            if arrayCustomizationSelected.contains(true)
            {
                destinationVC.isComingFromCustomization = true
                destinationVC.isPrefereceCancelButtonClicked = false
            }
            else
            {
                destinationVC.isComingFromCustomization = true
                destinationVC.isPrefereceCancelButtonClicked = true
                
            }
            
            
        }
        
        
    }
    
}
