//
//  DaemonsView.swift
//  Nugget
//
//  Created for the Nugget-Mobile fork (GoldenNugget daemons).
//

import SwiftUI

struct DaemonsView: View {
    @StateObject var manager = DaemonsManager.shared
    @StateObject var applyHandler = ApplyHandler.shared

    var body: some View {
        List {
            if !manager.recommendedDaemons().isEmpty {
                Section {
                    Toggle(isOn: Binding(
                        get: { manager.isEnabled(manager.recommendedDaemons()) },
                        set: { on in
                            manager.setEnabled(manager.recommendedDaemons(), on)
                            if on { applyHandler.setTweakEnabled(.Daemons, isEnabled: true) }
                        }
                    )) {
                        Label("Recommended", systemImage: "checkmark.seal")
                            .font(.headline)
                    }
                    .help("Enable the recommended set of telemetry, analytics, and logging daemons at once.")
                } header: {
                    Text("Recommended")
                }
            }

            let adlDaemons = manager.adlDaemons()
            if !adlDaemons.isEmpty {
                Section {
                    Toggle(isOn: Binding(
                        get: { manager.isEnabled(adlDaemons) },
                        set: { on in
                            manager.setEnabled(adlDaemons, on)
                            if on { applyHandler.setTweakEnabled(.Daemons, isEnabled: true) }
                        }
                    )) {
                        Label("Select all analytics, tracking & logging daemons", systemImage: "square.stack")
                            .font(.headline)
                    }
                    ForEach(adlDaemons) { daemon in
                        daemonRow(daemon)
                    }
                } header: {
                    Text("Analytics, Data Tracking & Logging")
                }
            }

            let otherDaemons = manager.daemons(in: .OTHER)
            if !otherDaemons.isEmpty {
                Section {
                    ForEach(otherDaemons) { daemon in
                        daemonRow(daemon)
                    }
                } header: {
                    Text("Other")
                }
            }
        }
        .tweakToggle(for: .Daemons)
        .navigationTitle("Daemons")
    }

    @ViewBuilder
    func daemonRow(_ daemon: DaemonDef) -> some View {
        Toggle(isOn: Binding(
            get: { manager.isOn(daemon) },
            set: { on in
                manager.setEnabled(daemon, on)
                if on { applyHandler.setTweakEnabled(.Daemons, isEnabled: true) }
            }
        )) {
            VStack(alignment: .leading, spacing: 2) {
                Text(daemon.title)
                if !daemon.description.isEmpty {
                    Text(daemon.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .help(daemon.description)
    }
}