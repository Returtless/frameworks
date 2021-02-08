//
//  AppDelegate.swift
//  frameworks
//
//  Created by Владислав Лихачев on 14.01.2021.
//

import UIKit
import GoogleMaps
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let center = UNUserNotificationCenter.current()
              center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                  guard granted else {
                      print("Разрешение не получено")
                      return
                  }
                  
                  self.sendNotificationRequest(
                      content: self.makeNotificationContent(),
                      trigger: self.makeIntervalNotificationTrigger()
                  )
              }

        
        GMSServices.provideAPIKey("AIzaSyCTWJz7beSmXzNPCyt2zXy_XKsMHK63BNo")

        return true
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

    func makeNotificationContent() -> UNNotificationContent {
           let content = UNMutableNotificationContent()
           content.title = "Пожалуйста"
           content.subtitle = "Запустите меня"
           content.body = "Прошло 30 минут"
           content.badge = 4
           return content
       }
       
       func makeIntervalNotificationTrigger() -> UNNotificationTrigger {
           return UNTimeIntervalNotificationTrigger(
               timeInterval: 1800,
               repeats: false
           )
       }
       
       func sendNotificationRequest(
           content: UNNotificationContent,
           trigger: UNNotificationTrigger) {
           
           let request = UNNotificationRequest(
               identifier: "notification",
               content: content,
               trigger: trigger
           )
           
           let center = UNUserNotificationCenter.current()
           center.add(request) { error in
               if let error = error {
                   print(error.localizedDescription)
               }
           }
       }
    
}

extension UIViewController {
    func showAlert(title : String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}
