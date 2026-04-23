//
//  CasanchessSmoke_macOSApp.swift
//  CasanchessSmoke macOS
//
//  Created by Ilias Karim on 4/23/26.
//

import SwiftUI

@main
struct CasanchessSmoke_macOSApp: App {
    init() {
        if CasanchessSmokeCheck() {
            NSLog("Casanchess macOS smoke check passed")
        } else {
            NSLog("Casanchess macOS smoke check failed")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
