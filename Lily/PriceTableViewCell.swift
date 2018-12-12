//
//  PriceTableViewCell.swift
//  Lily
//
//  Created by 赵润声 on 17/11/30.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import SDWebImage

class PriceTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var costPriceLabel: UILabel!
    @IBOutlet var sellPriceLabel: UILabel!
    @IBOutlet var storeLabel: UILabel!
    @IBOutlet var swImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
