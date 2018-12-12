//
//  BatchTableViewCell.swift
//  Lily
//
//  Created by 赵润声 on 2017/12/3.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit

class BatchTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var productLabel: UILabel!
    @IBOutlet var incomeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
