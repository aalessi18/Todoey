//
//  AppDelegate.swift
//  Todoey
//
//  Created by Alex on 2018-08-13.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Gets called when the app is loaded up (before viewDidLoad)
        
        // Location of plist file
        // print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        
        // print(Realm.Configuration.defaultConfiguration.fileURL)
        
        
        do {
            _ = try Realm()
        } catch {
            print("Error initializing Realm, \(error)")
        }
        return true
    }
}

