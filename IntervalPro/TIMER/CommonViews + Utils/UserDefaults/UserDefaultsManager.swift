//
//  UserDefaultsManager.swift
//  TIMER
//
//  Created by Aditya Maroo on 11/10/24.
//

import Foundation
private struct UserDefaultKeys{
    static var isUserSubscribed = "isUserSubscribed"
    static var disableVibrations = "disableVibrations"
    static var isIntroCompletedOnWorkingView = "isIntroCompletedOnWorkingView"
    static var isIntroCompletedOnIntervalReationCallView = "isIntervalReationCallView"
    static var isIntroCompletedOnTimerCreationCallView = "isTimerCreatonCallView"
    static var globalVolumeSoundIntervalApp = "globalVolumeSoundIntervalApp"
    static var disableAutoScreenOff = "disableAutoScreenOff"
    static var enableScreenLock = "enableScreenLock"
    static var themeModeSettingDark = "themeModeSettingDark"
    static var replacedDataCheckBox = "replacedDataCheckBox"
    static var systemVolumeLevel = "systemVolumeLevel"
    static var hundredthMilliSeconds = "hundredthMilliSeconds"
    static var appLaunchFirstTime = "appLaunchFirstTime"
    static var isPaidFolderAlreadyExist = "isPaidFolderAlreadyExist"
    static var purchaseDate = "purchaseDate"
    static var transactionId = "transactionId"
}

class AppDefaults{
    
    //MARK: -
    //MARK: CREATE SINGLTON
    static let shared:AppDefaults = {
        return AppDefaults()
    }()
    private init(){}
    
    //MARK: -
    //MARK: PROPERTIES
    private var userDefault = UserDefaults.standard
    
    //MARK: -
    //MARK: GET AND SET PROPERITES IN USERDEFAULTS
    var isUserSubscribed:Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.isUserSubscribed)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.isUserSubscribed)
        }
    }
    
    var isVibrationDisabled:Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.disableVibrations)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.disableVibrations)
        }
    }
    
    var isIntroCompletedOnWorkingView:Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.isIntroCompletedOnWorkingView)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.isIntroCompletedOnWorkingView)
        }
    }
    
    var isIntroCompletedOnIntervalReationCallView:Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.isIntroCompletedOnIntervalReationCallView)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.isIntroCompletedOnIntervalReationCallView)
        }
    }
    var isIntroCompletedOnTimerCreationCallView:Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.isIntroCompletedOnTimerCreationCallView)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.isIntroCompletedOnTimerCreationCallView)
        }
    }
    
    var systemVolumeLevel: Float{
        get{
            return userDefault.float(forKey: UserDefaultKeys.systemVolumeLevel)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.systemVolumeLevel)
        }
    }
    
    var globalVolumeSoundIntervalApp: Float{
        get{
            return userDefault.float(forKey: UserDefaultKeys.globalVolumeSoundIntervalApp)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.globalVolumeSoundIntervalApp)
        }
    }
    var disableAutoScreenOff :Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.disableAutoScreenOff)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.disableAutoScreenOff)
        }
    }
    var enableScreenLock:Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.enableScreenLock)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.enableScreenLock)
        }
    }
    var themeModeSettingDark: Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.themeModeSettingDark)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.themeModeSettingDark)
        }
    }
    var replacedDataCheckBox: Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.replacedDataCheckBox)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.replacedDataCheckBox)
        }
    }
    var hundredthMilliSeconds: Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.hundredthMilliSeconds)
        }
        set(newValue){
            userDefault.setValue(newValue, forKey: UserDefaultKeys.hundredthMilliSeconds)
        }
    }
    var appLaunchFirstTime: Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.appLaunchFirstTime)
        }
        set(newValue){
            userDefault.set(newValue, forKey: UserDefaultKeys.appLaunchFirstTime)
        }
    }
    var isPaidFolderAlreadyExist: Bool{
        get{
            return userDefault.bool(forKey: UserDefaultKeys.isPaidFolderAlreadyExist)
        }
        set(newValue){
            userDefault.set(newValue, forKey: UserDefaultKeys.isPaidFolderAlreadyExist)
        }
    }
}

 //MARK: - Extension for UserDefaults
extension UserDefaults {
    func contains(key: String) -> Bool {
        return self.object(forKey: key) != nil
    }
}
