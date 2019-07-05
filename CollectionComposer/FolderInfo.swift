//
//  FoldersInfo.swift
//  FoldersTableDemo
//
//  Created by Holger Hinzberg on 19.06.19.
//  Copyright © 2019 Holger Hinzberg. All rights reserved.
//

import Cocoa

public class FolderInfo: NSObject, NSCoding
{
    var Folder = "";
    var FileCount = 0;
    var FilesInFolder:[URL]? = nil
    
    public override init()
    {
    }

    public func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.Folder, forKey: "Folder")
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        self.Folder = aDecoder.decodeObject(forKey:"Folder") as! String
    }
}
