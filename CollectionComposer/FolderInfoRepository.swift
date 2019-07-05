//
//  FoldersInfoRepository.swift
//  FoldersTableDemo
//
//  Created by Holger Hinzberg on 19.06.19.
//  Copyright © 2019 Holger Hinzberg. All rights reserved.
//

import Cocoa

public class FolderInfoRepository: NSObject
{
    private let filename = "folderinfos"
    private var folderInfos = [FolderInfo]()
    
    public func Add(info : FolderInfo)
    {
        self.folderInfos.append(info)
    }
    
    public func GetCount() -> Int
    {
        return self.folderInfos.count
    }
    
    public func GetItemAt(index : Int) -> FolderInfo
    {
        return self.folderInfos[index]
    }

    public func removeItemAt(index : Int)
    {
        self.folderInfos.remove(at: index)
    }
    
    public func Load()
    {
        guard let loadedInfos = NSKeyedUnarchiver.unarchiveObject(withFile: self.filename) as? [FolderInfo] else { return}
        self.folderInfos.removeAll()
        
        for info in loadedInfos
        {
            self.folderInfos.append(info)
        }
    }
    
    public func Save()
    {
        let success = NSKeyedArchiver.archiveRootObject(self.folderInfos, toFile: self.filename)
        if success == true
        {
            print("gespeichert")
        }
        else
        {
            print("nicht gespeichert")
        }
    }
    
    
}
