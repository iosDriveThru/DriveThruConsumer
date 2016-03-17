
//
//  LoginViewController.swift
//  Drive Thru
//
//  Created by Sara/Yogi on 29/12/2015.
//  Copyright © 2015 Nanite Solutions. All rights reserved.
//

import UIKit
import CoreData
import FBSDKShareKit
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, UITextFieldDelegate {
    let defaults = NSUserDefaults.standardUserDefaults()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let numberToolbar: UIToolbar = UIToolbar()
    
    var userDetailsObject = [NSManagedObject]()
    //String
    var userName:String = ""
    var userFirstName:String = ""
    var userLastName:String = ""
    var userGender:String = ""
    var userDOB:String = ""
    var userMaritialStatus:String = ""
    var userEmail:String = ""
    var userLoaction:String = ""
    var userloggedin:String = ""
    var facebookProfileUrl:String = ""
    var resultRemovespace: String = ""
    
    // var userPassword:String = ""
    //Int
    var userPhoneNumber:Int = 0
    var facebookId:String = ""
    //   var googleId:String = ""
    //Bool
    var valFirstName: Bool = true
    var valLastName: Bool = true
    var valPhone: Bool = true
    var valEmail: Bool = true
    // var valPassword:Bool = true
    var isFacebookLogin:Bool = false
    var resultLength: Bool = false
    var resultEmpty: Bool = false
    var resultSpecialCharacter: Bool = false
    let valid =  validation()
    var dict:NSDictionary!
    var userProfilePicture:UIImage = UIImage()
    var userDetails:NSMutableArray = NSMutableArray()
    //IBOutlets
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet var FacebookLoginView: FBSDKLoginButton!
    @IBOutlet var btnSignUp: UIButton!
    @IBOutlet var txtFirstName: UITextField!
    @IBOutlet var txtLastName: UITextField!
    @IBOutlet var txtMobileNumber: UITextField!
    @IBOutlet var txtMailId: UITextField!
    //  @IBOutlet var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var titleText = NSAttributedString(string: "Log in")
        FacebookLoginView.setAttributedTitle(titleText, forState: UIControlState.Normal)
        FacebookLoginView.layer.shadowColor = UIColor.blackColor().CGColor
        FacebookLoginView.layer.shadowOffset = CGSizeMake(5, 5)
        FacebookLoginView.layer.shadowRadius = 5
        FacebookLoginView.layer.shadowOpacity = 0.8
        FacebookLoginView.layer.masksToBounds = false
        
        signInButton.layer.shadowColor = UIColor.blackColor().CGColor
        signInButton.layer.shadowOffset = CGSizeMake(5, 5)
        signInButton.layer.shadowRadius = 5
        signInButton.layer.shadowOpacity = 0.8
        signInButton.layer.masksToBounds = false
        
        
//        if let loggedin: String = defaults.objectForKey("userLoggedIn") as? String
//        {
//            self.userloggedin = loggedin
//        }
//        if let orderProgress:Bool = defaults.objectForKey("isOrderInProgress") as? Bool
//        {
//            if orderProgress == true
//            {
//                        self.performSegueWithIdentifier("segueLoginToToken", sender: self)
//                       
//            }
//        }
//
//        if self.userloggedin == "true"
//        {
//            self.performSegueWithIdentifier("segLoginview-MapView", sender: self)
//        }
        
        
        
        if appDelegate.isGoogleLogin == true
        {
            txtMailId.text = appDelegate.userEmail
            var arrayOfMappedDictKey = appDelegate.userFirstName.characters.split{$0==" "}.map(String.init)
            txtFirstName.text = arrayOfMappedDictKey[0]
            txtLastName.text = arrayOfMappedDictKey[1]
        }
        
        FBLoginViewButton()
        GIDSignIn.sharedInstance().uiDelegate = self
        btnSignUp.layer.borderWidth = 1.0
        btnSignUp.layer.cornerRadius = 5.0
        btnSignUp.layer.borderColor = UIColor(red: 46/255, green: 115/255, blue: 252/255, alpha: 1.0).CGColor
        // checkLoggedInUser()
        // toggleAuthUI()
        Delegate()
        
        numberToolbar.barStyle = UIBarStyle.BlackTranslucent
        numberToolbar.items=[
            UIBarButtonItem(title: "Return", style: UIBarButtonItemStyle.Bordered,target: self, action: "DismissKeyBoard"),
            //UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
        ]
        numberToolbar.tintColor = UIColor.blackColor()
        let navBarColor = UIColor (red:207/250.0, green:211/250.0, blue:217/250.0, alpha:1.0)
        numberToolbar.barTintColor = navBarColor
        numberToolbar.sizeToFit()
        txtMobileNumber.inputAccessoryView = numberToolbar
      }
    func DismissKeyBoard () {
        
        txtMobileNumber.resignFirstResponder()
     }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if let loggedin: String = defaults.objectForKey("userLoggedIn") as? String
        {
            self.userloggedin = loggedin
        }
        if let orderProgress:Bool = defaults.objectForKey("isOrderInProgress") as? Bool
                {
                    if orderProgress == true
                    {
                                self.performSegueWithIdentifier("segueLoginToToken", sender: self)
        
                    }
                    
                }
       if self.userloggedin == "true"
        {
            self.performSegueWithIdentifier("segLoginview-MapView", sender: self)
        }
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //@IBAction
    @IBAction func btnSignUp_Click(sender: AnyObject) {
        
        let userPhNumber = txtMobileNumber.text!
        
        if( (valFirstName == false) || (valLastName == false ) || (valPhone == false) ||  (valEmail == false))
        {
            print("Fields are empty")
        }
            
        else if ((txtFirstName.text == "") || (txtLastName.text == "") || (txtMailId.text == "") ||  (txtMobileNumber.text == "")){
        }
        else
        {
            insertLoginDetails()
            
        }
        defaults.setValue(userEmail, forKey: "userMailId")
        defaults.setValue(userPhNumber, forKey: "userPhoneNumber")
        defaults.setValue(userName, forKey: "userName")
    }
    @IBAction func txtEmailIdvalidate_click(sender: AnyObject){
        resultLength =  valid.checkMinLength(txtMailId,textStatusLabel: "Empty")
        resultEmpty =  valid.checkEmpty(txtMailId)
        txtMailId.text = valid.removeSpaceFromString(txtMailId.text!)
        if(resultLength == false || resultEmpty == false)
        {
            txtMailId.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            txtMailId.layer.borderWidth = 1.0
            valEmail = false
        }
        else
        {
            txtMailId.layer.borderWidth = 0.0
            txtMailId.hidden = true
            valEmail = true
        }
    }
    @IBAction func txtFirstNameValidate_Click(sender: AnyObject){
        resultLength =  valid.checkMinLength(txtFirstName, textStatusLabel: "Empty")
        resultEmpty =  valid.checkEmpty(txtFirstName)
        txtFirstName.text = valid.removeSpaceFromString(txtFirstName.text!)
        if(resultLength == false || resultEmpty == false)
        {
            txtFirstName.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            txtFirstName.layer.borderWidth = 1.0
            valFirstName = false
        }
        else
        {
            txtFirstName.layer.borderWidth = 0.0
            valFirstName = true
        }
    }
    @IBAction func txtLastNameValidate_Click(sender: AnyObject) {
        resultLength =  valid.checkMinLength(txtLastName, textStatusLabel: "Empty")
        resultEmpty =  valid.checkEmpty(txtLastName)
        txtLastName.text = valid.removeSpaceFromString(txtLastName.text!)
        if(resultLength == false || resultEmpty == false)
        {
            txtLastName.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            txtLastName.layer.borderWidth = 1.0
            valLastName = false
        }
        else
        {
            txtLastName.layer.borderWidth = 0.0
            valLastName = true
        }
    }
    @IBAction func txtPhoneNumberValidate_Click(sender: AnyObject){
        resultLength =  valid.checkLenPhone(txtMobileNumber, iLength: 10)
        resultEmpty =  valid.checkEmpty(txtMobileNumber)
        txtMobileNumber.text = valid.removeSpaceFromString(txtMobileNumber.text!)
        if(resultLength == false || resultEmpty == false)
        {
            txtMobileNumber.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            txtMobileNumber.layer.borderWidth = 1.0
            valPhone = false
        }
        else
        {
            txtMobileNumber.layer.borderWidth = 0.0
            valPhone = true
        }
    }
    
    func Delegate(){
        txtFirstName.delegate = self
        txtLastName.delegate = self
        txtMobileNumber.delegate = self
        txtMailId.delegate = self
    }
    
    
    //FacebookLogin
    func FBLoginViewButton(){
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
        }
        else
        {
            FacebookLoginView.readPermissions = ["public_profile", "email", "user_friends"]
            FacebookLoginView.delegate = self
        }
    }
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
        returnUserData()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        txtFirstName.text = ""
        txtLastName.text = ""
        txtMailId.text = ""
        txtMobileNumber.text = ""
    }
    
    func returnUserData(){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,name,first_name,last_name,location,gender,birthday,link"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                if let userName : String = result.valueForKey("name") as? String
                {
                    self.userName = userName
                }
                if let firstName : String = result.valueForKey("first_name") as? String
                {
                    self.userFirstName = firstName
                }
                
                if let lastName : String = result.valueForKey("last_name") as? String
                {
                    self.userLastName = lastName
                }
                if let gender : String = result.valueForKey("gender") as? String
                {
                    self.userGender = gender
                }
                if let mail : String = result.valueForKey("email") as? String
                {
                    self.userEmail = mail
                }
                if let location : String = result.valueForKey("location") as? String
                {
                    self.userLoaction = location
                }
                if let dob : String = result.valueForKey("birthday") as? String
                {
                    self.userDOB = dob
                }
                if let userId :String = result.valueForKey("id") as? String
                {
                    self.facebookId = userId
                }
                self.dict = result as! NSDictionary
                self.facebookId = (self.dict.objectForKey("id") as? String)!
                self.facebookProfileUrl = "https://graph.facebook.com/\(self.facebookId)/picture?type=large"
                self.saveUserDetailsLocalStorage()
              //  self.insertLoginDetails()
            }
        })
        isFacebookLogin = true
        appDelegate.isGoogleLogin = false
    }
    
    func saveUserDetailsLocalStorage() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("UserDetails",
            inManagedObjectContext:managedContext)
        let user = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        user.setValue(self.userName, forKey: "userName")
        user.setValue(self.userFirstName, forKey: "firstName")
        user.setValue(self.userLastName, forKey: "lastName")
        user.setValue(self.userGender, forKey: "gender")
        user.setValue(self.userDOB, forKey: "dob")
        user.setValue(self.userEmail, forKey: "email")
        user.setValue(self.userMaritialStatus, forKey: "maritialStatus")
        user.setValue(self.userLoaction, forKey: "location")
        user.setValue(self.facebookProfileUrl, forKey: "userProfileImage")
        do {
            try managedContext.save()
            userDetailsObject.append(user)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        //performSegueWithIdentifier("segLoginview-MapView", sender: self)
        txtFirstName.text = userFirstName
        txtLastName.text = userLastName
        txtMailId.text = userEmail
    }
    
    //GoogleLogin
    func toggleAuthUI() {
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
            // Signed in
            signInButton.hidden = true
            //FacebookLoginView.hidden = true
            //  signOutButton.hidden = false
            //  disconnectButton.hidden = false
            
        } else {
            signInButton.hidden = false
            FacebookLoginView.hidden = false
            //  signOutButton.hidden = true
            //  disconnectButton.hidden = true
            //  statusText.text = "Google Sign in\niOS Demo"
        }
    }
    func checkLoggedInUser()
    {
        if let userloggedin: String = defaults.objectForKey("userLoggedIn") as? String
        {
            if userloggedin == "true"
            {
                performSegueWithIdentifier("segLoginview-MapView", sender: self)
            }
        }
    }
    
    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool
    {
        var inverseSet:NSCharacterSet!
        var newLength:Int
        var lenChk:Bool
        lenChk = false
        if(textField == txtFirstName)
        {
            // Create an `NSCharacterSet` set which includes everything *but* the digits
            inverseSet = NSCharacterSet(charactersInString:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz .'").invertedSet
            newLength = textField.text!.characters.count + string.characters.count - range.length
            if(newLength <= 20)
            {
                lenChk = true
            }
            else
            {
                lenChk = false
            }
        }
        if(textField == txtLastName)
        {
            // Create an `NSCharacterSet` set which includes everything *but* the digits
            inverseSet = NSCharacterSet(charactersInString:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz .'").invertedSet
            newLength = textField.text!.characters.count + string.characters.count - range.length
            if(newLength <= 20)
            {
                lenChk = true
            }
            else
            {
                lenChk = false
            }
        }
        
        if(textField == txtMobileNumber)
        {
            // Create an `NSCharacterSet` set which includes everything *but* the digits
            inverseSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
            
            newLength = textField.text!.characters.count + string.characters.count - range.length
            if(newLength <= 10)
            {
                lenChk = true
            }
            else
            {
                lenChk = false
            }
        }
        
        if(textField == txtMailId)
        {
            // Create an `NSCharacterSet` set which includes everything *but* the digits
            inverseSet = NSCharacterSet(charactersInString:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@.").invertedSet
            
            newLength = textField.text!.characters.count + string.characters.count - range.length
            if(newLength <= 30)
            {
                lenChk = true
            }
            else
            {
                lenChk = false
            }
        }
        // At every character in this "inverseSet" contained in the string,
        // split the string up into components which exclude the characters
        // in this inverse set
        let components = string.componentsSeparatedByCharactersInSet(inverseSet)
        // Rejoin these components
        let filtered = components.joinWithSeparator("")
        // If the original string is equal to the filtered string, i.e. if no
        // inverse characters were present to be eliminated, the input is valid
        // and the statement returns true; else it returns false
        return (string == filtered && lenChk)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    //Inserting user details into server
    
    func insertLoginDetails()
    {
        userFirstName = txtFirstName.text!
        userLastName = txtLastName.text!
        userEmail = txtMailId.text!
        let  userNumber = txtMobileNumber.text!
        var request:NSMutableURLRequest = NSMutableURLRequest()
        //http://sqweezy.com/DriveThru/create_user.php?fid=15&first_name=sagar&last_name=k&email=sagar@gmail.com&password=123&mobile=8105550288
        if isFacebookLogin == true{
            request = NSMutableURLRequest(URL: NSURL(string: "http://sqweezy.com/DriveThru/create_user.php?fid=\(facebookId)&first_name=\(userFirstName)&last_name=\(userLastName)&email=\(userEmail)&mobile=\(userNumber)&image_url=\(facebookId)")!)
        }
        else if appDelegate.isGoogleLogin == true
        {
            request = NSMutableURLRequest(URL: NSURL(string: "http://sqweezy.com/DriveThru/create_user.php?gid=\(appDelegate.googleID)&first_name=\(userFirstName)&last_name=\(userLastName)&email=\(userEmail)&mobile=\(userNumber)&image_url=\(appDelegate.userProfilePicture)")!)
           
        }
        else
        {
            request = NSMutableURLRequest(URL: NSURL(string: "http://sqweezy.com/DriveThru/create_user.php?first_name=\(userFirstName)&last_name=\(userLastName)&email=\(userEmail)&mobile=\(userNumber)")!)
        }
         print(request)
        
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            // handle error
            guard error == nil
                else
            {
                return
            }
            
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let json: NSDictionary?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
            } catch let dataError {
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                // return or throw?
                return
            }
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                let success:NSMutableArray = (parseJSON["result"] as? NSMutableArray)!
                for index in 0...success.count-1{
                    if let userId:String = success.objectAtIndex(index).objectForKey("user_id") as? String{
                        self.defaults.setValue("true", forKey: "userLoggedIn")
                        self.defaults.setValue(userId, forKey: "user_ID")
                        self.appDelegate.userID = userId
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.performSegueWithIdentifier("segLoginview-MapView", sender: self)
                        })
                    }
                    if let userId:String = success.objectAtIndex(index).objectForKey("last_insted_userID") as? String{
                        self.defaults.setValue("true", forKey: "userLoggedIn")
                        self.defaults.setValue(userId, forKey: "user_ID")
                        self.appDelegate.userID = userId
                        dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("segLoginview-MapView", sender: self)
                        })
                    }
                }
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
            }
            
        })
        task.resume()
    }
    
}
