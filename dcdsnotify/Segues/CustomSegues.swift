//
//  CustomSegues.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 9/2/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
import UIKit
class SwipeSegue: UIStoryboardSegue {
	func animateSwipeDown() {
		let toViewController = destinationViewController
		let fromViewController = sourceViewController
		
		let containerView = fromViewController.view.superview
		let screenBounds = UIScreen.mainScreen().bounds
		
		let finalToFrame = screenBounds
		let finalFromFrame = CGRectOffset(finalToFrame, 0, screenBounds.size.height)
		
		toViewController.view.frame = CGRectOffset(finalToFrame, 0, -screenBounds.size.height)
		containerView?.addSubview(toViewController.view)
		
		UIView.animateWithDuration(0.5, animations: {
			toViewController.view.frame = finalToFrame
			fromViewController.view.frame = finalFromFrame
			}, completion: { finished in
				let fromVC = self.sourceViewController
				let toVC = self.destinationViewController
				fromVC.presentViewController(toVC, animated: false, completion: nil)
		})
	}
}