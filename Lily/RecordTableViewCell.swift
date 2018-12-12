//
//  RecordTableViewCell.swift
//  Lily
//
//  Created by 赵润声 on 17/12/1.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {

    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var batchLabel: UILabel!
    @IBOutlet var costPriceLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var paidLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
