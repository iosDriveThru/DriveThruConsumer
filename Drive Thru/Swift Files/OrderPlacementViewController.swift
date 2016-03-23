//

//  OrderPlacementViewController.swift

//  Drive Thru

//

//  Created by Nanite on 19/01/16.

//  Copyright © 2016 Nanite Solutions. All rights reserved.

//



import UIKit



class OrderPlacementViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var setSourceType:String = "Menu"
    var totalAmount:Double = 0.0
    var imageCache:NSCache = NSCache()
    var userMail: String = ""
    var userPhone: String = ""
    var customizationIndex:Int = Int()
    var fromCustSourceType:String = ""
    var segueCustomization:Bool = false
    var isOrderPlaced:Bool = false
    var progressBar:UIProgressView = UIProgressView()
    
    @IBOutlet weak var menuCV: UICollectionView!
    @IBOutlet weak var cartCV: UICollectionView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblTopBarMenu: UILabel!
    @IBOutlet weak var btnPlaceOrder: UIButton!
    @IBOutlet weak var lblTotalPriceCart: UILabel!
    @IBOutlet var merchantImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        progressBar.frame = CGRectMake(0.0, 0.0, 300.0, 300.0)
        progressBar.transform = CGAffineTransformMakeScale(1.0, 3.0)
        progressBar.trackTintColor = UIColor.lightGrayColor()
        progressBar.progressTintColor = UIColor.darkGrayColor()
        btnPlaceOrder.layer.borderWidth = 1.0
        btnPlaceOrder.layer.cornerRadius = 5.0
        btnPlaceOrder.layer.borderColor = UIColor(red: 21/255, green: 126/255, blue: 251/255, alpha: 1.0).CGColor
        displayMerchantImage()
        if let mailid: String = defaults.objectForKey("userMailId") as? String
        {
            self.userMail = mailid
        }
        if let phnumber: String = defaults.objectForKey("userPhoneNumber") as? String
        {
            self.userPhone = phnumber
        }
        if appDelegate.preferenceJson.products.isEmpty
        {
            setSourceType = "Menu"
        }
        else
        {
            setSourceType = "Preference"
        }
        if setSourceType == "Menu"
        {
            btnMenu.setImage(UIImage(named:"Hearts-100.png"), forState: .Normal)
        }
        else  if setSourceType == "Preference"
        {
            btnMenu.setImage(UIImage(named:"menu100_grey.png"), forState: .Normal)
        }
        menuCV.delegate = self
        menuCV.dataSource = self
        cartCV.delegate = self
        cartCV.dataSource = self
        if (segueCustomization)
        {
            ShowItemFromCust()
        }
        else
        {
            if appDelegate.isPreferenceChanged
            {
                DataManager.setPreference()
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function to Display merchant image
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.merchantImageView.image = image
                })
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
        })
    }
    //End- Function to Display merchant image
    
    //Function that executes when it comes from Customization ViewController to set Customization for respective product
    func ShowItemFromCust()
    {
        let value = self.fromCustSourceType
        var arrayOfMappedDictKey = value.characters.split{$0=="_"}.map(String.init)
        let indexPathRow = Int(arrayOfMappedDictKey[0])
        let sourceType = arrayOfMappedDictKey[1]
        if sourceType == "Menu"
        {
            setSourceType = "Menu"
            self.menuCV.reloadData()
            self.menuCV.layoutIfNeeded()
            btnMenu.setImage(UIImage(named:"Hearts-100.png"), forState: .Normal)
            self.menuCV.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPathRow! , inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        }
        else if sourceType == "Preference"
        {
            setSourceType = "Preference"
            btnMenu.setImage(UIImage(named:"menu100_grey.png"), forState: .Normal)
            self.menuCV.reloadData()
            self.menuCV.layoutIfNeeded()
            self.menuCV.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPathRow! , inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        }
        else if sourceType == "Cart"
        {
            setSourceType = "Cart"
            if appDelegate.PreviousSourceType == "Menu"
            {
            btnMenu.setImage(UIImage(named:"menu100_grey.png"), forState: .Normal)
            }
            else  if appDelegate.PreviousSourceType == "Preference"
            {
                btnMenu.setImage(UIImage(named:"Hearts-100.png"), forState: .Normal)
            }
            self.menuCV.reloadData()
            self.menuCV.layoutIfNeeded()
            self.menuCV.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPathRow! , inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        }
    }
    //Function that executes when it comes from Customization ViewController to set Customization for respective product
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var noOfItems = 0
        if collectionView == menuCV
        {
            if setSourceType == "Menu"
            {
                noOfItems = appDelegate.menuJson.products.count
            }
            else if setSourceType == "Preference"
            {
                noOfItems = appDelegate.preferenceJson.products.count
            }
            else if setSourceType == "Cart"
            {
                noOfItems = appDelegate.cartJson.products.count
            }
        }
        else if collectionView == cartCV
        {
            noOfItems = appDelegate.cartJson.products.count
        }
        return noOfItems
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == cartCV
        {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            if !(setSourceType == "Cart")
            {
            let currentIndexpath = self.menuCV.indexPathsForVisibleItems()
            appDelegate.PreviousSourceItemIndex = currentIndexpath[0].row
            appDelegate.PreviousSourceType = setSourceType
            if setSourceType == "Preference"
            {
             btnMenu.setImage(UIImage(named:"Hearts-100.png"), forState: .Normal)
            }
            else if setSourceType == "Menu"
            {
                btnMenu.setImage(UIImage(named:"menu100_grey.png"), forState: .Normal)
            }
                self.menuCV.reloadData()

            }
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                
                cell!.transform = CGAffineTransformMakeScale(1.3,1.3)
                cell!.layer.shadowColor = UIColor.blackColor().CGColor
                cell!.layer.shadowOffset = CGSizeMake(5, 5)
                cell!.layer.shadowRadius = 5
                cell!.layer.shadowOpacity = 1.0
                cell!.layer.masksToBounds = false
                
            })
            let indexPathRow = indexPath.row
            
            setSourceType = "Cart"
            self.menuCV.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPathRow , inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
  
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)
    {
        if collectionView == cartCV
        {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
             UIView.animateWithDuration(0.3, animations: { () -> Void in
            cell!.transform = CGAffineTransformMakeScale(1,1)
                cell!.layer.shadowOpacity = 0.0

                })
        }
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            var cellSize:CGSize = CGSize()
            if collectionView == menuCV
            {
            cellSize = CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height-20)
            }
            else if collectionView == cartCV
            {
             cellSize =  CGSizeMake(collectionView.bounds.size.width/4, collectionView.bounds.size.height-10)
            }
            
         return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if collectionView == menuCV
        {
            if setSourceType == "Menu"
            {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier("menuCell",forIndexPath: indexPath) as UICollectionViewCell
                let imageName = appDelegate.menuJson.products[indexPath.row].productImage
                let productName = appDelegate.menuJson.products[indexPath.row].productName
                var productPrice: Double = 0
                productPrice = appDelegate.menuJson.products[indexPath.row].productPrice
                let addToCartSelector = Selector("AddItemToCart:")
                let DownSwipe = UISwipeGestureRecognizer(target: self, action: addToCartSelector)
                DownSwipe.direction = .Down
                cell.addGestureRecognizer(DownSwipe)
                lblTopBarMenu.text = "Menu"
                if let menuCell = cell as? menuCollectionViewCell {
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
                    }
                    let url = NSURL(string: imageName)
                    //                    if let img:UIImage = imageCache.objectForKey(url!) as? UIImage {
                    //
                    //                        // cell.imageView?.image = img as UIImage
                    //
                    //                        menuCell.productImageView.image = img as UIImage
                    //
                    //
                    //
                    //                    }
                    //
                    //                    else {
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
                                menuCell.productImageView.image = image
                            })
                        }
                        else {
                            print("Error: \(error!.localizedDescription)")
                        }
                    })
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
                    menuCell.btnCustomization.tag = indexPath.row
                    menuCell.btnCustomization.addTarget(self, action: "Customize:", forControlEvents: UIControlEvents.TouchUpInside)
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
                }
            }
            else if setSourceType == "Cart"
            {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier("menuCell",forIndexPath: indexPath) as UICollectionViewCell
                cell.transform = CGAffineTransformMakeScale(1,1)
                let imageName = appDelegate.cartJson.products[indexPath.row].productImage
                let productName = appDelegate.cartJson.products[indexPath.row].productName
                var productPrice: Double = 0
                productPrice = appDelegate.cartJson.products[indexPath.row].productPrice
                let addToCartSelector = Selector("AddItemToCart:")
                let DownSwipe = UISwipeGestureRecognizer(target: self, action: addToCartSelector)
                DownSwipe.direction = .Down
                cell.addGestureRecognizer(DownSwipe)
                let removeFromCartSelector = Selector("RemoveItemFromCart:")
                let UpSwipe = UISwipeGestureRecognizer(target: self, action: removeFromCartSelector)
                UpSwipe.direction = .Up
                cell.addGestureRecognizer(UpSwipe)
                lblTopBarMenu.text = "Cart"
                if let menuCell = cell as? menuCollectionViewCell {
                    menuCell.btnAddToPreference.hidden = false
                    if appDelegate.cartJson.products[indexPath.row].CustomizationAvailable == true
                    {
                        if appDelegate.cartJson.products[indexPath.row].isCustomized == true
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
                        menuCell.btnAddToPreference.setImage(UIImage(named: "UnselectedPreference.png"), forState: .Normal)
                        menuCell.btnAddToPreference.userInteractionEnabled = false
                    let url = NSURL(string: imageName)
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
                                menuCell.productImageView.image = image
                            })
                        }
                        else {
                            print("Error: \(error!.localizedDescription)")
                        }
                    })
                    menuCell.productName.text  = productName
                    if appDelegate.cartJson.products[indexPath.row].isCustomized == true
                    {
                        for indexCatDetails in 0...appDelegate.cartJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails.count-1
                        {
                            for index in 0...appDelegate.cartJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue.count-1                       {
                                if (appDelegate.cartJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue[index].customisationIsSelected)
                                {
                                    productPrice = productPrice + appDelegate.cartJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue[index].CustomizationPrice
                                }
                            }
                        }
                    }
                    menuCell.productPrice.text = "₹ \(productPrice)"
                    menuCell.btnCustomization.tag = indexPath.row
                    menuCell.btnCustomization.addTarget(self, action: "Customize:", forControlEvents: UIControlEvents.TouchUpInside)
                    menuCell.btnLeftMenuCell.addTarget(self, action: "ClickLeftArrowScrollButton:", forControlEvents: UIControlEvents.TouchUpInside)
                    menuCell.btnLeftMenuCell.tag = indexPath.row
                    menuCell.btnRightMenuCell.addTarget(self, action: "ClickRightArrowScrollButton:", forControlEvents: UIControlEvents.TouchUpInside)
                    menuCell.btnRightMenuCell.tag = indexPath.row
                    if indexPath.row == 0
                    {
                        menuCell.btnLeftMenuCell.hidden = true
                        menuCell.btnRightMenuCell.hidden = false
                    }
                    else if indexPath.row == (appDelegate.cartJson.products.count)-1
                    {
                        menuCell.btnLeftMenuCell.hidden = false
                        menuCell.btnRightMenuCell.hidden = true
                    }
                    else
                    {
                        menuCell.btnRightMenuCell.hidden = false
                        menuCell.btnLeftMenuCell.hidden = false
                    }
                    if appDelegate.cartJson.products.count == 1
                    {
                        menuCell.btnRightMenuCell.hidden = true
                        menuCell.btnLeftMenuCell.hidden = true
                    }
                }
            }
            else if setSourceType == "Preference"
            {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier("menuCell",forIndexPath: indexPath) as UICollectionViewCell
                let imageName = appDelegate.preferenceJson.products[indexPath.row].productImage
                let productName = appDelegate.preferenceJson.products[indexPath.row].productName
                var productPrice = appDelegate.preferenceJson.products[indexPath.row].productPrice
                let addToCartSelector = Selector("AddItemToCart:")
                let DownSwipe = UISwipeGestureRecognizer(target: self, action: addToCartSelector)
                DownSwipe.direction = .Down
                cell.addGestureRecognizer(DownSwipe)
                lblTopBarMenu.text = "Preference"
                if let menuCell = cell as? menuCollectionViewCell {
                    if appDelegate.preferenceJson.products[indexPath.row].CustomizationAvailable == true
                    {
                        if appDelegate.preferenceJson.products[indexPath.row].isCustomized == true
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
                    menuCell.btnAddToPreference.setImage(UIImage(named: "SelectedPreference.png"), forState: .Normal)
                    let url = NSURL(string: imageName)
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
                                menuCell.productImageView.image = image
                            })
                        }
                        else {
                            print("Error: \(error!.localizedDescription)")
                        }
                    })
                    menuCell.productName.text  = productName
                    if appDelegate.preferenceJson.products[indexPath.row].isCustomized == true
                    {
                        for indexCatDetails in 0...appDelegate.preferenceJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails.count-1
                        {
                            for index in 0...appDelegate.preferenceJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue.count-1                       {
                                if (appDelegate.preferenceJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue[index].customisationIsSelected)
                                {
                                    productPrice = productPrice + appDelegate.preferenceJson.products[indexPath.row].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue[index].CustomizationPrice
                                }
                            }
                        }
                    }
                    menuCell.productPrice.text = "₹ \(productPrice)"
                    menuCell.btnAddToPreference.tag = indexPath.row
                    menuCell.btnAddToPreference.addTarget(self, action: "AddOrRemovePreference:", forControlEvents: UIControlEvents.TouchUpInside)
                    menuCell.btnCustomization.tag = indexPath.row
                    menuCell.btnCustomization.addTarget(self, action: "Customize:", forControlEvents: UIControlEvents.TouchUpInside)
                    menuCell.btnLeftMenuCell.addTarget(self, action: "ClickLeftArrowScrollButton:", forControlEvents: UIControlEvents.TouchUpInside)
                    menuCell.btnLeftMenuCell.tag = indexPath.row
                    menuCell.btnRightMenuCell.addTarget(self, action: "ClickRightArrowScrollButton:", forControlEvents: UIControlEvents.TouchUpInside)
                    menuCell.btnRightMenuCell.tag = indexPath.row
                    if indexPath.row == 0
                    {
                        menuCell.btnLeftMenuCell.hidden = true
                        menuCell.btnRightMenuCell.hidden = false
                    }
                    else if indexPath.row == (appDelegate.preferenceJson.products.count)-1
                    {
                        menuCell.btnLeftMenuCell.hidden = false
                        menuCell.btnRightMenuCell.hidden = true
                    }
                    else
                    {
                        menuCell.btnRightMenuCell.hidden = false
                        menuCell.btnLeftMenuCell.hidden = false
                    }
                    if appDelegate.preferenceJson.products.count == 1
                    {
                        menuCell.btnRightMenuCell.hidden = true
                        menuCell.btnLeftMenuCell.hidden = true
                    }
                }
            }
        }
        else if collectionView == cartCV
        {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("cartCell",forIndexPath: indexPath) as UICollectionViewCell
            let imageName = appDelegate.cartJson.products[indexPath.row].productImage
            if let cartCell = cell as? cartCollectionViewCell {
                let url = NSURL(string: imageName)
                if let img:UIImage = imageCache.objectForKey(url!) as? UIImage {
                    cartCell.productImageView.image = img
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
                            // Update the cell
                            dispatch_async(dispatch_get_main_queue(), {
                                cartCell.productImageView.image = image
                            })
                        }
                        else {
                            print("Error: \(error!.localizedDescription)")
                        }
                    })
                }
                cartCell.productImageView.layer.cornerRadius = 5.0
                cartCell.productImageView.clipsToBounds = true
                cartCell.noOfProducts.layer.cornerRadius = 12.0
                cartCell.noOfProducts.clipsToBounds = true
                cartCell.noOfProducts.text = "\(appDelegate.cartJson.products[indexPath.row].numberOfProduct)"
                totalAmount = 0.0
                for indexOut in 0...(appDelegate.cartJson.products.count)-1
                {
                    if appDelegate.cartJson.products[indexOut].isCustomized == false
                    {
                        totalAmount = totalAmount+((appDelegate.cartJson.products[indexOut].productPrice) * Double((appDelegate.cartJson.products[indexOut].numberOfProduct)))
                    }
                    else if appDelegate.cartJson.products[indexOut].isCustomized == true
                    {
                        var custPrice:Double = 0.0
                        for indexCatDetails in 0...appDelegate.cartJson.products[indexOut].customizationDetails.CustomizationcategoryDetails.count-1
                        {
                            for index in 0...appDelegate.cartJson.products[indexOut].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue.count-1                       {
                                if (appDelegate.cartJson.products[indexOut].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue[index].customisationIsSelected)
                                {
                                    custPrice = custPrice +  appDelegate.cartJson.products[indexOut].customizationDetails.CustomizationcategoryDetails[indexCatDetails].CategoryValue[index].CustomizationPrice
                                }
                            }
                        }
                        totalAmount = totalAmount + ((appDelegate.cartJson.products[indexOut].productPrice + custPrice) * Double(appDelegate.cartJson.products[indexOut].numberOfProduct))
                    }
                }
                lblTotalPriceCart.text = "Total ₹\(totalAmount)"
            }
      }
        return cell
    }
    
    
    
    func AddItemToCart(sender:UISwipeGestureRecognizer)
        
    {
        
        let tapLocation = sender.locationInView(self.menuCV)
        
        let indexPath:NSIndexPath = self.menuCV.indexPathForItemAtPoint(tapLocation)!
        
        let cell = self.menuCV.cellForItemAtIndexPath(indexPath) as! menuCollectionViewCell
        
        
        
        if setSourceType == "Menu"
            
        {
            
            
            
            //IF item exists in cart
            
            //  let sourceType:String
            
            //            if let Type = appDelegate.menuJson.products[indexPath.row].SourceType
            
            //            {
            
            //             sourceType = Type
            
            //            }
            
            
            var cartIndex:Int?
            
            
            if let value  = appDelegate.mappedDictionary["\(appDelegate.menuJson.products[indexPath.row].SourceType)"]
                
            {
                
                
                
                for index in 0...appDelegate.cartJson.products.count-1
                    
                {
                    
                    if value.SourceType == appDelegate.cartJson.products[index].SourceType
                        
                    {
                        
                        // var arrayOfMappedDictKey = sourcetype.characters.split{$0=="_"}.map(String.init)
                        
                        // let index = Int(arrayOfMappedDictKey[0])
                        
                        cartIndex = index
                        
                    }
                    
                    
                    
                }
                
                appDelegate.cartJson.products[cartIndex!].numberOfProduct++
                
                
                
            }
                
            else {
                
                //IF item does not exists in cart
                
                if let addingItem = appDelegate.menuJson.products[indexPath.row] as? productDetails
                    
                {
                    
                    var object = addingItem
                    
                    object.SourceIndex = indexPath.row
                    
                    if object.CustomizationAvailable == true
                        
                    {
                        object.setCustomization.removeAll()
                        for index in 0...object.customizationDetails.CustomizationcategoryDetails.count-1
                            
                        {
                            
                            for indexInside in 0...object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue.count-1
                                
                            {
                                
                                if (object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].customisationIsSelected)
                                    
                                {
                                    
                                    object.setCustomization.append(selectedCustomization(catId:object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].customizationCatID ,catName: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].CategoryValueName, storeAliasName: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].StoreAliasName, IdCustValueAlias: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].IdCustomizationValueAlias, price: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].CustomizationPrice, selected: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].customisationIsSelected))
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                    
                    
                    
                    
                    if (self.appDelegate.cartJson.products.count == 0) {
                        
                        appDelegate.cartJson.products = [object]
                        
                        // appDelegate.mappedDictionary.setValue(object as! AnyObject, forKey: "\(indexPath.row)_Menu")
                        
                        appDelegate.mappedDictionary["\(object.SourceType)"] = object
                        cartIndex = appDelegate.cartJson.products.count-1
                        
                    }
                        
                        
                        
                    else
                        
                    {
                        
                        // var object = addingItem
                        
                        object.SourceIndex = indexPath.row
                        
                        //                        if object.isCustomized == false
                        
                        //                        {
                        
                        //                            object.SourceType = "\(indexPath.row)_Menu"
                        
                        //                        }
                        
                        //                        else if object.isCustomized == true
                        
                        //                        {
                        
                        //                            object.SourceType = "\(indexPath.row)_Menu_Cust"
                        
                        //                        }
                        
                        appDelegate.cartJson.products.append(object)
                        cartIndex = appDelegate.cartJson.products.count-1
                        
                        // appDelegate.mappedDictionary.setValue(object as! AnyObject, forKey: "\(indexPath.row)_Menu")
                        
                        appDelegate.mappedDictionary["\(object.SourceType)"] = object
                        
                        
                        
                    }
                    
                }
                
            }
            
            
            
            //End- IF item does not exists in cart
            
            let bounds = UIScreen.mainScreen().bounds
            
            //var width = bounds.size.width
            
            //var height = bounds.size.height
            
            
            
            let animationView = UIImageView()
            
            animationView.alpha = 1.0
            
            animationView.frame = CGRectMake((bounds.size.width / 2) - (cell.productImageView.frame.width / 2), self.menuCV.frame.origin.y + self.menuCV.frame.height/2, cell.productImageView.frame.width, cell.productImageView.frame.height)
            
            
            
            self.view.addSubview(animationView)
            
            //animationView.transform = CGAffineTransformMakeTranslation(bounds.size.width / 2, self.cv.frame.origin.y + self.cv.frame.height )
            
            // animationView.transform = CGAffineTransformMakeScale(3.0, 3.0)
            
            let url = NSURL(string: (appDelegate.menuJson.products[indexPath.row].productImage))
            
            if let img:UIImage = imageCache.objectForKey(url!) as? UIImage {
                
                // cell.imageView?.image = img as UIImage
                
                animationView.image = img as UIImage
                
                
                
            }
            
            //cell.itemsimageview.image = UIImage(named: image)
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseIn , animations: {
                
                
                
                // let translate = CGAffineTransformMakeTranslation(bounds.size.width/2, self.cartCV.frame.origin.y)
                
                // let scale = CGAffineTransformMakeScale(0.000001, 0.000001)
                
                animationView.frame = CGRectMake(bounds.size.width / 2, self.cartCV.frame.origin.y  + self.cartCV.frame.size.height / 2, 0, 0)
                
                animationView.alpha = 0.5
                
                
                
                //  animationView.transform = CGAffineTransformConcat(scale, translate)
                
                }, completion: {(finished:Bool) in
                    
                    // the code you put here will be compiled once the animation finishes
                    
                    animationView.removeFromSuperview()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.cartCV.reloadData()
                        let indexPath = NSIndexPath(forRow: cartIndex!, inSection: 0)
                        print(cartIndex!)
                        self.cartCV.scrollToItemAtIndexPath(NSIndexPath(forItem: cartIndex! , inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
                        
                        
                        
                    })
                    
                    
                    
            })
            
            
            
        }
        
        
        
        if setSourceType == "Preference"
            
        {
            
            //IF item exists in cart
            
            if let value  = appDelegate.mappedDictionary["\(appDelegate.preferenceJson.products[indexPath.row].SourceType)"]
                
            {
                
                var cartIndex:Int?
                
                for index in 0...appDelegate.cartJson.products.count-1
                    
                {
                    
                    if value.SourceType == appDelegate.cartJson.products[index].SourceType
                        
                    {
                        
                        // var arrayOfMappedDictKey = sourcetype.characters.split{$0=="_"}.map(String.init)
                        
                        // let index = Int(arrayOfMappedDictKey[0])
                        
                        cartIndex = index
                        
                    }
                    
                    
                    
                }
                
                appDelegate.cartJson.products[cartIndex!].numberOfProduct++
                
                
                
            }
                
            else {
                
                //IF item does not exists in cart
                
                
                
                if let addingItem = appDelegate.preferenceJson.products[indexPath.row] as? productDetails
                    
                {
                    
                    var object = addingItem
                    object.setCustomization.removeAll()
                    object.SourceIndex = indexPath.row
                    
                    if object.CustomizationAvailable == true
                        
                    {
                        
                        for index in 0...object.customizationDetails.CustomizationcategoryDetails.count-1
                            
                        {
                            
                            for indexInside in 0...object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue.count-1
                                
                            {
                                
                                if (object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].customisationIsSelected)
                                    
                                {
                                    
                                    object.setCustomization.append(selectedCustomization(catId:object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].customizationCatID ,catName: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].CategoryValueName, storeAliasName: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].StoreAliasName, IdCustValueAlias: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].IdCustomizationValueAlias, price: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].CustomizationPrice, selected: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].customisationIsSelected))
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    if (self.appDelegate.cartJson.products.count == 0) {
                        
                        appDelegate.cartJson.products = [object]
                        
                        // appDelegate.mappedDictionary.setValue(object as! AnyObject, forKey: "\(indexPath.row)_Menu")
                        
                        appDelegate.mappedDictionary["\(object.SourceType)"] = object
                        
                    }
                        
                        
                        
                    else
                        
                    {
                        
                        // var object = addingItem
                        
                        object.SourceIndex = indexPath.row
                        
                        //                        if object.isCustomized == false
                        
                        //                        {
                        
                        //                            object.SourceType = "\(indexPath.row)_Menu"
                        
                        //                        }
                        
                        //                        else if object.isCustomized == true
                        
                        //                        {
                        
                        //                            object.SourceType = "\(indexPath.row)_Menu_Cust"
                        
                        //                        }
                        
                        appDelegate.cartJson.products.append(object)
                        
                        // appDelegate.mappedDictionary.setValue(object as! AnyObject, forKey: "\(indexPath.row)_Menu")
                        
                        appDelegate.mappedDictionary["\(object.SourceType)"] = object
                        
                    }
                    
                }
                
            }
            
            
            
            //End- IF item does not exists in cart
            
            
            
            let bounds = UIScreen.mainScreen().bounds
            
            //var width = bounds.size.width
            
            //var height = bounds.size.height
            
            
            
            let animationView = UIImageView()
            
            animationView.alpha = 1.0
            
            animationView.frame = CGRectMake((bounds.size.width / 2) - (cell.productImageView.frame.width / 2), self.menuCV.frame.origin.y + self.menuCV.frame.height/2, cell.productImageView.frame.width, cell.productImageView.frame.height)
            
            
            
            self.view.addSubview(animationView)
            
            //animationView.transform = CGAffineTransformMakeTranslation(bounds.size.width / 2, self.cv.frame.origin.y + self.cv.frame.height )
            
            // animationView.transform = CGAffineTransformMakeScale(3.0, 3.0)
            
            let url = NSURL(string: (appDelegate.preferenceJson.products[indexPath.row].productImage))
            
            if let img:UIImage = imageCache.objectForKey(url!) as? UIImage {
                
                // cell.imageView?.image = img as UIImage
                
                animationView.image = img as UIImage
                
                
                
            }
            
            //cell.itemsimageview.image = UIImage(named: image)
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseIn , animations: {
                
                
                
                // let translate = CGAffineTransformMakeTranslation(bounds.size.width/2, self.cartCV.frame.origin.y)
                
                // let scale = CGAffineTransformMakeScale(0.000001, 0.000001)
                
                animationView.frame = CGRectMake(bounds.size.width / 2, self.cartCV.frame.origin.y  + self.cartCV.frame.size.height / 2, 0, 0)
                
                animationView.alpha = 0.5
                
                
                
                //  animationView.transform = CGAffineTransformConcat(scale, translate)
                
                }, completion: {(finished:Bool) in
                    
                    // the code you put here will be compiled once the animation finishes
                    
                    animationView.removeFromSuperview()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.cartCV.reloadData()
                        
                        
                    })
                    
            })
            
        }
        
    }
    
    
    
    func RemoveItemFromCart(sender:UISwipeGestureRecognizer)
        
    {
        
        
        if setSourceType == "Cart"
        {
        
        let bounds = UIScreen.mainScreen().bounds
        
        let tapLocation = sender.locationInView(self.menuCV)
        
        let indexPath:NSIndexPath = self.menuCV.indexPathForItemAtPoint(tapLocation)!
        
        let cell = self.menuCV.cellForItemAtIndexPath(indexPath) as! menuCollectionViewCell
        
        //  print(indexPath.row)
        
        //   print(appDelegate.menuJson.products[indexPath.row].SourceType)
        
        
        

        
        
        
            
        
                
                var cartIndex:Int = indexPath.row
                
           
                
                
                
                if appDelegate.cartJson.products[cartIndex].numberOfProduct > 1
                    
                {
                    
                    appDelegate.cartJson.products[cartIndex].numberOfProduct--
                    
                    self.cartCV.reloadData()
                    self.menuCV.reloadData()
                    
                    let animationView = UIImageView()
                    
                    animationView.frame = CGRectMake(bounds.size.width / 2, self.cartCV.frame.origin.y  + self.cartCV.frame.size.height / 2, 0, 0)
                    
                    animationView.alpha = 1.0
                    
                    self.view.addSubview(animationView)
                    
                    //animationView.transform = CGAffineTransformMakeTranslation(bounds.size.width / 2, self.cv.frame.origin.y + self.cv.frame.height )
                    
                    // animationView.transform = CGAffineTransformMakeScale(3.0, 3.0)
                    
                    let url = NSURL(string: (appDelegate.cartJson.products[indexPath.row].productImage))
                    
                    if let img:UIImage = imageCache.objectForKey(url!) as? UIImage {
                        
                        // cell.imageView?.image = img as UIImage
                        
                        animationView.image = img as UIImage
                        
                    }
                    
                    //cell.itemsimageview.image = UIImage(named: image)
                    
                    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseIn , animations: {
                        
                        
                        
                        // let translate = CGAffineTransformMakeTranslation(bounds.size.width/2, self.cartCV.frame.origin.y)
                        
                        // let scale = CGAffineTransformMakeScale(0.000001, 0.000001)
                        
                        animationView.frame = CGRectMake((bounds.size.width / 2) - (cell.productImageView.frame.width / 2), self.menuCV.frame.origin.y + self.menuCV.frame.height/2, cell.productImageView.frame.width, cell.productImageView.frame.height)
                        
                        animationView.alpha = 0.5
                        
                        
                        
                        
                        
                        //  animationView.transform = CGAffineTransformConcat(scale, translate)
                        
                        }, completion: {(finished:Bool) in
                            
                            // the code you put here will be compiled once the animation finishes
                            
                            
                            
                            animationView.removeFromSuperview()
                            
                            
                            
                            
                            
                            
                            
                    })
                    
                    
                    
                    
                    
                    
                }
                    
                else if appDelegate.cartJson.products[cartIndex].numberOfProduct == 1
                    
                {
                    
                    self.appDelegate.mappedDictionary.removeValueForKey("\(appDelegate.cartJson.products[indexPath.row].SourceType)")
                    
                    
                    
                    
                    
                    
                    
                    let animationView = UIImageView()
                    
                    animationView.frame = CGRectMake(bounds.size.width / 2, self.cartCV.frame.origin.y  + self.cartCV.frame.size.height / 2, 0, 0)
                    
                    animationView.alpha = 1.0
                    
                    self.view.addSubview(animationView)
                    
                    //animationView.transform = CGAffineTransformMakeTranslation(bounds.size.width / 2, self.cv.frame.origin.y + self.cv.frame.height )
                    
                    // animationView.transform = CGAffineTransformMakeScale(3.0, 3.0)
                    
                    let url = NSURL(string: (appDelegate.cartJson.products[indexPath.row].productImage))
                    
                    if let img:UIImage = imageCache.objectForKey(url!) as? UIImage {
                        
                        // cell.imageView?.image = img as UIImage
                        
                        animationView.image = img as UIImage
                        
                    }
                    
                    //cell.itemsimageview.image = UIImage(named: image)
                    
                    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseIn , animations: {
                        
                        
                        
                        // let translate = CGAffineTransformMakeTranslation(bounds.size.width/2, self.cartCV.frame.origin.y)
                        
                        // let scale = CGAffineTransformMakeScale(0.000001, 0.000001)
                        
                        animationView.frame = CGRectMake((bounds.size.width / 2) - (cell.productImageView.frame.width / 2), self.menuCV.frame.origin.y + self.menuCV.frame.height/2, cell.productImageView.frame.width, cell.productImageView.frame.height)
                        
                        animationView.alpha = 0.5
                        
                        
                        
                        
                        
                        //  animationView.transform = CGAffineTransformConcat(scale, translate)
                        
                        }, completion: {(finished:Bool) in
                            
                            // the code you put here will be compiled once the animation finishes
                            
                            
                            
                            animationView.removeFromSuperview()
                            
                            
                         self.appDelegate.cartJson.products.removeAtIndex(cartIndex)
                            self.cartCV.reloadData()
                            self.menuCV.reloadData()
//                            if !self.appDelegate.cartJson.products.isEmpty
//                            {
//                            
//                            let cartindexPath = NSIndexPath(forRow: indexPath.row-1, inSection: 0)
//                                print(indexPath.row)
//                                 print(cartindexPath.row)
//                            let cartSelectedcell = self.cartCV.cellForItemAtIndexPath(cartindexPath)
//                                
//                                
//                                    
//                                    
//                                    cartSelectedcell!.transform = CGAffineTransformMakeScale(1.3,1.3)
//                                    cartSelectedcell!.layer.shadowColor = UIColor.blackColor().CGColor
//                                    cartSelectedcell!.layer.shadowOffset = CGSizeMake(5, 5)
//                                    cartSelectedcell!.layer.shadowRadius = 5
//                                    cartSelectedcell!.layer.shadowOpacity = 1.0
//                                    cartSelectedcell!.layer.masksToBounds = false
//                                    
//                               
//                            }
                            
                            if self.appDelegate.cartJson.products.isEmpty
                                
                            {
                                
                                self.lblTotalPriceCart.text = ""
                                 self.menuCV.reloadData()
                                
                                self.appDelegate.menuJson = self.appDelegate.originalMenuJson
                                self.setSourceType = self.appDelegate.PreviousSourceType
                                if self.setSourceType == "Menu"
                                    
                                {
                                    
                                    self.btnMenu.setImage(UIImage(named:"Hearts-100.png"), forState: .Normal)
                                    
                                }
                                    
                                else  if self.setSourceType == "Preference"
                                    
                                {
                                    
                                    self.btnMenu.setImage(UIImage(named:"menu100_grey.png"), forState: .Normal)
                                    
                                }
                                
                                self.menuCV.scrollToItemAtIndexPath(NSIndexPath(forItem: self.appDelegate.PreviousSourceItemIndex , inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
                                
                                
                            }
                            
                            
                            
                            
                    })
                    
                    
                    
                    
                    
                    
                }

                
           
            
        }
        
      
        
    }
    
    
    
    
    
    func AddOrRemovePreference(sender: UIButton)
        
    {
        
        var index:Int = sender.tag
        
        
        
        var indexPrefence:Int = 0
        
        var indexMenu:Int = 0
        
        if self.setSourceType == "Menu"
            
        {
            
            indexMenu = index
            
        }
            
        else
            
        {
            
            indexPrefence = index
            
        }
        
        
        
        
        
        if sender.currentImage  == UIImage(named: "UnselectedPreference.png")
            
        {
            
            appDelegate.menuJson.products[index].alreadyInPreference = true
            
            appDelegate.originalMenuJson.products[index].alreadyInPreference = true
            
            addToPreference(index)
            
            appDelegate.isPreferenceChanged = true
            
        }
            
        else if sender.currentImage  == UIImage(named: "SelectedPreference.png")
            
        {
            if (!appDelegate.preferenceJson.products.isEmpty)
            
        {

            
            if self.setSourceType == "Menu"
                
            {
                
                for Index in 0...appDelegate.preferenceJson.products.count-1
                    
                {
                    
                    if appDelegate.menuJson.products[sender.tag].productId == appDelegate.preferenceJson.products[Index].productId
                        
                    {
                        
                        
                        
                        index = Index
                        
                        indexPrefence = Index
                        
                        
                        
                    }
                    
                }
                
            }
                
            else if self.setSourceType == "Preference"
                
            {
                
                for Index in 0...appDelegate.menuJson.products.count-1
                    
                {
                    
                    if appDelegate.menuJson.products[Index].productId == appDelegate.preferenceJson.products[sender.tag].productId
                        
                    {
                        
                        indexPrefence = sender.tag
                        
                        index = Index
                        
                        indexMenu = Index
                        
                    }
                    
                }
                
                
                
            }
            
            
            
            }
            
            if setSourceType == "Preference"
                
            {
                
                appDelegate.menuJson.products[indexMenu].alreadyInPreference = false
                
                appDelegate.originalMenuJson.products[indexMenu].alreadyInPreference = false
                
                removeFromPreference(indexPrefence)
                
                appDelegate.isPreferenceChanged = true
                
            } else if setSourceType == "Menu"
                
            {
                
                appDelegate.menuJson.products[indexMenu].alreadyInPreference = false
                
                appDelegate.originalMenuJson.products[indexMenu].alreadyInPreference = false
                
                removeFromPreference(indexPrefence)
                
                appDelegate.isPreferenceChanged = true
                
                
                
            }
            
        }
        
        
        
    }
    
    
    
    func addToPreference(Index: Int)
        
    {
        
        var object = appDelegate.menuJson.products[Index]
        
        
        object.setCustomization.removeAll()
        if object.CustomizationAvailable == true
            
        {
            
            for index in 0...object.customizationDetails.CustomizationcategoryDetails.count-1
                
            {
                
                for indexInside in 0...object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue.count-1
                    
                {
                    
                    if (object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].customisationIsSelected)
                        
                    {
                        
                        
                        object.setCustomization.append(selectedCustomization(catId:object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].customizationCatID ,catName: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].CategoryValueName, storeAliasName: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].StoreAliasName, IdCustValueAlias: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].IdCustomizationValueAlias, price: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].CustomizationPrice, selected: object.customizationDetails.CustomizationcategoryDetails[index].CategoryValue[indexInside].customisationIsSelected))
                        
                    }
                    
                }
                
            }
            
        }

        
        
        
        let index = appDelegate.preferenceJson.products.count
        
        if(object.isCustomized == true)
            
        {
            
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
            
            object.SourceType = "\(index)_Preference"
            
        }
        
        if (appDelegate.preferenceJson.products.count == 0) {
            
            appDelegate.preferenceJson.products = [object]
            
        }
            
        else
            
        {
            
            appDelegate.preferenceJson.products.append(object)
            
        }
        print(appDelegate.preferenceJson.products)
        self.menuCV.reloadData()
        
        //        }
        
        //        else
        
        //        {
        
        //            print("already exists")
        
        //        }
        
    }
    
    
    
    func removeFromPreference(Index: Int)
        
    {
        
        let alertController = UIAlertController(title: "Drive-Thru", message: "Remove Item from Preference?", preferredStyle: .Alert)
        
        // Create the actions
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
            
            {
                
                UIAlertAction in
                
                NSLog("Yes Pressed")
                
                self.appDelegate.preferenceJson.products.removeAtIndex(Index)
                
                self.menuCV.reloadData()
                if self.setSourceType == "Preference"
                {
                if self.appDelegate.preferenceJson.products.isEmpty
                {
                    let label:UILabel = UILabel(frame: CGRectMake(0, 0, 300, 30))
                    label.center = CGPointMake(self.menuCV.frame.size.width/2, self.menuCV.frame.size.height/2)
                    label.textAlignment = NSTextAlignment.Center
                    // label.textColor = UIColor.
                    label.text = "Add Item To Preference"
                    self.menuCV.addSubview(label)
                    self.menuCV.bringSubviewToFront(label)
                    
                }
                }
                
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
    
    @IBAction func Click_btnMenu(sender: AnyObject) {
        
        let fromCart:String = lblTopBarMenu.text!
        
        if btnMenu.imageView?.image == UIImage(named:"menu100_grey.png")
            
        {
            let subViews = self.menuCV.subviews
            for subview in subViews{
                subview.removeFromSuperview()
            }
            
            setSourceType = "Menu"
            
            btnMenu.setImage(UIImage(named:"Hearts-100.png"), forState: .Normal)
            
            lblTopBarMenu.text = "Menu"
            
            self.menuCV.reloadData()
            
        }
            
        else if btnMenu.imageView?.image == UIImage(named:"Hearts-100.png")
            
        {
            
            setSourceType = "Preference"
            
            btnMenu.setImage(UIImage(named:"menu100_grey.png"), forState: .Normal)
            
            lblTopBarMenu.text = "Preference"
            
            self.menuCV.reloadData()
            if appDelegate.preferenceJson.products.isEmpty
            {
                let label:UILabel = UILabel(frame: CGRectMake(0, 0, 300, 30))
                label.center = CGPointMake(self.menuCV.frame.size.width/2, self.menuCV.frame.size.height/2)
                label.textAlignment = NSTextAlignment.Center
               // label.textColor = UIColor.
                label.text = "Add Item To Preference"
                self.menuCV.addSubview(label)
                self.menuCV.bringSubviewToFront(label)
                
            }
            
        }
        
        if fromCart == "Cart"
        {
            let noOfItemsInCart = appDelegate.cartJson.products.count
            for index in 0...noOfItemsInCart-1
            {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                print(indexPath)
                let cell = cartCV.cellForItemAtIndexPath(indexPath)
           
                
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        
                        cell!.transform = CGAffineTransformMakeScale(1,1)
                        cell!.layer.shadowOpacity = 0.0
                    })
                
                
            }
         self.menuCV.scrollToItemAtIndexPath(NSIndexPath(forItem: self.appDelegate.PreviousSourceItemIndex , inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
            cartCV.reloadData()
        }
        
        
        
    }
    
    func Customize(sender: UIButton){
        
        /*    if sender.imageView?.image == UIImage(named: "Customize_UnSelected.png")
        
        {
        
        print("Customization On")
        
        sender.setTitle("Customize_Selected.png", forState: .Normal)
        
        
        
        self.performSegueWithIdentifier("SegueOrderPlacementToCustomization", sender: self)
        
        
        
        }
        
        if sender.imageView?.image == UIImage(named: "Customize_Selected.png")        {
        
        print("Customization Off")
        
        sender.setTitle("Customize_UnSelected.png", forState: .Normal)
        
        }
        
        sender.setImage(UIImage(named: "Customize_Selected.png"), forState: .Normal)
        
        
        
        */
        
        customizationIndex = sender.tag
        
        
        
        self.performSegueWithIdentifier("SegueOrderPlacementToCustomization", sender: self)
        
    }
    
    
    
    
    
    @IBAction func Click_btnPlaceOrder(sender: AnyObject) {
        
        if (!(appDelegate.cartJson.products.isEmpty))
            
        {
            
            showCheckout()
            
        }
            
        else
            
        {
            
            let alertController = UIAlertController(title: "Drive-Thru", message: "Cart is Empty!", preferredStyle: .Alert)
            
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
    
    
    
    func showCheckout(){
        
        let checkout:RazorpayCheckout = RazorpayCheckout(key: "rzp_test_nX8WQgZ65haHrQ");
        
        checkout.setDelegate(self);
        
        
        
        let options = ["amount" : "\(Int(self.totalAmount))00", "currency": "INR", "name": "DriveThru", "description": appDelegate.MerchantName,
            
            "image": appDelegate.MerchantImageUrlString,
            
            "prefill": ["email": self.userMail,
                
                "contact": self.userPhone]]
        
        checkout.open(options as [NSObject : AnyObject]);
        
    }
    
    
    
    // implement in delegate set through "checkout.setDelegate" above.
    
    func onPaymentSuccess(payment_id: String){
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        view.addSubview(blurEffectView)
        
//        indicator.center = view.center
//        blurEffectView.addSubview(indicator)
//        indicator.bringSubviewToFront(view)
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        self.view.userInteractionEnabled = false
//        indicator.startAnimating()
        
        progressBar.center = view.center
        blurEffectView.addSubview(progressBar)
        progressBar.bringSubviewToFront(view)
        self.view.userInteractionEnabled = false
        progressBar.setProgress(0.2, animated: true)
        
        var orderPlaced:Order = Order()
        
        orderPlaced.order = appDelegate.cartJson
        orderPlaced.order.ConsumerID = Int(appDelegate.userID)!
        orderPlaced.order.MerchantID = Int(appDelegate.MerchantId)!
        
        
        orderPlaced.order.payment.paymentID = payment_id
        
        let orderJsonObject = orderPlaced.toJSON()
        print(orderJsonObject)
        
        var orderJsonData: NSData!
        
        do {
            
            orderJsonData = try NSJSONSerialization.dataWithJSONObject(orderJsonObject!, options: NSJSONWritingOptions())
            
            
            
        } catch {
            
            print(error)
            
            
            
        }
        progressBar.setProgress(0.3, animated: true)
        saveJsonToRestfull(orderJsonData, url: "http://sqweezy.com/DriveThru/Save_Orderdetails.php")
        isOrderPlaced = true
    }
    
    
    
    
    
    func onPaymentError(code: NSNumber, description: String){
        
        
        
        let alertController = UIAlertController(title: "Alert", message: "Error \(description)", preferredStyle: .Alert)
        
        // Create the actions
        
        let okAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default)
            
            {
                
                UIAlertAction in
                
                self.showCheckout()
                
                
                
        }
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.Cancel)
            
            {
                
                UIAlertAction in
                
        }
        
        // Add the actions
        
        alertController.addAction(okAction)
        
        alertController.addAction(cancelAction)
        
        // Present the controller
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
        
    }
    
    func saveJsonToRestfull(jSonData: NSData, url:String)
        
    {
        
        let encodedImage = jSonData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        let parameters = ["image": encodedImage, "otherParam": "otherValue"]
        
        progressBar.setProgress(0.4, animated: true)
        
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPMethod = "POST"
        
        
        
        var error: NSError?
        
        request.HTTPBody = jSonData
        
        
        
        if let error = error {
            
            print("\(error.localizedDescription)")
            
        }
        
        
        
        let dataTask = session.dataTaskWithRequest(request) { data, response, error in
        self.progressBar.setProgress(0.6, animated: true)
            
            
            var json: [String: AnyObject]!
            
            do {
                
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String: AnyObject]
                
            } catch {
                
                print(error)
                
                
                
            }
            
            print(json)
            let OrderDictionary = json as NSDictionary
            
            let result = OrderDictionary.objectForKey("result") as! NSMutableArray
            print(result)
            self.progressBar.setProgress(0.8, animated: true)
            for index in 0...result.count-1
                
            {
                
                if let tokenID = result[index].objectForKey("result_fn_next_token") as? String
                    
                {
                    
                    self.defaults.setObject(tokenID, forKey: "tokenID")
                    
                }
                
                if let orderID = result[index].objectForKey("inserted_orderID") as? Int
                    
                {
                    
                    self.defaults.setObject(String(orderID), forKey: "orderID")
                    
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.appDelegate.cartJson.products = []
                
                self.appDelegate.mappedDictionary.removeAll()
                self.view.userInteractionEnabled = true
                self.progressBar.setProgress(1.0, animated: true)
                
                self.appDelegate.orderedProductDetails = OrderedDetails(json:json)!
//                self.defaults.setValue(self.appDelegate.orderedProductDetails as? AnyObject, forKey: "OrderedProductDetails")
               
                self.performSegueWithIdentifier("segueOrderPlacementToTokenVC", sender: self)
                self.isOrderPlaced = true
                
            })
            
        }
        
        dataTask.resume()
        
    }
    
    
    @IBAction func clickBtnMenuMap(sender: AnyObject) {
        if appDelegate.cartJson.products.isEmpty
        {
        self.performSegueWithIdentifier("SegueOrderPlacementToMapView", sender: self)
        }
        else
        {
            let alertController = UIAlertController(title: "Drive-Thru", message: "Cart will be cleared!", preferredStyle: .Alert)
            
            // Create the actions
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
                
                {
                    
                    UIAlertAction in
                    self.appDelegate.cartJson.products = []
                    self.performSegueWithIdentifier("SegueOrderPlacementToMapView", sender: self)
                    
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default)
                
                {
                    
                    UIAlertAction in
                    
            }
            
            
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        }
        
    }
    
    
    @IBAction func clickBtnMenuHome(sender: AnyObject) {
        if appDelegate.cartJson.products.isEmpty
        {
        self.performSegueWithIdentifier("SegueOrderPlacementToHome", sender: self)
        }
        
        else
        {
            let alertController = UIAlertController(title: "Drive-Thru", message: "Cart will be cleared!", preferredStyle: .Alert)
            
            // Create the actions
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
                
                {
                    
                    UIAlertAction in
                    self.appDelegate.cartJson.products = []
                    self.performSegueWithIdentifier("SegueOrderPlacementToMapView", sender: self)
                    
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default)
                
                {
                    
                    UIAlertAction in
                    
            }
            
            
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "SegueOrderPlacementToCustomization")
            
        {
             let destinationVC = segue.destinationViewController as! customizationViewController
            if setSourceType == "Menu"
            {
            var passingItem = appDelegate.menuJson.products[customizationIndex]
            
            passingItem.SourceIndex = customizationIndex
            
            destinationVC.ProductCustomization = passingItem
                destinationVC.fromSource = "Menu"
            }
            else if setSourceType == "Preference"
            {
                var passingItem = appDelegate.preferenceJson.products[customizationIndex]
                
                passingItem.SourceIndex = customizationIndex
                passingItem.SourceType = "\(customizationIndex)_Preference"
                
                destinationVC.ProductCustomization = passingItem
                destinationVC.fromSource = "Preference"
                
            }
            else if setSourceType == "Cart"
            {
                var passingItem = appDelegate.cartJson.products[customizationIndex]
                print(passingItem.SourceType)
                passingItem.SourceIndex = customizationIndex
                destinationVC.fromSource = "Cart"
                
                destinationVC.ProductCustomization = passingItem
                
            }
            
        }
        
        if (segue.identifier == "segueOrderPlacementToTokenVC")
            
        {
            
            let destinationVC = segue.destinationViewController as! UserTokenViewController
            
            
            
        }
        
    }
    
}





