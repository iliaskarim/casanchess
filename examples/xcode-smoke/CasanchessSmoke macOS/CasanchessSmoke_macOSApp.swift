//
//  CasanchessSmoke_macOSApp.swift
//  CasanchessSmoke macOS
//
//  Created by Ilias Karim on 4/23/26.
//

import Casanchess
import SwiftUI

@main
struct CasanchessSmoke_macOSApp: App {
  init() {
    Task { @MainActor in
      await CasanchessSmokeRunner.run()
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
