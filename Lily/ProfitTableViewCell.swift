//
//  ProfitTableViewCell.swift
//  Lily
//
//  Created by 赵润声 on 2017/12/1.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit

class ProfitTableViewCell: UITableViewCell {

    @IBOutlet var batchLabel: UILabel!
    @IBOutlet var profitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
