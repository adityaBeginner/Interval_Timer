//
//  AppDelegate.swift
//  TIMER
//
//  Created by Aditya Maroo on 04/10/24.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    @Published var csvHandler = CSVHandler()

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle the incoming CSV file
        if url.pathExtension == "csv" {
            csvHandler.readCSV(from: url)
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
                    }
                }
                
                UIViewController.attemptRotationToDeviceOrientation()
            }
                else{
                    if orientationLock == .landscape {
                        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                    } else {
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    }
                }
            }
}

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

//MARK: -
//MARK: CSV HANDLER
class CSVHandler: ObservableObject {
    @Published var csvContent: String = ""
    
    func readCSV(from url: URL) {
        do {
            let content = try String(contentsOf: url)
            DispatchQueue.main.async {
                self.csvContent = content
            }
        } catch {
            print("Error reading CSV file: \(error)")
        }
    }
    
  
}
