//
//  AppDelegate.swift
//  TaigiHokbu
//
//  Created by Yung-Luen Lan on 2021/1/25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.servicesProvider = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func liamTaigi(_ pboard: NSPasteboard, userData: String, error: NSErrorPointer) {
        // get the string
        if let taigi = pboard.string(forType: .string) {
            TaigiHokbu.parseTaigi(taigi) { (result) in
                switch result {
                case .success(let syntax):
                    print("success: ", syntax)
                    TaigiHokbu.liamTaigi(syntax.KIP)
                case .failure(let error):
                    print("failure:", error)
                    break
                }
            }
        }
    }
}

