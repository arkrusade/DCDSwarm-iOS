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
        enumerateLines{ line, _ in result.append(line) }
        return result
    }
    func indexOf(_ target: String) -> Int
    {
        let range = self.range(of: target)
        if let range = range {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    func indexOf(_ target: String, startIndex: Int) -> Int
    {
        let startRange = self.characters.index(self.startIndex, offsetBy: startIndex)
        
        let range = self.range(of: target, options: NSString.CompareOptions.literal, range: startRange ..< endIndex)
        
        if let range = range {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
}

extension NSString {
    
    func crop(_ start: String) -> String?
    {
        let startRange = (self as NSString).range(of: start)
        guard startRange.location < self.description.characters.count else
        {
            return nil
        }
        
        return (self as NSString).substring(from: startRange.location)
    }
    func cropExclusive(_ start: String) -> String?
    {
        let startRange = (self as NSString).range(of: start)
        guard startRange.location < self.description.characters.count else
        {
            return nil
        }
        
        return (self as NSString).substring(from: startRange.location + startRange.length)
    }
    
    func cropEnd(_ suffix: String) -> String?
    {
        let endRange = (self as NSString).range(of: suffix)
        guard endRange.location < self.description.characters.count else
        {
            return nil
        }
        
        return (self as NSString).substring(to: endRange.location + endRange.length)
    }
    func cropEndExclusive(_ suffix: String) -> String?
    {
        let endRange = (self as NSString).range(of: suffix)
        guard endRange.location < self.description.characters.count else
        {
            return nil
        }
        
        return (self as NSString).substring(to: endRange.location)
    }
    
    func crop(_ start: String, end: String) -> String?
    {
        let startRange = (self as NSString).range(of: start)
        guard startRange.location < self.description.characters.count else
        {
            return nil
        }
        
        let startCut = (self as NSString).substring(from: startRange.location)
        
        let endRange = (startCut as NSString).range(of: end)
        guard endRange.location < startCut.characters.count else
        {
            return nil
        }
        
        return (startCut as NSString).substring(to: endRange.location + endRange.length)
    }
    func cropExclusive(_ start: String, end: String) -> String?
    {
        let startRange = (self as NSString).range(of: start)
        guard startRange.location < self.description.characters.count else
        {
            return nil
        }
        
        let startCut = (self as NSString).substring(from: startRange.location + startRange.length)
        
        let endRange = (startCut as NSString).range(of: end)
        guard endRange.location < startCut.characters.count else
        {
            return nil
        }
        
        return (startCut as NSString).substring(to: endRange.location)
    }
}
