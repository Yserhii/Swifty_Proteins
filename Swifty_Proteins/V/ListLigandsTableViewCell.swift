//
//  ListLigandsTableViewCell.swift
//  Swifty_Proteins
//
//  Created by Yolankyi SERHII on 9/2/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit

class ListLigandsTableViewCell: UITableViewCell {

    @IBOutlet weak var numberRow: UILabel!
    @IBOutlet weak var nemeLigand: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
