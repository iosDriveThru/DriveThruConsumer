//
//  ProductItemsDetailsFile.swift
//  Drive Thru
//
//  Created by Nanite on 04/02/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//


//Product Details File



import Foundation
import UIKit
import Gloss

//Order

public struct Order: Encodable {
    public var order:Cart = Cart()
    
    
    
    public init?(json: JSON) {
        order = ("order" <~~ json)!
        
    }
    
    public init()
    {
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "order" ~~> self.order
            ])
    }
    
    
    
    
    
}

//End- Order




//SetPreference

public struct SetPreference: Encodable {
    public var setPreference:Preference = Preference()
    public var Consumer_ID:Int?
    public var  Merchant_ID:Int?
    
    
    
    public init?(json: JSON) {
        setPreference = ("setPreference" <~~ json)!
        
    }
    
    public init()
    {
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "preference" ~~> self.setPreference,
            "Consumer_ID" ~~> self.Consumer_ID,
            "Merchant_ID" ~~> self.Merchant_ID
            ])
    }
    
    
    
    
    
}

//End- SetPreference




// Menu

public struct Menu: Decodable, Encodable {
    public var products: [productDetails] = []
    public var ConsumerID:Int
    
    public init?(json: JSON) {
        products = ("products" <~~ json)!
        ConsumerID = 65
    }
    
    public init()
    {
        ConsumerID = 65
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "ConsumerID" ~~>  65,
            "products" ~~> self.products
            ])
    }
    
    
    
    
    
}

//End- Menu



// Preference

public struct Preference: Decodable, Encodable {
    public var products: [productDetails] = []
    public var source = "Preference"
    
    
    
    public init?(json: JSON) {
        products = ("products_preferences" <~~ json)!
        
        
    }
    
    public init()
    {
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            
            "products" ~~> self.products
            
            
            ])
    }
    
    
    
    
    
}

//End- Preference





//Cart

public struct Cart: Decodable, Encodable {
    
    public var ConsumerID:Int
    public var MerchantID:Int
    public var payment:Payment = Payment()
    public var products: [productDetails] = []
    
    public init?(json: JSON) {
        self.products = ("products" <~~ json)!
        self.ConsumerID = 10
        self.MerchantID = 1
        
        
    }
    
    public init()
    {
        self.ConsumerID = 10
        self.MerchantID = 1
        
        
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "Consumer_ID" ~~>  self.ConsumerID,
            "Merchant_ID" ~~> self.MerchantID,
            "products" ~~> self.products,
            "payment" ~~> self.payment
            ])
    }
    
    
    
}


//End- Cart


//Payment

public struct Payment  {
    
    
    public var paymentID:String
    
    
    
    
    public init()
    {
        
        self.paymentID = ""
        
    }
    
    
    
    
    
}

//End - Payment

//Product Details

public struct productDetails: Decodable, Encodable {
    
    public let productId:Int
    public let merchantId:Int
    public var numberOfProduct:Int
    public let productName:String
    public var productImage:String
    public var productPrice:Double
    public var SourceType:String
    public var SourceIndex:Int
    public let CustomizationAvailable:Bool
    public var alreadyInPreference : Bool
    public var setCustomization:[selectedCustomization]
    public var isCustomized:Bool
    //public var source:String
    public var customizationDetails: Customizationdetails
    public init?(json: JSON) {
        self.productId = ("productID" <~~ json)!
        self.merchantId = ("merchant_id" <~~ json)!
        self.productName = ("product_name" <~~ json)!
        self.productImage = ("product_image" <~~ json)!
        self.numberOfProduct = 1
        self.productPrice = ("product_price" <~~ json)!
        self.SourceType = "Menu"
        self.SourceIndex = 0
        self.CustomizationAvailable = ("customization_availability" <~~ json)!
        self.isCustomized = false
        self.alreadyInPreference = ("preference" <~~ json)!
        self.setCustomization = []
        self.customizationDetails = ("product_customization_details" <~~ json)!
    }
    // init()
    // {
    //
    //    source = "hi"
    //    self.productId = 0
    //    self.merchantId = 0
    //    self.productName = ""
    //    self.productImage = ""
    //    self.numberOfProduct = 1
    //    self.productPrice = 0
    //    self.SourceType = ""
    //    self.SourceIndex = 0
    //    self.CustomizationAvailable = false
    //    self.isCustomized = false
    //    self.alreadyInPreference = ""
    //    self.setCustomization = []
    //
    //    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "product_id" ~~>  self.productId,
            "item_name" ~~> self.productName,
            "source_type" ~~> self.SourceType,
            "product_image" ~~> self.productImage,
            "item_quantity" ~~> self.numberOfProduct,
            "item_price" ~~> self.productPrice,
            "customization_present" ~~> self.CustomizationAvailable,
            "customization" ~~> self.setCustomization])
    }
    
}


//End- Product Details




