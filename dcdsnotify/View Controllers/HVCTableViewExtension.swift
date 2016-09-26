//
//  HVCTableViewExtension.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/26/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
import UIKit
extension HomeworkViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return activitiesDay?.activities?.count ?? 1
	}
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return activitiesDay?.activities?[section].classString
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("ActivityCell") as! ActivityTableViewCell
		if activitiesDay != nil && activitiesDay!.activities != nil
		{
			cell.activityIndicator.hidesWhenStopped = true
			cell.activityIndicator.stopAnimating()
			cell.activity = activitiesDay?.activities?[indexPath.section]
			
		}
		else {
			cell.activity = Activity(classString: "", title: "", subtitle: "Loading")
			cell.activityIndicator.startAnimating()
		}
		return cell
	}
	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}
