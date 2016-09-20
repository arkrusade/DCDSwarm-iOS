//
//  UIImage.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 9/8/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
extension UIImage{
	
	func alpha(value:CGFloat)->UIImage?
	{
		UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
		
		let ctx = UIGraphicsGetCurrentContext()!;
		let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height);
		
		CGContextScaleCTM(ctx, 1, -1);
		CGContextTranslateCTM(ctx, 0, -area.size.height);
		CGContextSetBlendMode(ctx, .Multiply);
		CGContextSetAlpha(ctx, value);
		CGContextDrawImage(ctx, area, self.CGImage ?? CGImage!);
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return newImage;
	}
}
