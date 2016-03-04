//
//  customTableViewCell.swift
//  Customization
//
//  Created by Nanite Solutions on 1/20/16.
//  Copyright © 2016 Nanite. All rights reserved.
//

import UIKit

class customTableViewCell: UITableViewCell{

    @IBOutlet var cv: UICollectionView!
    @IBOutlet var lblCategory: UILabel!
}
extension customTableViewCell {
    
    func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
        
        cv.delegate = dataSourceDelegate
        cv.dataSource = dataSourceDelegate
        cv.tag = row
        cv.setContentOffset(cv.contentOffset, animated:false)
        // Stops collection view if it was scrolling.
        cv.clearsContextBeforeDrawing = true
        cv.reloadData()
        self.cv.pagingEnabled = true
    }
    
    var collectionViewOffset: CGFloat {
        set {
            cv.contentOffset.x = newValue
        }
        
        get {
            return cv.contentOffset.x
        }
    }
}
