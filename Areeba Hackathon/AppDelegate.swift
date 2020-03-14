//
//  AppDelegate.swift
//  Areeba Hackathon
//
//  Created by Mohamad El Bohsaly on 3/14/20.
//

import UIKit
import Parse //Connect to Back4Apps server

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "bBXGTjo2UvVchEiidgDiROxces5051RkJVTMeHGN"
            $0.clientKey = "nVKQUP7FMP1obv7kbW07jhuT0p24dcg3PUiVSoqE"
            $0.server = "https://parseapi.back4app.com"
        }
        
        Parse.initialize(with: configuration)
        
        saveInstallationObject() //create a new parse installation object upon your app loading
        
        return true
    }
    
    func saveInstallationObject(){ //asynchronuously connect with the installation persisted to the Parse cloud
        if let installation = PFInstallation.current(){
            installation.saveInBackground {
                (success: Bool, error: Error?) in
                if (success) {
                    print("You have successfully connected your app to Back4App!")
                } else {
                    if let myError = error{
                        print(myError.localizedDescription)
                    }else{
                        print("Uknown error")
                    }
                }
            }
        }
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

