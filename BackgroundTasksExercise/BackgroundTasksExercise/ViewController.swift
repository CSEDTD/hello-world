//
//  ViewController.swift
//  BackgroundTasksExercise
//
//  Created by 윤성우 on 2020/07/15.
//  Copyright © 2020 윤성우. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UNUserNotificationCenter.current().delegate = self
        globalNotificationManager = UNUserNotificationCenter.current()
    }

    @IBAction func start(_ sender: Any) {
        //let queue = OperationQueue()
        //queue.maxConcurrentOperationCount = 1
        globalOperationQueue.maxConcurrentOperationCount = 1
        
        let operation = MyOperation()

        //queue.addOperation(operation)
        globalOperationQueue.addOperation(operation)
    }
}

// for foreground notification
extension ViewController: UNUserNotificationCenterDelegate {

    //for displaying notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        //If you don't want to show notification when app is open, do something here else and make a return here.
        //Even you you don't implement this delegate method, you will not see the notification on the specified controller. So, you have to implement this delegate and make sure the below line execute. i.e. completionHandler.

        completionHandler([.alert, .badge, .sound])
    }

    // For handling tap and user actions
    // TODO
    /*
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        switch response.actionIdentifier {
        case "stopRouting":
            workingAlarm.finished()
        default:
            break
        }
        completionHandler()
    }
 */

}

// TODO MUST 0623
func scheduleNotifications() {

    let content = UNMutableNotificationContent()
    let requestIdentifier = UUID().uuidString

    // TODO
    content.badge = 0
    content.sound = UNNotificationSound.default
    
    content.title = "백그라운드에서 뜨나요?"
    content.subtitle = ""
    content.body = ""
    content.categoryIdentifier = "simpleCategory"

    // If you want to attach any image to show in local notification
    /*
    let url = Bundle.main.url(forResource: "notificationImage", withExtension: ".jpg")
    do {
        let attachment = try? UNNotificationAttachment(identifier: requestIdentifier, url: url!, options: nil)
        content.attachments = [attachment!]
    }
     */

    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)

    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { (error:Error?) in

        if error != nil {
            print(error?.localizedDescription ?? "some unknown error")
        }
        print("Notification Register Success")
    }
}

// TODO
func registerForRichNotifications() {

   UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (granted:Bool, error:Error?) in
        if error != nil {
            print(error?.localizedDescription)
        }
        if granted {
            print("Permission granted")
        } else {
            print("Permission not granted")
        }
    }

    //actions defination
    let stopRouting = UNNotificationAction(identifier: "stopRouting", title: "이동 중지", options: [.foreground])

    let actionCategory = UNNotificationCategory(identifier: "actionCategory", actions: [stopRouting], intentIdentifiers: [], options: [])
    
    let simpleCategory = UNNotificationCategory(identifier: "simpleCategory", actions: [], intentIdentifiers: [], options: [])

    UNUserNotificationCenter.current().setNotificationCategories([actionCategory, simpleCategory])

}


var globalNotificationManager = UNUserNotificationCenter.current()
