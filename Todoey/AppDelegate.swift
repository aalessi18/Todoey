//
//  AppDelegate.swift
//  Todoey
//
//  Created by Alex on 2018-08-13.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Gets called when the app is loaded up (before viewDidLoad)
        
        // Location of plist file
        // print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    // Value only created at the time point when it is needed. We occupy the memory only when needed
    // This is where we're going to store all of our data. The default is a SQLite Database
    lazy var persistentContainer: NSPersistentContainer = {
        
        // This is where we create our Database and where we're going to be saving our data. We use the layout we
        // established under Models
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    // Helps to save our data when the application gets terminated
    func saveContext () {
        // Allows to change data until we're satisfied
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                // Then we save to our container -> Makes it permanent
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


}

