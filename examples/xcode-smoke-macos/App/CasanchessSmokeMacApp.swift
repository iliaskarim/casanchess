import SwiftUI

@main
struct CasanchessSmokeMacApp: App {
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

private struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Casanchess macOS Smoke")
                .font(.title2)
            Text("SwiftUI app booted and C++ bridge initialized.")
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(minWidth: 460, minHeight: 220)
    }
}
