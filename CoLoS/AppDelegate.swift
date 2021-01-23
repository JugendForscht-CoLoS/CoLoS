//
//  AppDelegate.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import UIKit
import os

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let downloadQueue = DispatchQueue(label: "com.timjaeger.CoLoS.downloadQueue", qos: .utility)
        
        downloadQueue.async {
            
            self.checkAndRefreshOfflineMap()
        }
        
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

    func checkAndRefreshOfflineMap() {
        
        let fileManager = FileManager.default
        
        if let cacheUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            
            do {
                
                var url = cacheUrl
                
                url.appendPathComponent("map")
                
                if !fileManager.fileExists(atPath: url.path) {
                    
                    try fileManager.createDirectory(at: url, withIntermediateDirectories: false, attributes: [:])
                }
                
                for z in 0 ... 5 {
                    
                    var zUrl = url
                    zUrl.appendPathComponent("\(z)")
                    
                    if !fileManager.fileExists(atPath: zUrl.path) {
                        
                        try fileManager.createDirectory(at: zUrl, withIntermediateDirectories: false, attributes: [:])
                    }
                    
                    for x in 0 ..< pow(a: 2, b: z) {
                        
                        var xUrl = zUrl
                        xUrl.appendPathComponent("\(x)")
                        
                        if !fileManager.fileExists(atPath: xUrl.path) {
                            
                            try fileManager.createDirectory(at: xUrl, withIntermediateDirectories: false, attributes: [:])
                        }
                        
                        for y in 0 ..< pow(a: 2, b: z) {
                            
                            var yUrl = xUrl
                            yUrl.appendPathComponent("\(y).png")
                            
                            if !fileManager.fileExists(atPath: yUrl.path) {
                                
                                let content = try Data(contentsOf: URL(string: "https://tile.openstreetmap.org/\(z)/\(x)/\(y).png")!)
                                fileManager.createFile(atPath: yUrl.path, contents: content, attributes: [:])
                            }
                        }
                    }
                }
            }
            catch {
                
                logger.error("Map-Download: Error occured \(error.localizedDescription)")
            }
        }
        else {
            
            logger.fault("Map-Download: Could not find cache url.")
        }
    }

}

let logger = Logger(subsystem: "com.timjaeger.CoLoS", category: "main")

func pow(a: Int, b: Int) -> Int {
    
    var result = 1
    
    for _ in 0 ..< b {
        
        result *= a
    }
    
    return result
}

