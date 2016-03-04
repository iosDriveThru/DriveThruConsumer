//
//  MapViewController.swift
//  Drive Thru
//
//  Created by Nanite Solutions on 1/2/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Firebase
import GeoFire

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    //variable
    let defaults = NSUserDefaults.standardUserDefaults()
    var currentLatitude:Double = 12.919687
    var currentLongitude:Double = 77.592188
    var Store_Latitude:Double!
    var Store_Longitude:Double!
    var cameraZoom:Double = 17
    var manager: CLLocationManager?
    var StoreAddress:String!
    var MerchantImage:String = String()
    //firebase
    var geofireRef:Firebase = Firebase(url: "https://blistering-torch-3715.firebaseio.com")
    var geoFire:GeoFire!
    var geoFireGeoFence:GeoFire!
    var spotmessagesRef = Firebase(url: "https://blistering-torch-3715.firebaseio.com/storegeo/store1")
    var otherCarLocation:CLLocation!
    var otherCar_Key:String!
    var userID:String = "10"
    var token: dispatch_once_t = 0
    var listener = [String : Firebase]()
    var spaces_cars_in_vicinity_dict:NSMutableDictionary = NSMutableDictionary()
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //IBOutlet         //https://blistering-torch-3715.firebaseio.com/
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var btnRecenter: UIButton!
    @IBOutlet var button: UIButton!
    //@IBAction
    @IBAction func btnRecenter_Click(sender: AnyObject) {
        mapView.camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude:currentLongitude, zoom:Float(cameraZoom))
        btnRecenter.hidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // currentLatitude = manager!.location!.coordinate.latitude
        // currentLongitude = manager!.location!.coordinate.longitude
        mapRelatedSettings()
        CLLocationRegion()
        //self.getstoresList()
        if appDelegate.isPreferenceChanged
        {
            DataManager.setPreference()
        }
        
        //  setupGeoFireForCurrentLocation(currentLatitude, lng: currentLongitude)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        //Add the map to the Main view
        self.view.addSubview(mapView)
        mapView.camera = GMSCameraPosition.cameraWithLatitude(currentLatitude, longitude:currentLongitude, zoom:Float(cameraZoom))
        //        let bounds = UIScreen.mainScreen().bounds
        //        let screenHeight = bounds.size.height/2
        //        let mapInsets:UIEdgeInsets = UIEdgeInsetsMake(screenHeight+10, 10.0, 10.0, 10.0)
        //        mapView.padding = mapInsets
        // self.mapView.mapType = kGMSTypeNormal
        mapView.addSubview(btnRecenter)
        
    }
    func CLLocationRegion()
    {
        manager = CLLocationManager()
        manager?.delegate = self;
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        let available = CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)
        manager?.requestWhenInUseAuthorization()
        manager?.requestAlwaysAuthorization()
        manager?.startUpdatingLocation()
        self.manager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.manager?.distanceFilter = kCLDistanceFilterNone;
        self.manager?.activityType = CLActivityType.AutomotiveNavigation
        //self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled()
            && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
                mapView.myLocationEnabled = true
        }
        let currRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 12.919687, longitude:77.592188), radius: 200, identifier: "Location")
        manager?.startMonitoringForRegion(currRegion)
        
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLatitude = manager.location!.coordinate.latitude
        currentLongitude = manager.location!.coordinate.longitude
        // let myLocation = manager.location!.coordinate
        //var myLocation = CLLocationCoordinate2DMake(40.315629, -74.624081)
        //  let camUpdate = GMSCameraUpdate.setTarget(myLocation, zoom: Float(cameraZoom))
        //  mapView.animateWithCameraUpdate(camUpdate)
        dispatch_once(&self.token) { () -> Void in
            
            self.getstoresList()
        }
     }
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        NSLog("Entering region")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        NSLog("Exit region")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("\(error)")
    }
    
    //show stores marker on map
    func getstoresList(){
        
        DataManager.getDataFromRestfullWithSuccess("http://sqweezy.com/DriveThru/get_nearby_stores.php?lat=\(currentLatitude)&lng=\(currentLongitude)") { (data) -> Void in
            var json: NSDictionary?
            // 1
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
                
                let merchantDictionary:NSDictionary = json!.objectForKey("Stores") as! NSDictionary
                let MerchantArray = merchantDictionary.objectForKey("Merchant_Array") as! NSMutableArray
                for merchantArrayIndex in 0...MerchantArray.count-1{
                    let merchant = MerchantArray.objectAtIndex(merchantArrayIndex).objectForKey("Merchant") as! NSDictionary
                    var merchantId:Int!
                    if let merchant_id:Int = merchant.objectForKey("Merchant_ID") as? Int
                    {
                        merchantId = merchant_id
                    }
                    if let Merchant_Image:String = merchant.objectForKey("Merchant_Image") as? String
                    {
                        self.MerchantImage = Merchant_Image
                    }
                    var MerchantName:String!
                    if let Merchant_Name:String = merchant.objectForKey("Merchant_Name") as? String
                    {
                        MerchantName = Merchant_Name
                    }
                    let StoreArray = merchant.objectForKey("Store_Array") as! NSMutableArray
                    for storeArrayIndex in 0...StoreArray.count-1{
                        let merchant = StoreArray.objectAtIndex(storeArrayIndex).objectForKey("Store") as! NSDictionary
                        var StoreID:Int!
                        if let Store_ID:Int = merchant.objectForKey("Store_ID") as? Int
                        {
                            StoreID = Store_ID
                        }
                        if let Store_Address:String = merchant.objectForKey("Store_Address") as? String
                        {
                            self.StoreAddress = Store_Address
                        }
                        if let Store_Lat:Double = merchant.objectForKey("Store_Lat") as? Double
                        {
                            self.Store_Latitude = Store_Lat
                        }
                        if let Store_Lng:Double = merchant.objectForKey("Store_Lng") as? Double
                        {
                            self.Store_Longitude = Store_Lng
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            self.addMarkerforStore(self.Store_Latitude, storeLongitude: self.Store_Longitude, storeAddress: self.StoreAddress, storeImage: self.MerchantImage)
                        })                        
                    }
                }
                
            }
            catch {
                print(error)
            }
        }
        var myLocation = CLLocationCoordinate2DMake(currentLatitude, currentLongitude)
        let camUpdate = GMSCameraUpdate.setTarget(myLocation, zoom: Float(cameraZoom))
        mapView.animateWithCameraUpdate(camUpdate)
    }
    func addMarkerforStore(storeLatitude:Double, storeLongitude:Double, storeAddress: String, storeImage:String)
    {
        let marker:GMSMarker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(storeLatitude, storeLongitude)
        marker.snippet = storeAddress
        let storeImageName = storeImage
        let url = NSURL(string: storeImageName)
        let imageData = NSData(contentsOfURL: url!)
        marker.icon = resizeImage(UIImage(data: imageData!)!, scaledToSize: CGSizeMake(30,30))
        marker.map = mapView
    }
    func resizeImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        //        marker.snippet = "hi"
        //        marker.title = StoreAddress
        //        marker.snippet = "Population: 8,174,100"
        //        marker.infoWindowAnchor = CGPointMake(0.5, 0.5)
        //        marker.map = mapView
        //mapCenterPinImage.fadeOut(0.25)
        
        if (marker.icon == UIImage(named:"CarFilled.png")){
            return true
        }
        else{
            setupGeoFireForCurrentLocation(currentLatitude, lng: currentLongitude)
            return false
        }
    }
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        // btnRecenter.hidden = false
        if (gesture) {
            //mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
        let infoWindow = NSBundle.mainBundle().loadNibNamed("CustomInfoWindow", owner: self, options: nil).first as! CustomInfoWindow
        infoWindow.layer.cornerRadius = 6
        if (marker.icon == UIImage(named:"CarFilled.png")){
            infoWindow.hidden = true
        }
        else{
            infoWindow.lblAddress.text = "3 orders before you"
            //infoWindow.photo.image = UIImage(named: "SydneyOperaHouseAtNight")
            mapView.addSubview(infoWindow)
        }
        return infoWindow
        
    }
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
      // getMerchantPreferenceitems(1)
        getMerchantMenuitems(1)
    }
    
    //Firebase and GeoFire
    func setupGeoFireForCurrentLocation(lat: Double, lng: Double){
        geoFire = GeoFire(firebaseRef: spotmessagesRef)
        let geofirecenter = CLLocation(latitude: lat, longitude: lng)
        // Query locations at current location with a radius of 2 km
        let circleQuery = geoFire.queryAtLocation(geofirecenter, withRadius: 2)
        setupListners(circleQuery)
        // setup_push_infrastructure()
        //        previous_spot_geofence_lat = currentLat
        //        previous_spot_geofence_lng = currentLng}
        //
    }
    
    func setupListners(query:GFQuery){
        var queryHandleEntered = query.observeEventType(GFEventTypeKeyEntered, withBlock:{(key: String!, location: CLLocation!) in
            self.otherCar_Key = key
            self.otherCarLocation = location
            self.AddShopMarker(location.coordinate.latitude, mlongitude: location.coordinate.longitude, car_key: key)
            
            //                if(key != self.userID)
            //                {
            //                    let temp = self.spotmessagesRef.childByAppendingPath(key)
            //                    self.listener[key] = temp
            //                    temp.observeEventType(.ChildAdded,withBlock:{
            //                        snapshot in
            //                        let lattitude = snapshot.value["lattitude"] as? String
            //                        let longitude = snapshot.value["longitude"] as? String
            //
            //                        if let vspotID = snapshot.value["shore1"] as? String
            //                        {
            //                            print("fdgthgg")
            //                        }
            //                        let spot_status: String!
            //                        if let vSpot_Status = snapshot.value["store2"] as? String
            //                        {
            //                            spot_status = vSpot_Status
            //
            //                        }
            //                    })
            //                    temp.observeEventType(.ChildChanged, withBlock: { snapshot in
            //                        if let vspotID = snapshot.value["shore1"] as? String
            //                        {
            //                            print("fdgthgg")
            //                        }
            //                        var spot_status: String!
            //                        if let vSpot_Status = snapshot.value["store2"] as? String
            //                        {
            //                            spot_status = vSpot_Status
            //
            //                        }                    })
            //                    self.AddShopMarker(location.coordinate.latitude, mlongitude: location.coordinate.longitude, car_key: key)
            //                } //if(key != self.userID)
        })
        var queryHandleMoved = query.observeEventType(GFEventTypeKeyMoved, withBlock: { (key: String!, location: CLLocation!) in
            self.otherCar_Key = key
            self.otherCarLocation = location
            if(key != self.userID)
            {
                self.UpdateGeoCarMarker(location.coordinate.latitude, mlongitude: location.coordinate.longitude, car_key: key)
            }
        })
        var queryHandleExited = query.observeEventType(GFEventTypeKeyExited, withBlock: { (key: String!, location: CLLocation!) in
            if(key != self.userID)
            {
                self.RemoveGeoCarMarker(key)
            }
        })
    }
    
    func AddShopMarker(mlatitude:CLLocationDegrees, mlongitude:CLLocationDegrees, car_key:String!){
        if (mlatitude != 0.0) {
            let gaddMarker:GMSMarker = GMSMarker()
            gaddMarker.position = CLLocationCoordinate2DMake(mlatitude, mlongitude)
            spaces_cars_in_vicinity_dict.setObject(gaddMarker, forKey:car_key)
            let carMarker = UIImage(named: "CarFilled.png")
            gaddMarker.icon = resizeImage(carMarker!, scaledToSize: CGSizeMake(30,30))
            //locationMarker1.icon = imageWithImage(clustImage!, scaledToSize: CGSizeMake(30,30))
            //useless comment
            
            gaddMarker.map = mapView
        }
    }
    func setupListners_ZoomInfrastructure(query:GFQuery){
        var queryHandleEntered = query.observeEventType(GFEventTypeKeyEntered, withBlock:{(key: String!, location: CLLocation!) in
            // println("Key '\(key)' entered the search area and is at location '\(location)'")
            //call function to zoom into 21
            //println("inside zoom in")
            
        })
        var queryHandleExited = query.observeEventType(GFEventTypeKeyExited, withBlock:{(key: String!, location: CLLocation!) in
            // // println("Key '\(key)' exited the search area and is at location '\(location)'")
            //call function to zoom out into 17
        })
    }
    func createGeoFireGeoFence()
    {
        let geofiregeofencecenter = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
        let geofencecircleQuery = geoFireGeoFence.queryAtLocation(geofiregeofencecenter, withRadius: 0.1)
        setupListners_ZoomInfrastructure(geofencecircleQuery)
    }
    func createGeoFireGeoFenceSpot(spot_lat:Double, spot_lng:Double){
        let geofiregeofencecenter = CLLocation(latitude: spot_lat, longitude: spot_lat)
        let geofencecircleQuery = geoFireGeoFence.queryAtLocation(geofiregeofencecenter, withRadius: 0.1)
        setupListners_ZoomInfrastructure(geofencecircleQuery)
    }
    
    
    func UpdateGeoCarMarker(mlatitude:CLLocationDegrees, mlongitude:CLLocationDegrees, car_key:String!){
        var gupdateMarker:GMSMarker = GMSMarker()
        if let vgupdateMarker = spaces_cars_in_vicinity_dict.objectForKey(car_key) as? GMSMarker
        {
            gupdateMarker = vgupdateMarker
        }
        gupdateMarker.position.latitude = mlatitude
        gupdateMarker.position.longitude = mlongitude
        gupdateMarker.map = mapView
    }
    func RemoveGeoCarMarker(car_key:String!){
        var gremoveMarker:GMSMarker = GMSMarker()
        gremoveMarker = spaces_cars_in_vicinity_dict.objectForKey(car_key) as! GMSMarker
        gremoveMarker.map = nil
    }
    
    
    func getMerchantMenuitems(merchantID: Int)
    {
        print(appDelegate.userID)
        DataManager.getDataFromRestfullWithSuccess("http://sqweezy.com/DriveThru/get_menu.php?merchant_id=\(merchantID)&consumer_id=\(appDelegate.userID)") { (data) -> Void in
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
                    self.performSegueWithIdentifier("segMap-MenuVC", sender: self)
                })
                
            }
            else {
                print("Error initializing object")
                return
            }
        }
    }
    
    func getMerchantPreferenceitems(merchantID: Int)
    {
        DataManager.getDataFromRestfullWithSuccess("http://sqweezy.com/DriveThru/Get_Preference.php?merchant_id=\(merchantID)&consumer_id=\(appDelegate.userID)") { (data) -> Void in
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
}

