//
//  menuCollectionViewCell.swift
//  Drive Thru
//
//  Created by Nanite on 20/01/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit

class menuCollectionViewCell: UICollectionViewCell {
    
   
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    
//    @IBAction func btnPreference_Click(sender: AnyObject) {
//        let CollectionView: UICollectionView = UICollectionView()
//        let indexPath:NSIndexPath = NSIndexPath()
//        print("Preference button clicked")
//        let cell : UICollectionViewCell = CollectionView.dequeueReusableCellWithReuseIdentifier("menuCell", forIndexPath: indexPath)
//           // cellForItemAtIndexPath(indexPath)!
//        print("Collectionview at row \(CollectionView.tag) selected row \(indexPath.row)")
//    }
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var btnAddToPreference: UIButton!
    @IBOutlet weak var btnRightMenuCell: UIButton!
    @IBOutlet weak var btnLeftMenuCell: UIButton!
    @IBOutlet weak var btnCustomization: UIButton!
    @IBOutlet weak var lblCustomize: UILabel!
    
    
}
