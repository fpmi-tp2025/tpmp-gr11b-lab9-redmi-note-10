//
//  AppDelegate.swift
//  LimoBank
//
//  Created by Zharnasek Daniil on 26.05.25.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Настройка внешнего вида
        setupAppearance()
        return true
    }
    
    func setupAppearance() {
        // Настройка Tab Bar
        UITabBar.appearance().barTintColor = UIColor(named: "background_dark")
        UITabBar.appearance().tintColor = UIColor(named: "primary_yellow")
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "text_gray")
        
        // Настройка Navigation Bar
        UINavigationBar.appearance().barTintColor = UIColor(named: "background_dark")
        UINavigationBar.appearance().tintColor = UIColor(named: "primary_yellow")
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LimoBank")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
