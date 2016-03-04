//
//  BaselocationViewController.swift
//  Drive Thru
//
//  Created by Nanite Solutions on 2/29/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
class BaselocationViewController: UIViewController, GMSMapViewDelegate, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate
{
    var isLocationAddressSet:Bool = false
    var currentLatitude:Double = 12.919687
    var currentLongitude:Double = 77.592188
    var cameraZoom:Double = 17
    var Home_Latitude:Double = 0.0
    var Home_Longitude:Double = 0.0
    var work_Latitude:Double = 0.0
    var work_Longitude:Double = 0.0
    var userDetailsObject = [NSManagedObject]()
    var allplace :[String] = []
    var placeID : [String] = []
    var recentSearchedItemCount:Int = 0
    @IBOutlet var autocompleteTableView: UITableView!
    @IBOutlet var btnSkip: UIButton!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var imgUserProfile: UIImageView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var segmentController: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imgUserProfile.layer.cornerRadius = self.imgUserProfile.frame.size.width / 2
        mapRelatedSettings()
        getUserDetails()
        settingButtonDesign()
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func segmentController_Click(sender: AnyObject) {
        if segmentController.selectedSegmentIndex == 0{
            getUserLocationDetailsFromLocalStorage(Home_Latitude, locationLongitude: Home_Longitude)
            addMarker(Home_Latitude, Longitude: Home_Longitude)
        mapView.camera = GMSCameraPosition.cameraWithLatitude(Home_Latitude, longitude:Home_Longitude, zoom:Float(cameraZoom))
        }
        else{
            getUserLocationDetailsFromLocalStorage(work_Latitude, locationLongitude: work_Longitude)
            addMarker(work_Latitude, Longitude: work_Longitude)
        mapView.camera = GMSCameraPosition.cameraWithLatitude(work_Latitude, longitude:work_Longitude, zoom:Float(cameraZoom))
        }
    }
    @IBAction func btnDone_Click(sender: AnyObject) {
        btnDone.hidden = true
        btnSkip.hidden = true
        isLocationAddressSet = true
        if segmentController.selectedSegmentIndex == 0{
            saveUserLocationDetailsToLocalStorage(Home_Latitude, locationLongitude: Home_Longitude)
        }
        else{
            saveUserLocationDetailsToLocalStorage(work_Latitude, locationLongitude: work_Longitude)
        }
        
         }
    @IBAction func btnSkip_Click(sender: AnyObject) {
        btnDone.hidden = true
        btnSkip.hidden = true
        isLocationAddressSet = false
     }
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
        //Add the map to the Main view
        self.view.addSubview(mapView)
        mapView.addSubview(btnDone)
        mapView.addSubview(btnSkip)
        
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
    func addMarker(Latitude:Double, Longitude:Double)
    {
        let marker:GMSMarker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(Latitude, Longitude)
    //      let storeImageName = MerchantImage
//        let url = NSURL(string: storeImageName)
//        let imageData = NSData(contentsOfURL: url!)
//        marker.icon = resizeImage(UIImage(data: imageData!)!, scaledToSize: CGSizeMake(30,30))
        marker.map = mapView
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLatitude = manager.location!.coordinate.latitude
        currentLongitude = manager.location!.coordinate.longitude
        // let myLocation = manager.location!.coordinate
        //var myLocation = CLLocationCoordinate2DMake(40.315629, -74.624081)
        //  let camUpdate = GMSCameraUpdate.setTarget(myLocation, zoom: Float(cameraZoom))
        //  mapView.animateWithCameraUpdate(camUpdate)
    }
    //saving user store details to coredata
    func saveUserLocationDetailsToLocalStorage(locationLatitude:Double, locationLongitude:Double){
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let storeEntity =  NSEntityDescription.entityForName("MyAddress",
            inManagedObjectContext:managedContext)
        let store = NSManagedObject(entity: storeEntity!,
            insertIntoManagedObjectContext: managedContext)
        store.setValue(self.Home_Latitude, forKey: "homeLatitude")
        store.setValue(self.Home_Longitude, forKey: "homeLongitude")
        store.setValue(self.work_Latitude, forKey: "workLatitude")
        store.setValue(self.work_Longitude, forKey: "workLongitude")
        do {
            try managedContext.save()
            userDetailsObject.append(store)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    // get storesDetails
    func  getUserLocationDetailsFromLocalStorage(locationLatitude:Double, locationLongitude:Double){
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        //2
        let fetchRequest = NSFetchRequest(entityName: "MyAddress")
        //3
        do {
            let results:NSArray =
            try managedContext.executeFetchRequest(fetchRequest)
            userDetailsObject = results as! [NSManagedObject]
            if results.count > 0{
                let res = results[results.count-1] as! NSManagedObject
                var latitude:Double = Double()
                if let homeLatitude:Double =  res.valueForKey("homeLatitude") as? Double{
                    print("homeLatitude\(homeLatitude)")
                    latitude = homeLatitude
                }
                var longitude:Double = Double()
                if let homeLongitude:Double =  res.valueForKey("homeLongitude") as? Double{
                    print("homeLongitude\(homeLongitude)")
                    longitude = homeLongitude
                }
                if let workLatitude:Double =  res.valueForKey("workLatitude") as? Double{
                    print("workLatitude\(workLatitude)")
                }
                if let workLongitude:Double =  res.valueForKey("workLongitude") as? Double{
                    print("workLongitude\(workLongitude)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    //display search results in tableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
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
        btnDone.hidden = false
        btnSkip.hidden = false
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
        //autocompleteTableView.hidden = false
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
        btnDone.hidden = false
        btnSkip.hidden = false
    }
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        print("hi")
    }
    func getPlaceFromId(id: String)
    {
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
            }
            self.mapView.camera = GMSCameraPosition.cameraWithLatitude(place!.coordinate.latitude, longitude: place!.coordinate.longitude, zoom: 16)
            self.addMarker(place!.coordinate.latitude, Longitude: place!.coordinate.longitude)
         })
    }
}
