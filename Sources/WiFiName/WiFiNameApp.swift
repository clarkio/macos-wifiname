import SwiftUI

@main
struct WiFiNameApp: App {
    @StateObject private var monitor = WiFiMonitor()

    var body: some Scene {
        MenuBarExtra {
            Button(monitor.isVisible ? "Hide Name" : "Show Name") {
                monitor.isVisible.toggle()
            }
            .keyboardShortcut("t")

            if monitor.needsLocationPermission {
                Divider()
                Button("Grant Location Access…") {
                    monitor.openLocationSettings()
                }
            }

            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Image(nsImage: MenuBarImage.make(top: monitor.topLine, bottom: monitor.bottomLine))
        }
        .menuBarExtraStyle(.menu)
    }
}