extension OrderPlacementViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if(appDelegate.isMenuChanged)
            
        {
            
            appDelegate.menuJson = appDelegate.originalMenuJson
            
            appDelegate.isMenuChanged = false
            
            
            
        }
        if setSourceType == "Cart"
        {
            let noOfItemsInCart = appDelegate.cartJson.products.count
            let currentIndexpath = self.menuCV.indexPathsForVisibleItems()
            for index in 0...noOfItemsInCart-1 
            {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                print(indexPath)
                let cell = cartCV.cellForItemAtIndexPath(indexPath)
                if index == currentIndexpath[0].row
                {
                    
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        
                        
                        cell!.transform = CGAffineTransformMakeScale(1.3,1.3)
                        cell!.layer.shadowColor = UIColor.blackColor().CGColor
                        cell!.layer.shadowOffset = CGSizeMake(5, 5)
                        cell!.layer.shadowRadius = 5
                        cell!.layer.shadowOpacity = 1.0
                        cell!.layer.masksToBounds = false
                        
                    })
                }
                    else
                    {
                        
                            
                            
                            cell!.transform = CGAffineTransformMakeScale(1,1)
                            cell!.layer.shadowOpacity = 0.0
                            
                        
                }
                
            }
            
                

            cartCV.selectItemAtIndexPath(NSIndexPath(forItem: currentIndexpath[0].row, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.Left)
        }
        }
        
    }
    
    



