//
//  ContentView.swift
//  CasanchessSmoke iOS
//
//  Created by Ilias Karim on 4/23/26.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack(spacing: 12) {
      Text("Casanchess iOS Smoke")
        .font(.title2)
      Text("SwiftUI app booted and XCFramework bridge initialized.")
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(24)
  }
}

#Preview {
  ContentView()
}
