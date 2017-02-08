//
//  SettingsCell.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 9/8/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    var action: ClosureVoid!
	var title: String!
	@IBOutlet weak var settingButton: UIButton!
	
	
    @IBAction func onButtonTap(_ sender: AnyObject) {
        action()
    }

}
