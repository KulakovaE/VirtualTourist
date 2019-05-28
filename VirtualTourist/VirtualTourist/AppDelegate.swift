//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Elena Kulakova on 2019-05-20.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let dataController = DataController.shared
        dataController.load()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? DataController.shared.viewContext.save()
    }

}

