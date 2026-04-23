//
//  ContentView.swift
//  CasanchessSmoke macOS
//
//  Created by Ilias Karim on 4/23/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Casanchess macOS Smoke")
                .font(.title2)
            Text("SwiftUI app booted and XCFramework bridge initialized.")
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(minWidth: 460, minHeight: 220)
    }
}

#Preview {
    ContentView()
}
