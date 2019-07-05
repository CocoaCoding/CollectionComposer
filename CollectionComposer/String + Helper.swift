//
//  HHZStringHelper.swift
//
//  Created by Holger Hinzberg on 14.06.14.
//  Copyright (c) 2014 Holger Hinzberg. All rights reserved.
//

import Foundation

extension String
{
    func caseInsensitiveContains(substring:String) -> Bool
    {
        if (self.lowercased().contains(substring.lowercased()))
        {
            return true
        }
        return false
    }
    
    func getIndexOf(substring:String)->Int
    {
        let theRange:Range = self.lowercased().range(of:substring.lowercased())!
        let index: Int = self.distance(from: self.startIndex, to: theRange.lowerBound)
        return index
    }

    func substringLeftOf(searchString:String) ->String
    {
        let theRange = self.range(of: searchString)
        if let theRange = theRange
        {
            let endIndex = theRange.lowerBound
            let str = String(self[self.startIndex..<endIndex])
            return str
        }
        return self
    }
    
    func substringRightOf(searchString:String) ->String
    {
        let theRange = self.range(of: searchString)
        if let theRange = theRange
        {
            let str = String(self[theRange.upperBound..<self.endIndex])
            return str
        }
        return self
    }
    
    func substringRightFrom(characterCount:Int) -> String
    {
        if characterCount > 0 && characterCount < self.count
        {
            let sub = String(self[self.index(self.startIndex, offsetBy: characterCount)...])
            return sub
        }
        return self
    }
    
    func left(_ characterCount : Int) -> String
    {
        if characterCount > 0 && characterCount < self.count
        {
            let sub = String(self[..<self.index(self.startIndex, offsetBy: characterCount)])
            return sub
        }
        return self
    }
    
    func substringLeftFrom(characterCount:Int) -> String
    {
        if characterCount > 0 && characterCount < self.count
        {
            let sub = String(self[..<self.index(self.startIndex, offsetBy: self.count - characterCount)])
            return sub
        }
        return self
    }
    
    func caseInsensitiveEndsWith(anotherString:String)->Bool
    {
        // Position wo die Zeichenkette ist.
        let indexOfAnotherString = getIndexOf(substring: anotherString)
        // Position wo die Zeichenkette sein sollten wenn sie am Ende wäre
        let endIndex:Int = self.count - anotherString.count
        
        if indexOfAnotherString == endIndex
        {
            return true
        }
        return false
    }
    
    func caseInsensitiveBeginsWith(anotherString:String)->Bool
    {
        let indexOfAnotherString = getIndexOf(substring: anotherString)
        if indexOfAnotherString == 0
        {
            return true
        }
        return false
    }
    
    func appendingPathComponent(_ string: String) -> String
    {
        return URL(fileURLWithPath: self).appendingPathComponent(string).path
    }
}
