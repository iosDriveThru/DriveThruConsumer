//
//  Validation.swift
//  Consumer
//
//  Created by Praveen Kumar on 15/05/15.
//  Copyright (c) 2015 nanite. All rights reserved.
//

import Foundation

class validation: UIViewController{
    var isEntriesValid = true
    func checkEmpty(textField: UITextField) -> Bool
    {
        isEntriesValid = true
        if textField.text == ""
        {
            isEntriesValid = false
            textField.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            textField.layer.borderWidth = 1.0
        }
        else
        {
            isEntriesValid = true
            textField.layer.borderWidth = 0.0
        }
        return isEntriesValid
    }
    func checkLenPhone(textField: UITextField, iLength: Int) -> Bool
    {
        isEntriesValid = true
        let result: Bool = true
        let iInt = textField.text!.characters.count
        if( iInt != iLength)
        {
            isEntriesValid = false
            textField.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            textField.layer.borderWidth = 1.0
        }
        return result
    }
    func checkLen(textField: UITextField, iLength: Int, textStatusLabel: UILabel) -> Bool
    {
        isEntriesValid = true
        let iInt = textField.text!.characters.count
        if( iInt > iLength)
        {
            isEntriesValid = false
            //        textStatusLabel.hidden = false
            //        textField.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            //        textField.layer.borderWidth = 1.0
            //        textStatusLabel.text = "error"
            
        }
        else
        {
            isEntriesValid = true
            //        textField.layer.borderWidth = 0.0
            //        textStatusLabel.hidden = true
            //
        }
        return isEntriesValid
    }
    func checkNumber(textField:UITextField) -> Bool
    {
        if let numericValue = Int(textField.text!) {
            //textField.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            textField.layer.borderWidth = 0.0
            return true
        }
        else
        {
            textField.text = ""
            textField.placeholder = "Enter Number"
            textField.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            textField.layer.borderWidth = 1.0
            return false
        }
    }
    func checkLeadingSpace(textField: UITextField)
    {
        _ = NSCharacterSet.whitespaceCharacterSet()
    }
    func firstLetterUpperCase(textField: UITextField)
    {
        textField.text = textField.text!.capitalizedString
    }
    func checkMinLength(textField: UITextField, textStatusLabel: String) -> Bool
    {
        isEntriesValid = true
        if(textField.text!.characters.count<3)
        {
            isEntriesValid = false
            //   lblValidateMessage.text = "Require Minimum 3 Characters"
            //        textField.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            //        textField.layer.borderWidth = 1.0
            //        textStatusLabel.text = "Require Minimum 3 Characters"
            //        textStatusLabel.hidden = false
        }
        else
        {
            isEntriesValid = true
            //textField.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            // textField.layer.borderWidth = 0.0
            //textStatusLabel.hidden = true
        }
        return isEntriesValid
    }
    func removeSpaceFromString(cityString: NSString) ->String {
        var cityWOSpace: String = cityString as String
        if cityString.rangeOfString(" ").location != NSNotFound {
            cityWOSpace = cityString.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: NSMakeRange(0, cityString.length))
        }
        return cityWOSpace
    }
    
    func nameContainsSpecialCharacter(textField:UITextField, textStatusLabel: UILabel) -> Bool
    {
        let strPassedText: String = textField.text!
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z\\s'].*", options: [])
        if (regex.firstMatchInString(strPassedText as String, options: [], range: NSMakeRange(0, strPassedText.characters.count)) != nil) {
            isEntriesValid = false
            //        textField.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            //        textField.layer.borderWidth = 1.0
            //        result = true
            //         textStatusLabel.text = "nameContainsSpecialCharacter - there are NO special characters"
            //        textStatusLabel.hidden = false
        }
        else
        {
            isEntriesValid = true
            //        textField.layer.borderWidth = 0.0
            //
            //        result = false
            //        textStatusLabel.hidden = true
        }
        return isEntriesValid
    }
}
