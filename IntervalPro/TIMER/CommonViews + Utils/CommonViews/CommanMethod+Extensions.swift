//
//  CommanMethod+Extensions.swift
//  TIMER
//
//  Created by Aditya Maroo on 27/09/24.
//

import SwiftUI
///
///RUN ON MAIN THREAD
func runOnMainThread(_ body: @escaping ()->Void){
    DispatchQueue.main.async {
        body()
    }
}
///
///RUN WITH DELAY
func runWithDelay(delay:Double,_ body: @escaping ()->Void){
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delay) {
        body()
    }
}
