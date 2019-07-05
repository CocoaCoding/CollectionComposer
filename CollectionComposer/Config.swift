//
//  Config.swift
//  TwitterDispatcher
//
//  Created by Holger Hinzberg on 26.06.18.
//  Copyright © 2018 Holger Hinzberg. All rights reserved.
//

import Cocoa

class Config
{
    static var sourcePath:String = ""
    static var destinationPath:String = ""
    static var numberOfFilesToCopy:Int32 = 0
    static var keywords = ""
    static var deleteOriginalFiles:Bool = false;
    
    static private let sourcePathKey = "sourcePathKey"
    static private let destinationPathKey = "destinationPathKey"
    static private let numberOfFilesPathKey = "numberOfFilesPathKey"
    static private let keywordsPathKey = "keywordsPathKey"
    static private let deleteFilesPathKey = "deleteFilesPathKey"
    
    static func load()
    {
        let defaults = UserDefaults.standard
        var data:AnyObject? = defaults.object(forKey: sourcePathKey) as AnyObject
        if data != nil && data is String
        {
            let path = data as! String
            self.sourcePath = path
        }
        
        data = defaults.object(forKey: destinationPathKey) as AnyObject
        if data != nil && data is String
        {
            let path = data as! String
            self.destinationPath = path
        }
        
        data = defaults.object(forKey: numberOfFilesPathKey) as AnyObject
        if data != nil && data is Int32
        {
            let path = data as! Int32
            self.numberOfFilesToCopy = path
        }
        
        data = defaults.object(forKey: keywordsPathKey) as AnyObject
        if data != nil && data is String
        {
            let path = data as! String
            self.keywords = path
        }
        
        data = defaults.object(forKey: deleteFilesPathKey) as AnyObject
        if data != nil && data is Bool
        {
            let del = data as! Bool
            self.deleteOriginalFiles = del
        }
    }
    
    static  func save()
    {
        let defaults = UserDefaults.standard
        defaults.set(self.sourcePath, forKey: self.sourcePathKey)
        defaults.set(self.destinationPath, forKey: self.destinationPathKey)
        defaults.set(self.numberOfFilesToCopy, forKey: self.numberOfFilesPathKey)
        defaults.set(self.keywords, forKey: self.keywordsPathKey)
        defaults.set(self.deleteOriginalFiles, forKey: self.deleteFilesPathKey)
    }    
}
