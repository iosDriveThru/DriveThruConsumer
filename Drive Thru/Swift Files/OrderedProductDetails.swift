//
//  cartProductDetails.swift
//  Drive Thru
//
//  Created by Nanite on 25/01/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit
import Gloss


public struct OrderedDetails: Decodable {
    
    public var orderedProductDetails:[OrderedProductDetails] = []
   
    public init?(json: JSON) {
    self.orderedProductDetails = ("order_details" <~~ json)!
    }
    public init(){
        
    }
    
}

public struct OrderedProductDetails: Decodable {
   // public let OrderID:Int
    public var orderedProduct:[OrderedProduct] = []
    public init?(json: JSON) {
       // self.OrderID = ("Order_ID" <~~ json)!
        self.orderedProduct = ("Products" <~~ json)!
           }
   
}

public struct OrderedProduct: Decodable {
   public var productName:String
    public let productQuantity:String
    public var orderedProdutCustomization:[OrderedProductCustomization] = []
    public init?(json: JSON) {
        
        self.productName = ("Product_Name" <~~ json)!
        self.productQuantity = ("Quantity" <~~ json)!
        self.orderedProdutCustomization = ("Customization" <~~ json)!
    }
    
}

public struct OrderedProductCustomization: Decodable {
    public var productCategory:String
    public let productCategory_value:String
    
    public init?(json: JSON) {
        self.productCategory = ("category" <~~ json)!
        self.productCategory_value = ("category_value" <~~ json)!
    }
    
}


