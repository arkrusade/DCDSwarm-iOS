//
//  BlockCell.swift
//  dcdsnotify
//
//  Created by Justin Lee on 10/7/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
class BlockCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    var block: Block? {
        didSet {
            self.titleLabel?.text = block?.name
            self.descLabel?.text = block?.time
        }
    }

    
}
