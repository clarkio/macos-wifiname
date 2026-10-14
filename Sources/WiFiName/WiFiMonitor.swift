import AppKit
import CoreLocation
import CoreWLAN

/// Tracks the current Wi-Fi SSID and live throughput, and publishes the text
/// shown in the menu bar.
///
/// Since macOS 14, `CWInterface.ssid()` returns nil unless the app has been
/// granted Location access, so this also drives the permission flow.
@MainActor
final class WiFiMonitor: NSObject, ObservableObject, CWEventDelegate, CLLocationManagerDelegate {
    @Published private(set) var ssid: String?
    @Published private(set) var needsLocationPermission = false
    @Published private(set) var downBytesPerSecond: Double = 0
    @Published private(set) var upBytesPerSecond: Double = 0
    @Published var isVisible = true

    private let wifiClient = CWWiFiClient.shared()
    private let locationManager = CLLocationManager()

    // Throughput sampling state
    private var sampleTimer: Timer?
    private var lastInterface: String?
    private var lastCounters: (rx: UInt32, tx: UInt32)?
    private var lastSampleTime: TimeInterval = 0

    /// First line: network name (or underscores when hidden).
    var topLine: String {
        let name: String
        if let ssid {
            name = ssid
        } else if needsLocationPermission {
            name = "Allow Location"   // makes a missing permission visible instead of looking like "no Wi-Fi"
        } else {
            name = "Disconnected"
        }
        return isVisible ? name : String(repeating: "_", count: name.count)
    }

    /// Second line: "↓ down ↑ up", e.g. "↓120KB/s ↑32KB/s".
    var bottomLine: String {
        "↓\(Self.format(downBytesPerSecond)) ↑\(Self.format(upBytesPerSecond))"
    }

    override init() {
        super.init()
        locationManager.delegate = self
        startMonitoring()
        requestLocationIfNeeded()
        refresh()
        startSampling()
    }

    deinit {
        try? wifiClient.stopMonitoringAllEvents()
    }

    // MARK: - Wi-Fi

    private func startMonitoring() {
        wifiClient.delegate = self
        do {
            try wifiClient.startMonitoringEvent(with: .ssidDidChange)
        } catch {
            NSLog("WiFiName: could not monitor SSID changes: \(error.localizedDescription)")
        }
    }

    private func refresh() {
        // `interface()` is nil on Macs without Wi-Fi hardware; the original force-unwrapped it.
        let name = wifiClient.interface()?.ssid()
        // Treat an empty string like nil so the top line is never blank.
        ssid = (name?.isEmpty ?? true) ? nil : name
        updatePermissionState()
    }

    nonisolated func ssidDidChangeForWiFiInterface(withName interfaceName: String) {
        Task { @MainActor in self.refresh() }
    }

    // MARK: - Throughput

    private func startSampling() {
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.sample()
                // Cheap, and recovers if permission was granted after launch.
                if self?.ssid == nil { self?.refresh() }
            }
        }
        // .common so it keeps ticking while the menu is open.
        RunLoop.main.add(timer, forMode: .common)
        sampleTimer = timer
        sample()
    }

    private func sample() {
        let name = wifiClient.interface()?.interfaceName ?? "en0"
        let now = ProcessInfo.processInfo.systemUptime

        guard let counters = Self.readCounters(for: name) else {
            downBytesPerSecond = 0
            upBytesPerSecond = 0
            lastCounters = nil
            return
        }

        defer {
            lastInterface = name
            lastCounters = counters
            lastSampleTime = now
        }

        // Skip the first sample and any interface switch: no valid baseline yet.
        guard let previous = lastCounters, lastInterface == name else { return }

        let elapsed = now - lastSampleTime
        guard elapsed > 0 else { return }

        // The kernel counters are 32-bit and wrap; wrapping subtraction handles that.
        downBytesPerSecond = Double(counters.rx &- previous.rx) / elapsed
        upBytesPerSecond = Double(counters.tx &- previous.tx) / elapsed
    }

    /// Cumulative received/sent bytes for a network interface, from getifaddrs.
    private static func readCounters(for interfaceName: String) -> (rx: UInt32, tx: UInt32)? {
        var list: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&list) == 0, let first = list else { return nil }
        defer { freeifaddrs(list) }

        var cursor: UnsafeMutablePointer<ifaddrs>? = first
        while let entry = cursor {
            let ifa = entry.pointee
            if let cName = ifa.ifa_name,
               String(cString: cName) == interfaceName,
               let addr = ifa.ifa_addr,
               addr.pointee.sa_family == UInt8(AF_LINK),
               let data = ifa.ifa_data {
                let stats = data.assumingMemoryBound(to: if_data.self).pointee
                return (stats.ifi_ibytes, stats.ifi_obytes)
            }
            cursor = ifa.ifa_next
        }
        return nil
    }

    /// Bytes per second -> "0KB/s", "850KB/s", "12.3MB/s", "1.2GB/s" (decimal units, 1 KB = 1000 B).
    static func format(_ bytesPerSecond: Double) -> String {
        let kb = bytesPerSecond / 1_000
        if kb < 1_000 { return String(format: "%.0fKB/s", kb) }
        let mb = kb / 1_000
        if mb < 1_000 { return String(format: "%.1fMB/s", mb) }
        return String(format: "%.1fGB/s", mb / 1_000)
    }

    // MARK: - Location permission

    private func requestLocationIfNeeded() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func updatePermissionState() {
        let status = locationManager.authorizationStatus
        let authorized = status == .authorizedAlways
        // Only flag it when a name is actually missing and permission is why it might be.
        needsLocationPermission = ssid == nil && !authorized
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in self.refresh() }
    }

    func openLocationSettings() {
        requestLocationIfNeeded()
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices")!
        NSWorkspace.shared.open(url)
    }
}
