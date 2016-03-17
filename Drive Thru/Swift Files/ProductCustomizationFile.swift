//
//  ProductCustomizationFile.swift
//  Drive Thru
//
//  Created by Nanite on 03/02/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import Foundation
import UIKit
import Gloss


public struct Customizationdetails: Decodable, Encodable {
    
    public var CustomizationcategoryDetails: [CustmizationCategoryDetails] = []
    
    
    public init?(json: JSON) {
        self.CustomizationcategoryDetails = ("categories" <~~ json)!
        
        
    }
    
    
    public func toJSON() -> JSON? {
        return jsonify([
            "categories" ~~>  self.CustomizationcategoryDetails,
            ])
    }
    
}



public struct CustmizationCategoryDetails: Decodable, Encodable {
    public var ProductCategoryName:String
    public var CategoryValue:[CustomizationCategoryValue] = []
    
    
    public init?(json: JSON) {
        self.ProductCategoryName = ("Category_Name" <~~ json)!
        self.CategoryValue = ("Values" <~~ json)!
        
    }
    
    
    public func toJSON() -> JSON? {
        return jsonify([
            "Category_Name" ~~>  self.ProductCategoryName,
            "Values" ~~> self.CategoryValue
            ])
    }
    
}




public struct CustomizationCategoryValue: Decodable, Encodable {
    public var CategoryValueName:String
    public var StoreAliasName:String
    public var customisationIsSelected:Bool
    public var IdCustomizationValueAlias:Int
    public var CustomizationPrice:Double
    public var customizationCatID:Int
   // public var preferenceAliasId:Int
   
      public init?(json: JSON) {
        self.CategoryValueName = ("category_value_name" <~~ json)!
        self.StoreAliasName = ("store_alias_name" <~~ json)!
        self.IdCustomizationValueAlias = ("id_customization_value_alias" <~~ json)!
        self.CustomizationPrice = ("customization_price" <~~ json)!
        self.customisationIsSelected = ("selected" <~~ json)!
        self.customizationCatID = ("category_ID" <~~ json)!
       // self.preferenceAliasId = ("preference_alias_id" <~~ json)!
    }
    
    public init?(){
        self.CategoryValueName = ""
        self.StoreAliasName = ""
        self.IdCustomizationValueAlias = 0
        self.CustomizationPrice = 0
        self.customisationIsSelected = false
        self.customizationCatID = 0
      //  self.preferenceAliasId = 0
}
    
    
    
    
    public func toJSON() -> JSON? {
        if(self.customisationIsSelected)
        {
        return jsonify([
            "category_value_name" ~~>  self.CategoryValueName,
            "store_alias_name" ~~> self.StoreAliasName,
            "id_customization_value_alias" ~~>  self.IdCustomizationValueAlias,
            "customization_price" ~~> self.CustomizationPrice,
            "category_ID" ~~> self.customizationCatID
            
          //  "id_merchant" ~~> self.IdMerchant
            ])
        }
        else
        {
            return nil
        }
    }
}

public struct selectedCustomization: Encodable{
    
    public var CategoryValueName:String
    public var StoreAliasName:String
    public var customisationIsSelected:Bool
    public var IdCustomizationValueAlias:Int
    public var CustomizationPrice:Double
    public var customizationCatID:Int
    
    init(catId : Int, catName : String, storeAliasName : String, IdCustValueAlias : Int, price: Double, selected: Bool )
    {
        customizationCatID = catId
     CategoryValueName = catName
        StoreAliasName = storeAliasName
        IdCustomizationValueAlias = IdCustValueAlias
        CustomizationPrice = price
        customisationIsSelected = selected
        
    }
    
    public func toJSON() -> JSON? {
      
            return jsonify([
                "category_ID" ~~> self.customizationCatID,
                "category_value_name" ~~>  self.CategoryValueName,
                "store_alias_name" ~~> self.StoreAliasName,
                "id_customization_value_alias" ~~>  self.IdCustomizationValueAlias,
                "customization_price" ~~> self.CustomizationPrice
                
               
                ])
        }
 }

