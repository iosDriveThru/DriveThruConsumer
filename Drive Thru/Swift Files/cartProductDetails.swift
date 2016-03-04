//
//  cartProductDetails.swift
//  Drive Thru
//
//  Created by Nanite on 25/01/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit
import Gloss

public struct cartProductDetails: Decodable {
    
    public let productId:Int
    public let merchantId:Int
    public var numberOfProduct:Int
    public let productName:String
    public let productImage:String
    public var productPrice:Double
    public let menuType:Int
    public let CustomizationAvailable:Bool
   // public let customizationDetails:[cartProductDetails]?
    
    //    init(fromMerchantId merchantId:Int, fromProductId id:Int, fromProductName name:String, fromProductImage image:String, fromNumberOfProducts noOfProducts: Int, fromProductPrice price:Double, frommenuType type:Int) {
    //        productId = id
    //        productName = name
    //        productImage = image
    //        numberOfProduct = noOfProducts
    //        productPrice = price
    //        menuType = type
    //
    //
    //    }
    
    public init?(json: JSON) {
        self.productId = ("productID" <~~ json)!
        self.merchantId = ("merchant_id" <~~ json)!
        self.productName = ("product_name" <~~ json)!
        self.productImage = ("product_image" <~~ json)!
        self.numberOfProduct = 1
        self.productPrice = ("product_price" <~~ json)!
        self.menuType = 2
        self.CustomizationAvailable = ("customization_availability" <~~ json)!
       // self.customizationDetails = ("product_customization_details" <~~ json)!
        
        
    }

}
