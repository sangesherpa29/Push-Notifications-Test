//
//  AppDelegate.swift
//  ApiCaller
//
//  Created by Sange Sherpa on 23/12/2024.
//

import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureFirebase()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // request notification from user
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { granted, error in
            guard granted else {
                return
            }
            
            print("Access Granted")
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    fileprivate func configureFirebase() {
        let options = FirebaseOptions(googleAppID: "", gcmSenderID: "")
        options.bundleID = ""
        options.apiKey = ""
        options.projectID = ""
        options.clientID = ""
        FirebaseApp.configure(options: options)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // navigate to some vc on notification click
        let window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = ViewController()
        let navController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, error in
            guard token != nil else { return }
            print("Successfully registered APNS token")
        } 
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print(error)
    }
    
}
