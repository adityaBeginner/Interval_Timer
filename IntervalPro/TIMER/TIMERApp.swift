//
//  TIMERApp.swift
//  TIMER
//
//  Created by Aditya Maroo on 13/08/24.
//

import SwiftUI

@main
struct TIMERApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appEnvironment = AppEnvironment()
    
    let persistenceController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
//            SectionedListView()
            SplashView()
                .environmentObject(appEnvironment)
                .preferredColorScheme(appEnvironment.isDarkMode ? .dark : .light)
                .environment(\.managedObjectContext, persistenceController.context)
                .onAppear {
                    if !UserDefaults.standard.contains(key: "disableAutoScreenOff"){
                        AppDefaults.shared.disableAutoScreenOff = true
                    }
                    if !UserDefaults.standard.contains(key: "globalVolumeSoundIntervalApp"){
                        AppDefaults.shared.globalVolumeSoundIntervalApp = 1.0
                    }
                    if !UserDefaults.standard.contains(key: "appLaunchFirstTime"){
                        AppDefaults.shared.appLaunchFirstTime =  false
                        guard let firstUrl = Bundle.main.url(forResource: "home_circuit" , withExtension: "csv") else {
                            print("Csv file \(String(describing: "Crossfader - Broken (ellipsis)")) not found in the app bundle.")
                            return
                        }
                        guard let secondUrl = Bundle.main.url(forResource: "strike_force" , withExtension: "csv") else {
                            print("Csv file \(String(describing: "Crossfader - OK")) not found in the app bundle.")
                            return
                        }
                        ImportCSV.shared.importItemsFromCSV(url: firstUrl)
                        ImportCSV.shared.importItemsFromCSV(url: secondUrl)
//                        ImportCSV.shared.paidAllCsvFolderFile()
                    }
           
//                    if !AppDefaults.shared.disableAutoScreenOff{
//                        UIApplication.shared.isIdleTimerDisabled = false
    //                    }else{
//                        UIApplication.shared.isIdleTimerDisabled = true
//                    }
                    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    print(urls[urls.count-1] as URL)
                    
                    CoreDataManager.shared.removeEmptyItems()
                    CoreDataManager.shared.removeIntervalItemsWithoutTitle()
                    CoreDataManager.shared.removeAllCopyItems()
               
                    // Call SubscriptionManager to check and save subscription expiry
                    if !UserDefaults.standard.contains(key: "isUserSubscribed"){
                        
                        AppDefaults.shared.isUserSubscribed = false
                       // SubscriptionManager.shared.fetchSubscriptionStatus()
                    }
                }
//                .onOpenURL { url in
//                    debugPrint("found open url\(url)")
//                    if !AppDefaults.shared.isUserSubscribed{
//                        _ = ImportCSV.shared.importItemsFromCSV(url: url)
//                    }else{
//                        //update something on my WorkingView
//                        appEnvironment.isActivePurchaseView = true
//                    }
//                }
        }
    }
}
