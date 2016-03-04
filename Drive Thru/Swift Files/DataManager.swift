//
//  DataManager.swift
//  TopApps
//
//  Created by Attila on 2015. 11. 10..
//  Copyright © 2015. -. All rights reserved.
//

import Foundation

public class DataManager {
    
    
    public class func getTopAppsDataFromFileWithSuccess(success: ((data: NSData) -> Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let filePath = NSBundle.mainBundle().pathForResource("getMenu", ofType:"json")
            let data = try! NSData(contentsOfFile:filePath!,
                options: NSDataReadingOptions.DataReadingUncached)
            success(data: data)
        })
    }
    
    public class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            
            let session = NSURLSession.sharedSession()
            
            let loadDataTask = session.dataTaskWithURL(url) { (data, response, error) -> Void in
                if let responseError = error {
                    completion(data: nil, error: responseError)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        let statusError = NSError(domain:"com.Drivethru", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                        completion(data: nil, error: statusError)
                    } else {
                        completion(data: data, error: nil)
                    }
                }
            }
            loadDataTask.resume()
        })
    }
    
    
    public class func getDataFromRestfullWithSuccess(strUrl: String, success: ((iTunesData: NSData!) -> Void)) {
        //1
        loadDataFromURL(NSURL(string: strUrl)!, completion:{(data, error) -> Void in
            //2
            if let data = data {
                //3
                success(iTunesData: data)
            }
        })
    }
    
    
    
    public class func setPreference()
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var savePreference:SetPreference = SetPreference()
        savePreference.Consumer_ID = Int(appDelegate.userID)
        savePreference.Merchant_ID = Int(appDelegate.MerchantId)
        savePreference.setPreference = appDelegate.preferenceJson
        let savePreferenceJsonObject = savePreference.toJSON()
        print(savePreferenceJsonObject)
        var savePreferenceJsonData: NSData!
        do {
            savePreferenceJsonData = try NSJSONSerialization.dataWithJSONObject(savePreferenceJsonObject!, options: NSJSONWritingOptions())
            
        } catch {
            print(error)
            
        }
        
        
        DataManager.saveJsonToRestfull(savePreferenceJsonData, url: "http://sqweezy.com/DriveThru/save_user_preferences.php")
        appDelegate.isPreferenceChanged = false
    }
    
    
    public class func saveJsonToRestfull(jSonData: NSData, url:String)
    {
        let encodedImage = jSonData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        let parameters = ["image": encodedImage, "otherParam": "otherValue"]
        
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
            
            var json: [String: AnyObject]!
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String: AnyObject]
            } catch {
                print(error)
                
            }
        }
        dataTask.resume()
        
    }
}
