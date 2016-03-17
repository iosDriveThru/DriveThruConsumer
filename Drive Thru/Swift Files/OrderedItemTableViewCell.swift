//
//  OrderedItemTableViewCell.swift
//  Drive Thru
//
//  Created by Nanite Solutions on 3/15/16.
//  Copyright © 2016 Nanite Solutions. All rights reserved.
//

import UIKit

class OrderedItemTableViewCell: UITableViewCell {

    @IBOutlet var lblQuantity: UILabel!
    @IBOutlet var lblItem: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
