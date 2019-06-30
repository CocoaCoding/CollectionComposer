//
//  AppDelegate.swift
//  TwitterDispatcher
//
//  Created by Holger Hinzberg on 29.04.18.
//  Copyright © 2018 Holger Hinzberg. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        Config.save()
    }
}

