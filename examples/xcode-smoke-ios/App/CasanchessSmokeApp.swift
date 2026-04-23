import SwiftUI

@main
struct CasanchessSmokeApp: App {
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

private struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Casanchess iOS Smoke")
                .font(.title2)
            Text("SwiftUI app booted and C++ bridge initialized.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}
