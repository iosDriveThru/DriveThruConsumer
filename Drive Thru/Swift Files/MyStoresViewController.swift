//
//  MyStoresViewController.swift
//  Drive Thru
//
//  Created by Nanite Solutions on 2/29/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
class MyStoresViewController: UIViewController , GMSMapViewDelegate, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var isMarkerTitleset:Bool = false
    var currentLatitude:Double = 12.919687
    var currentLongitude:Double = 77.592188
    var store_Latitude:Double = 0.0
    var store_Longitude:Double = 0.0
    var cameraZoom:Double = 17
    var userDetailsObject = [NSManagedObject]()
    let orderVC = OrderPlacementViewController()
    var allplace :[String] = []
    var placeID : [String] = []
    var store_Name:String = ""
    var shopMarkerSnippet:String = ""
    var recentSearchedItemCount:Int = 0
    
    @IBOutlet var autocompleteTableView: UITableView!
    @IBOutlet var btnSkip: UIButton!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var btnToken: UIButton!
    @IBOutlet var imgUserProfile: UIImageView!
    @IBOutlet var lblStoreName: UILabel!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var txtShopName: UITextField!
    @IBOutlet var merchantImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imgUserProfile.layer.cornerRadius = self.imgUserProfile.frame.size.width / 2
        
        settingButtonDesign()
        mapRelatedSettings()
        getUserDetails()
        getStoreDetails()
        displayMerchantImage()
        txtShopName.delegate = self
        if orderVC.isOrderPlaced == true
        {
            btnToken.setImage(UIImage(named: "Token.png"), forState: .Normal)
        }
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func txtShopName_Click(sender: AnyObject) {
        btnDone.hidden = false
        btnSkip.hidden = false
    }
    @IBAction func btnDone_Click(sender: AnyObject) {
        btnDone.hidden = true
        btnSkip.hidden = true
        txtShopName.hidden = true
        lblStoreName.hidden = true
        store_Name = txtShopName.text!
        saveUserStoresDetailsToLocalStorage()
    }
    @IBAction func btnSkip_Click(sender: AnyObject) {
        btnDone.hidden = true
        btnSkip.hidden = true
        txtShopName.hidden = true
        lblStoreName.hidden = true
    }
    func settingButtonDesign()
    {
        btnSkip.layer.borderWidth = 1.0
        btnSkip.layer.cornerRadius = 5.0
        btnSkip.layer.borderColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0).CGColor
        
        btnSkip.layer.shadowRadius = 3.0
        btnSkip.layer.shadowColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0).CGColor
        btnSkip.layer.shadowOffset = CGSizeMake(5.0, 5.0)
        btnSkip.layer.shadowOpacity = 1.0
        btnSkip.layer.masksToBounds = false
        
        btnDone.layer.borderWidth = 1.0
        btnDone.layer.cornerRadius = 5.0
        btnDone.layer.borderColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0).CGColor
        btnDone.layer.shadowRadius = 3.0
        btnDone.layer.shadowColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0).CGColor
        btnDone.layer.shadowOffset = CGSizeMake(5.0, 5.0)
        btnDone.layer.shadowOpacity = 1.0
        btnDone.layer.masksToBounds = false
    }
    //resign keypad on click of return button
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
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
    // setting maprelated
    func mapRelatedSettings(){
        mapView.delegate = self
        mapView.myLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.settings.accessibilityElementsHidden = false
        mapView.animateToViewingAngle(45)
        mapView.animateToBearing(45.0)
        mapView.settings.zoomGestures = true
        mapView.camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude:currentLongitude, zoom:Float(cameraZoom))
        addSubView()
    }
    //Add the map to the Main view and add the object library to mapview    
    func addSubView(){
        self.view.addSubview(mapView)
        mapView.addSubview(btnDone)
        mapView.addSubview(btnSkip)
        mapView.resignFirstResponder()
        mapView.bringSubviewToFront(txtShopName)
    }
    //adding marker for stores
    func addMarker(Latitude:Double, Longitude:Double){
        let marker:GMSMarker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(Latitude, Longitude)
        //      let storeImageName = MerchantImage
        //        let url = NSURL(string: storeImageName)
        //        let imageData = NSData(contentsOfURL: url!)
        //        marker.icon = resizeImage(UIImage(data: imageData!)!, scaledToSize: CGSizeMake(30,30))
        marker.map = mapView
    }
    //didtap marker
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        txtShopName.hidden = false
        lblStoreName.hidden = false
        if isMarkerTitleset == true{
            txtShopName.placeholder = "Edit shop name"
            marker.snippet = ""
            marker.title = shopMarkerSnippet
         }
        else
        {
            
        }
    marker.map = mapView
       return false
    }
    //updating user location to get user location on iPhone device
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLatitude = manager.location!.coordinate.latitude
        currentLongitude = manager.location!.coordinate.longitude
    }
    //fetching user profile picture to display
    func  getUserDetails(){
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
                if let userProfilePicture:String =  res.valueForKey("userProfileImage") as? String
                {
                    if let url = NSURL(string: userProfilePicture) {
                        if let data = NSData(contentsOfURL: url){
                            self.imgUserProfile.image = UIImage(data: data)
                        }
                    }
                }
                
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    //saving user store details to coredata
    func saveUserStoresDetailsToLocalStorage(){
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let storeEntity =  NSEntityDescription.entityForName("MyStores",
            inManagedObjectContext:managedContext)
        let store = NSManagedObject(entity: storeEntity!,
            insertIntoManagedObjectContext: managedContext)
        store.setValue(self.store_Name, forKey: "storeName")
        store.setValue(self.store_Latitude, forKey: "storeLatitude")
        store.setValue(self.store_Longitude, forKey: "storeLongitude")
        do {
            try managedContext.save()
            userDetailsObject.append(store)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        isMarkerTitleset = true
    }
    // get storesDetails
    func  getStoreDetails(){
        isMarkerTitleset = true
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        //2
        let fetchRequest = NSFetchRequest(entityName: "MyStores")
        //3
        do {
            let results:NSArray =
            try managedContext.executeFetchRequest(fetchRequest)
            userDetailsObject = results as! [NSManagedObject]
            if results.count > 0{
                let res = results[results.count-1] as! NSManagedObject
                if let storeName:String =  res.valueForKey("storeName") as? String{
                    print("storeName\(storeName)")
                    self.shopMarkerSnippet = storeName
                }
                var latitude:Double = Double()
                if let storeLatitude:Double =  res.valueForKey("storeLatitude") as? Double{
                    print("storeLatitude\(storeLatitude)")
                    latitude = storeLatitude
                }
                var longitude:Double = Double()
                if let storeLongitude:Double =  res.valueForKey("storeLongitude") as? Double{
                    print("storeLongitude\(storeLongitude)")
                    longitude = storeLongitude
                }
                addMarker(latitude, Longitude: longitude)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }

    //display search results in tableview
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allplace.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if(indexPath.row < allplace.count)
        {
            if indexPath.row < recentSearchedItemCount
            {
                cell.textLabel?.textColor = UIColor.redColor()
            }
            cell.textLabel?.text = allplace[indexPath.row] as String
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.resignFirstResponder()
        if(indexPath.row >= allplace.count)
        {
            return
        }
        autocompleteTableView.hidden = true
        getPlaceFromId(placeID[indexPath.row])
        searchBar.text = allplace[indexPath.row]
    }
    func placeAutocomplete(let txt: String) {
        let placesClient:GMSPlacesClient? = GMSPlacesClient()
        placesClient?.autocompleteQuery(searchBar!.text!, bounds: nil, filter: nil, callback: { (results, error: NSError?) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                self.allplace = [String]()
                self.placeID = [String]()
                self.autocompleteTableView.reloadData()
                return
            }
            self.allplace = [String]()
            self.placeID = [String]()
            if(results == nil)
            {
                self.autocompleteTableView.reloadData()
                
                return;
            }
            let placesDescription:String = ""
            let placesId:String = ""
            if(placesDescription.lowercaseString.rangeOfString(self.searchBar.text!.lowercaseString) != nil)
            {
                self.allplace.append(placesDescription)
                self.placeID.append(placesId)
            }
            self.recentSearchedItemCount = self.placeID.count
            for result in results! {
                if let result = result as? GMSAutocompletePrediction {
                self.allplace.append(result.attributedFullText.string)
                self.placeID.append(result.placeID)
                self.autocompleteTableView.reloadData()
                }
            }
            if(self.searchBar.text!.isEmpty)
            {
                self.allplace = [String]()
                self.placeID = [String]()
                self.autocompleteTableView.reloadData()
            }
        })
        autocompleteTableView.hidden = false
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
     }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text!.isEmpty)
        {
            allplace = [String]()
            placeID = [String]()
            self.autocompleteTableView.reloadData()
            autocompleteTableView.hidden = true
            return
        }
        placeAutocomplete(self.searchBar.text!)
        autocompleteTableView.hidden = false
    }
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
       return true
    }
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        print("hi")
    }
    func getPlaceFromId(id: String){
        let placesClient:GMSPlacesClient? = GMSPlacesClient()
        placesClient?.lookUpPlaceID(id, callback: { (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)", terminator: "")
                return
            }
            if let place = place {
                self.allplace.append(place.name)
                self.autocompleteTableView.reloadData()
            } else {
                // print("No place details for \(id)")
            }
            self.mapView.camera = GMSCameraPosition.cameraWithLatitude(place!.coordinate.latitude, longitude: place!.coordinate.longitude, zoom: 16)
            self.addMarker(place!.coordinate.latitude, Longitude: place!.coordinate.longitude)
            self.store_Latitude = place!.coordinate.latitude
            self.store_Longitude = place!.coordinate.longitude
        })
    }

}