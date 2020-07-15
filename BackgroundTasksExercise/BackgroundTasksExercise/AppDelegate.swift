//
//  AppDelegate.swift
//  BackgroundTasksExercise
//
//  Created by 윤성우 on 2020/07/15.
//  Copyright © 2020 윤성우. All rights reserved.
//

import UIKit
import BackgroundTasks

let globalOperationQueue = OperationQueue()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier:
        "CSEDTD.BackgroundTasksExercise.myTask",
        using: nil)
          {task in
             self.handleAppRefresh(task: task as! BGAppRefreshTask)
          }
        
        registerForRichNotifications()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        scheduleAppRefresh()
    }
    
    func scheduleAppRefresh() {
       let request = BGAppRefreshTaskRequest(identifier: "CSEDTD.BackgroundTasksExercise.myTask")
       // Fetch no earlier than 2 seconds from now
       request.earliestBeginDate = Date(timeIntervalSinceNow: 2)
            
       do {
          try BGTaskScheduler.shared.submit(request)
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        
        // Schedule a new refresh task
        scheduleAppRefresh()
        
        //let queue = OperationQueue()
        //queue.maxConcurrentOperationCount = 1
        globalOperationQueue.maxConcurrentOperationCount = 1


        // Create an operation that performs the main part of the background task
        let operation = MyOperation()

        // Provide an expiration handler for the background task
        // that cancels the operation
        task.expirationHandler = {
         operation.cancel()
        }

        // Inform the system that the background task is complete
        // when the operation completes
        operation.completionBlock = {
         task.setTaskCompleted(success: !operation.isCancelled)
        }

        // Start the operation
        //queue.addOperation(operation)
        globalOperationQueue.addOperation(operation)
        //queue.addOperations([operation], waitUntilFinished: false)
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

