//
//  DaemonsManager.swift
//  Nugget
//
//  Created for the Nugget-Mobile fork (GoldenNugget daemons).
//

import Foundation

// MARK: Model

struct DaemonDef: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let labels: [String]
    let category: String
    let title: String
    let description: String
}

enum DaemonCategory: String, Codable, CaseIterable {
    case LOGGING
    case ANALYTICS
    case TRACKING
    case OTHER

    var displayName: String {
        switch self {
        case .LOGGING: return "Logging"
        case .ANALYTICS: return "Analytics"
        case .TRACKING: return "Data Tracking"
        case .OTHER: return "Other"
        }
    }
}

struct DaemonCatalog: Codable {
    let generatedFrom: String
    let recommended: [String]
    let daemons: [DaemonDef]

    enum CodingKeys: String, CodingKey {
        case generatedFrom = "generated_from"
        case recommended
        case daemons
    }
}

// MARK: Manager

class DaemonsManager: ObservableObject {
    static let shared = DaemonsManager()

    /// Set of launchd labels currently marked as disabled (`true`).
    @Published var enabledLabels: Set<String> = []

    /// Whether daemon modifications are gated on (the master switch). Persisted
    /// across launches so the enable state survives a restart.
    @Published var masterEnabled: Bool {
        didSet {
            UserDefaults.standard.set(masterEnabled, forKey: "DaemonMasterEnabled")
        }
    }

    let catalog: DaemonCatalog = DaemonsManager.loadCatalog()

    private static func loadCatalog() -> DaemonCatalog {
        guard let url = Bundle.main.url(forResource: "daemons", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode(DaemonCatalog.self, from: data)
        else {
            print("Failed to load daemons.json")
            return DaemonCatalog(generatedFrom: "", recommended: [], daemons: [])
        }
        return catalog
    }

    init() {
        // Persist selection across app launches
        enabledLabels = Set(UserDefaults.standard.stringArray(forKey: "DaemonDisabledLabels") ?? [])
        masterEnabled = UserDefaults.standard.bool(forKey: "DaemonMasterEnabled")
    }

    func setEnabled(_ daemon: DaemonDef, _ on: Bool) {
        if on {
            enabledLabels.formUnion(daemon.labels)
            masterEnabled = true
        } else {
            enabledLabels.subtract(daemon.labels)
        }
        UserDefaults.standard.set(Array(enabledLabels), forKey: "DaemonDisabledLabels")
    }

    func setEnabled(_ daemons: [DaemonDef], _ on: Bool) {
        for daemon in daemons {
            if on {
                enabledLabels.formUnion(daemon.labels)
            } else {
                enabledLabels.subtract(daemon.labels)
            }
        }
        if on {
            masterEnabled = true
        }
        UserDefaults.standard.set(Array(enabledLabels), forKey: "DaemonDisabledLabels")
    }

    func isOn(_ daemon: DaemonDef) -> Bool {
        return daemon.labels.contains { enabledLabels.contains($0) }
    }

    func isEnabled(_ daemons: [DaemonDef]) -> Bool {
        return daemons.allSatisfy { isOn($0) }
    }

    /// Number of daemons that are fully disabled (every label is enabled in the set).
    var disabledDaemonCount: Int {
        catalog.daemons.filter { daemon in
            !daemon.labels.isEmpty && daemon.labels.allSatisfy { enabledLabels.contains($0) }
        }.count
    }

    func daemons(in category: DaemonCategory) -> [DaemonDef] {
        return catalog.daemons.filter { DaemonCategory(rawValue: $0.category) == category }
    }

    /// Analytics/Data Tracking/Logging daemons (the combined "ADL" section).
    func adlDaemons() -> [DaemonDef] {
        let set: Set<DaemonCategory> = [.ANALYTICS, .TRACKING, .LOGGING]
        return catalog.daemons.filter { daemon in
            guard let category = DaemonCategory(rawValue: daemon.category) else { return false }
            return set.contains(category)
        }
    }

    func recommendedDaemons() -> [DaemonDef] {
        let names = Set(catalog.recommended)
        return catalog.daemons.filter { names.contains($0.name) }
    }

    /// Builds the `disabled.plist` payload for a restore: every selected
    /// label is set to `true` (disabled). Unlisted daemons stay enabled.
    func apply() -> Data {
        var plist: [String: Bool] = [:]
        for label in enabledLabels {
            plist[label] = true
        }
        return (try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)) ?? Data()
    }

    /// Re-enables everything this app knows about by writing `false` for
    /// every known launchd label.
    func reset() -> Data {
        var plist: [String: Bool] = [:]
        for daemon in catalog.daemons {
            for label in daemon.labels {
                plist[label] = false
            }
        }
        return (try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)) ?? Data()
    }
}