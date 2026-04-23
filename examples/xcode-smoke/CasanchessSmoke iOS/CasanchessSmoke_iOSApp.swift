//
//  CasanchessSmoke_iOSApp.swift
//  CasanchessSmoke iOS
//
//  Created by Ilias Karim on 4/23/26.
//

import SwiftUI

@main
struct CasanchessSmoke_iOSApp: App {
    init() {
        if CasanchessSmokeCheck() {
            NSLog("Casanchess iOS smoke check passed")
        } else {
            NSLog("Casanchess iOS smoke check failed")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
