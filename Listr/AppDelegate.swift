//
//  AppDelegate.swift
//  Listr
//
//  Created by Hesham Saleh on 1/29/17.
//  Copyright © 2017 Hesham Saleh. All rights reserved.
//

import UIKit
import CoreData
import CobrowseIO
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CobrowseIODelegate {

    var window: UIWindow?
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.registerForRemoteNotifications()
        
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
          (granted, error) in
            if !granted {
                print("Something went wrong", error!)
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set your license key below to associate sessions with your
        // account.
        // By default all sessions will be available on the trial account
        // which is accessed at https://cobrowse.io/trial
        print("Cobrowse device id:  \(String(describing: CobrowseIO.instance().deviceId))")
        
        CobrowseIO.instance().delegate = self

        let license = UserDefaults.standard.string(forKey: "license");
        if (license != nil) {
            print("Overriding license to: \(license!)")
            CobrowseIO.instance().license = license!;
        } else {
            CobrowseIO.instance().license = "trial";
        }

        let api = UserDefaults.standard.string(forKey: "api");
        if (api != nil) {
            print("Overriding api to: \(api!)")
            CobrowseIO.instance().api = api!;
        }
        
//        CobrowseIO.instance().customData = [
//            kCBIOUserNameKey: "Sam Turner" as NSObject,
//            kCBIOUserEmailKey: "sam.turner@example.com" as NSObject
//        ]

//        for online demo only
//        UserDefaults.standard.set("abcdef", forKey: "device_id")
//        UserDefaults.standard.synchronize()
        var customData = [String: NSObject]();
        customData["cobrowseio_device_id"] = CobrowseIO.instance().deviceId as NSObject

        let user_name = UserDefaults.standard.string(forKey: "user_name");
        if (user_name != nil) {
            print("user_name is: \(user_name!)")
            customData["user_name"] = user_name! as NSObject
        }
        let user_email = UserDefaults.standard.string(forKey: "user_email");
        if (user_email != nil) {
            print("user_email is: \(user_email!)")
            customData["user_email"] = user_email! as NSObject
        }
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        if (user_id != nil) {
            print("user_id is: \(user_id!)")
            customData["user_id"] = user_id! as NSObject
        }
        let device_name = UserDefaults.standard.string(forKey: "device_name");
        if (device_name != nil) {
            print("device_name is: \(device_name!)")
            customData["device_name"] = device_name! as NSObject
        }
        let cobrowseio_device_id = UserDefaults.standard.string(forKey: "cobrowseio_device_id");
        if (cobrowseio_device_id != nil) {
            print("cobrowseio_device_id is: \(cobrowseio_device_id!)")
            customData["cobrowseio_device_id"] = cobrowseio_device_id! as NSObject
        }
        let cobrowseio_demo_id = UserDefaults.standard.string(forKey: "cobrowseio_demo_id");
        if (cobrowseio_demo_id != nil) {
            print("cobrowseio_demo_id is: \(cobrowseio_demo_id!)")
            customData["cobrowseio_demo_id"] = cobrowseio_demo_id! as NSObject
        }

        // legacy demo support
        let device_id = UserDefaults.standard.string(forKey: "device_id");
        if (device_id != nil) {
            print("Trial device_id is: \(device_id!)")
            customData[kCBIODeviceIdKey] = device_id! as NSObject
        }

        CobrowseIO.instance().customData = customData
        CobrowseIO.instance().start();

        // To override default status tap behavior set the status
        // tap property on the cobrowse instance.
        // CobrowseIO.instance().onStatusTap = { () -> Void in
        //     print("put status bar tap logic here.")
        // }
        
        return true
    }
    
    func defaultSessionIndicator(container: UIView) -> UIView {
        let indicator : UILabel = UILabel()
        indicator.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.7)
        indicator.text = "End Session"
        indicator.isUserInteractionEnabled = true
        indicator.textAlignment = .center
        indicator.font.withSize(UIFont.smallSystemFontSize)
        indicator.textColor = .white
        indicator.layer.cornerRadius = 10
        indicator.clipsToBounds = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(indicator)
        
        indicator.widthAnchor.constraint(equalToConstant: 200).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        indicator.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20).isActive = true
        
        let tapRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(indicatorTapped(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        indicator.addGestureRecognizer(tapRecognizer)
        return indicator
    }
    
    var indicatorInstance : UIView? = nil
    
    @objc
    func indicatorTapped(_ sender: UITapGestureRecognizer) {
        CobrowseIO.instance().currentSession()?.end(nil)
    }
    
//    func cobrowseShowSessionControls(_ session: CBIOSession) {
//        if (indicatorInstance == nil) {
//            indicatorInstance = self.defaultSessionIndicator(container: UIApplication.shared.keyWindow!)
//        }
//        indicatorInstance?.isHidden = false
//    }
//    
//    func cobrowseHideSessionControls(_ session: CBIOSession) {
//        indicatorInstance?.isHidden = true
//    }
    
    func cobrowseSessionDidUpdate(_ session: CBIOSession) { }
    
    func cobrowseSessionDidEnd(_ session: CBIOSession) { }

    func applicationWillTerminate(_ application: UIApplication) {
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("push notification received", userInfo);
        self.triggerNotification()
    }
       
    func triggerNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Suport Request"
        content.body = "A support agent would like to view your screen"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1,repeats: false)
        
        let identifier = "CobrowseIOSessionRequest"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
          if let error = error {
            print("Error sheduling notification", error);
          }
        })
    }
    

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Listr")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

//Shortcuts
let ad = UIApplication.shared.delegate as! AppDelegate
let context = ad.persistentContainer.viewContext
