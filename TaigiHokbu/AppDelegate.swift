//
//  AppDelegate.swift
//  TaigiHokbu
//
//  Created by Yung-Luen Lan on 2021/1/25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var viewController: ViewController!
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.servicesProvider = viewController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

