//
//  ActivityTableViewCell.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descLabel: UILabel!
	var activity: Activity? {
		didSet {
			self.titleLabel?.text = activity?.title
			self.descLabel?.text = activity?.subtitle
		}
	}
	
}
