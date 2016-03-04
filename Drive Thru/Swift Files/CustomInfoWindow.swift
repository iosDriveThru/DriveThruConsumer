//
//  CustomInfoWindow.swift
//  GoogleMapSwift
//
//  Created by Ziyang Tan on 4/6/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class CustomInfoWindow: UIView {

   @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnMenuButton: UIButton!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func btnMenu_click(sender: AnyObject) {
    }

}
