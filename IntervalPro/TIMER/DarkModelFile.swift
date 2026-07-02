//
//  DarkModelFile.swift
//  TIMER
//
//  Created by Aditya Maroo on 04/09/24.
//

import SwiftUI

class AppEnvironment: ObservableObject {
    @Published var isDarkMode: Bool = AppDefaults.shared.themeModeSettingDark
    @Published var isActivePurchaseView:Bool = false
}
