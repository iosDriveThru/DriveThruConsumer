//
//  AppDelegate.swift
//  Drive Thru
//
//  Created by Sara/Yogi on 29/12/2015.
//  Copyright © 2015 Nanite Solutions. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import PusherSwift
import CoreLocation
import Firebase
import Batch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, CLLocationManagerDelegate{
    let defaults = NSUserDefaults.standardUserDefaults()
    var locationManagerActive = CLLocationManager()
    var locationManagerBackground = CLLocationManager()
    var spotmessagesRef = Firebase(url: "https://blistering-torch-3715.firebaseio.com/storegeo/store")
    var currentLatitude:Double = 12.919687
    var currentLongitude:Double = 77.592188
    
    var userID:String = ""
    var window: UIWindow?
    var userDetailsObject = [NSManagedObject]()
    var userName:String = ""
    var userFirstName:String = ""
    var userLastName:String = ""
    var userGender:String = ""
    var userDOB:String = ""
    var userMaritialStatus:String = ""
    var userEmail:String = ""
    var userLoaction:String = ""
    var userProfilePicture:String = ""
    var userLoginId:String = ""
    var userPhoneNumber:Int = 0
    var isGoogleLogin:Bool = false
    var googleID: String = ""
    var cartJson:Cart = Cart()
    var menuJson: Menu = Menu()
    var originalMenuJson: Menu = Menu()
    var preferenceJson: Preference = Preference()
    var isMenuChanged:Bool = false
    var isPreferenceChanged:Bool = false
    var MerchantImageUrlString:String = ""
    var MerchantId:String = ""
    var MerchantName:String = ""
    var PreviousSourceType:String = ""
    var PreviousSourceItemIndex:Int = Int()
    var mappedDictionary: Dictionary<String, productDetails> = [:]
    var orderedProductDetails:OrderedDetails = OrderedDetails()
    override init()
    {
        GMSServices.provideAPIKey("AIzaSyAv74NNKnbQ4uaMlOlgngeUpFTl0wjaoQ8")
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        if let userid: String = defaults.objectForKey("user_ID") as? String
        {
           self.userID = userid
        }
        pushNotification()
        
        //Local Notification Setup Code
        let userNotificationTypes:UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound])
        let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().backgroundRefreshStatus
        //End-Local Notification Setup Code
        
        //Google and Facebook Code
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().delegate = self
        
        //Batch
        BatchPush.setupPush()
        Batch.startWithAPIKey("DEV56EA77F9A9DFEA9CDDD38271862")
        BatchPush.registerForRemoteNotifications()
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //End-Google and Facebook Code
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
        BatchPush.dismissNotifications()
    }
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return (FBSDKApplicationDelegate.sharedInstance().application(application,openURL:url,sourceApplication: sourceApplication, annotation: annotation) || GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation))
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.locationManagerActive.delegate = self
        self.locationManagerBackground.delegate = self
        
        locationManagerActive.requestAlwaysAuthorization()
        locationManagerActive.requestWhenInUseAuthorization()
        locationManagerBackground.requestAlwaysAuthorization()
        locationManagerBackground.requestWhenInUseAuthorization()
        locationManagerActive.startUpdatingLocation()
        locationManagerActive.startMonitoringVisits()
        locationManagerActive.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        application.beginBackgroundTaskWithExpirationHandler{}
        locationManagerActive.delegate = self
        locationManagerBackground.stopUpdatingLocation()
        locationManagerBackground.stopMonitoringVisits()
        locationManagerActive.requestAlwaysAuthorization()
        locationManagerActive.requestWhenInUseAuthorization()
        locationManagerBackground.requestAlwaysAuthorization()
        locationManagerBackground.requestWhenInUseAuthorization()
        locationManagerActive.startUpdatingLocation()
        locationManagerActive.startMonitoringVisits()
        locationManagerActive.distanceFilter = 10.0
        locationManagerBackground.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        DataManager.setPreference()
        self.saveContext()
    }
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        currentLatitude = manager.location!.coordinate.latitude
        currentLongitude = manager.location!.coordinate.longitude
        print("locationUpdate")
        
        spotmessagesRef.childByAppendingPath(userID).setValue([
            "parklat":currentLatitude,
            "parklng":currentLongitude
            //"user_ID":userID,
            ])
    }
    
    //GoogleSignIn Get User Deatils
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                // Perform any operations on signed in user here.
                if let idToken = user.authentication.idToken // Safe to send to the server
                {
                    print(idToken)
                }
                if let userId = user.userID
                {
                    userLoginId = userId
                    googleID = userId
                }
                if let email = user.profile.email
                {
                    self.userEmail = email
                }
                if let firstName = user.profile.name
                {
                    self.userFirstName = firstName
                }
                if let photo = user.profile.imageURLWithDimension(100)
                {
                    userProfilePicture = String(photo)
                }
                isGoogleLogin = true
                saveUserDetailsLocalStorage()
            }
            else {
                print("\(error.localizedDescription)")
            }
            
    }
    //End- GoogleSignIn Get User Deatils
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
        withError error: NSError!) {
            // Perform any operations when the user disconnects from app here.
            // [START_EXCLUDE]
            NSNotificationCenter.defaultCenter().postNotificationName("ToggleAuthUINotification", object: nil, userInfo: ["statusText": "User has disconnected."])
            // [END_EXCLUDE]
    }
    
    //Save User Deatils in Local Database using CoreData
    func saveUserDetailsLocalStorage() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("UserDetails", inManagedObjectContext:managedContext)
        let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        user.setValue(self.userFirstName, forKey: "userName")
        user.setValue(self.userFirstName, forKey: "firstName")
        user.setValue(self.userLastName, forKey: "lastName")
        user.setValue(self.userGender, forKey: "gender")
        user.setValue(self.userDOB, forKey: "dob")
        user.setValue(self.userEmail, forKey: "email")
        user.setValue(self.userMaritialStatus, forKey: "maritialStatus")
        user.setValue(self.userLoaction, forKey: "location")
        user.setValue(self.userProfilePicture, forKey: "userProfileImage")
        userDetailsObject.append(user)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = self.window!.rootViewController!.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
        self.window?.rootViewController?.presentViewController(viewController, animated: true, completion: {})
    }
    //End- Save User Deatils in Local Database using CoreData
    
    //Set up Push Notification For user Order Status- Token screen
    func pushNotification()
    {
        let pusher = Pusher(key: "1f006f9bd40000fbe5e8", options: ["secret": "118ce01e86e2ff6aa374"])
        pusher.connect()
        let chan = pusher.subscribe("consumer_\(self.userID)")
        chan.bind("consumer_event", callback: { (data: AnyObject?) -> Void in
            
            self.defaults.setValue(data, forKeyPath: "pusherValueChanged")
            if let vstatus = data?.objectForKey("order_status") as? String
            {
                if vstatus == "placed"
                {
                    self.defaults.setBool(true, forKey: "isOrderInProgress")
                }
                else  if vstatus == "inprogress"
                {
                    self.defaults.setBool(true, forKey: "isOrderInProgress")
                }
                else  if vstatus == "for_delivery"
                {
                    self.defaults.setBool(true, forKey: "isOrderInProgress")
                }
                else  if vstatus == "ready_to_pickup"
                {
                    self.defaults.setBool(true, forKey: "isOrderInProgress")
                }
                else  if vstatus == "picked_up"
                {
                    self.defaults.setBool(false, forKey: "isOrderInProgress")
                }
             }
         })
    }
    //End- Set up Push Notification For user Order Status- Token screen
    
    
    
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.nanitesolutions.Drive_Thru" in t he application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Drive_Thru", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as! NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

