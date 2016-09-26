//
//  Crop.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//
import Foundation
extension String {
	var lines:[String] {
		var result:[String] = []
		enumerateLines{ result.append($0.line) }
		return result
	}
	func indexOf(target: String) -> Int
	{
		let range = self.rangeOfString(target)
		if let range = range {
			return self.startIndex.distanceTo(range.startIndex)
		} else {
			return -1
		}
	}
	
	func indexOf(target: String, startIndex: Int) -> Int
	{
		let startRange = self.startIndex.advancedBy(startIndex)
		
		let range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: startRange ..< endIndex)
		
		if let range = range {
			return self.startIndex.distanceTo(range.startIndex)
		} else {
			return -1
		}
	}
	
}

extension NSString {
	
	func crop(start: String) throws -> String
	{
		let startRange = (self as NSString).rangeOfString(start)
		guard startRange.location < self.description.characters.count else
		{
			throw CropError.StartNotContained
		}
		
		return (self as NSString).substringFromIndex(startRange.location)
	}
	func cropExclusive(start: String) throws -> String
	{
		let startRange = (self as NSString).rangeOfString(start)
		guard startRange.location < self.description.characters.count else
		{
			throw CropError.StartNotContained
		}
		
		return (self as NSString).substringFromIndex(startRange.location + startRange.length)
	}
	
	func cropEnd(suffix: String) throws -> String
	{
		let endRange = (self as NSString).rangeOfString(suffix)
		guard endRange.location < self.description.characters.count else
		{
			throw CropError.EndNotContained
		}
		
		return (self as NSString).substringToIndex(endRange.location + endRange.length)
	}
	func cropEndExclusive(suffix: String) throws -> String
	{
		let endRange = (self as NSString).rangeOfString(suffix)
		guard endRange.location < self.description.characters.count else
		{
			throw CropError.EndNotContained
		}
		
		return (self as NSString).substringToIndex(endRange.location)
	}
	
	func crop(start: String, end: String) throws -> String
	{
		let startRange = (self as NSString).rangeOfString(start)
		guard startRange.location < self.description.characters.count else
		{
			throw CropError.StartNotContained
		}
		
		let startCut = (self as NSString).substringFromIndex(startRange.location)
		
		let endRange = (startCut as NSString).rangeOfString(end)
		guard endRange.location < startCut.characters.count else
		{
			throw CropError.EndNotContained
		}
		
		return (startCut as NSString).substringToIndex(endRange.location + endRange.length)
	}
	func cropExclusive(start: String, end: String) throws -> String
	{
		let startRange = (self as NSString).rangeOfString(start)
		guard startRange.location < self.description.characters.count else
		{
			throw CropError.StartNotContained
		}
		
		let startCut = (self as NSString).substringFromIndex(startRange.location + startRange.length)
		
		let endRange = (startCut as NSString).rangeOfString(end)
		guard endRange.location < startCut.characters.count else
		{
			throw CropError.EndNotContained
		}
		
		return (startCut as NSString).substringToIndex(endRange.location)
	}
}
