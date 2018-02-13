//
//  AppDelegate.swift
//  Trendever
//
//  Created by Руслан on 14/06/16.
//  Copyright © 2016 Trendever. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults = NSUserDefaults.standardUserDefaults()
    var need_reload = false
    var reload_url = ""


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            PushManager.sharedInstance.setRemoteNotificationDic(remoteNotification)
        }
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if  url.host == nil{
            return true;
        }
        let urlString = url.absoluteString
        let queryArray = urlString!.componentsSeparatedByString("/")
        
        if (queryArray[2] == "shop"){
            let shopName = queryArray[3]
            var url = "https://www.trendever.com/"
            url += shopName
            url += "/"
            self.reload_url = url
        }
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        let viewController:ViewController = window!.rootViewController as! ViewController
        viewController.authIsDoneTimer?.invalidate()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        viewController.startTimer()
        application.applicationIconBadgeNumber = 0
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
        PushManager.sharedInstance.pushToken = tokenString
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let fromSpringboard = application.applicationState == .Inactive || application.applicationState == .Background;
        if (fromSpringboard) {
            PushManager.sharedInstance.setRemoteNotificationDic(userInfo)
        }
    }

}

