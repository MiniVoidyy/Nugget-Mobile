//
//  DaemonsView.swift
//  Golden Nugget
//
//  Created for the Nugget-Mobile fork (GoldenNugget daemons).
//  UI mirrors the PC GoldenNugget iOS-style dark theme.
//

import SwiftUI

struct DaemonsView: View {
    @StateObject var manager = DaemonsManager.shared
    @StateObject var applyHandler = ApplyHandler.shared
    @State private var search = ""

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if search.isEmpty {
                        headerSection
                    } else {
                        searchResults
                    }
                }
                .padding(16)
            }
        }
        .background(GNTheme.background)
        .preferredColorScheme(.dark)
        .navigationTitle("Daemons")
    }

    // MARK: Master switch + Recommended

    @ViewBuilder
    private var headerSection: some View {
        GNSectionHeader(title: "Daemons to Disable")

        GNSwitchRow(
            title: "Enable Daemon Modifications",
            isOn: Binding(
                get: { manager.masterEnabled },
                set: { on in
                    manager.masterEnabled = on
                    applyHandler.setTweakEnabled(.Daemons, isEnabled: on)
                }
            )
        )

        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(GNTheme.gold)
            Text("\(manager.disabledDaemonCount) of \(manager.catalog.daemons.count) disabled")
                .font(.system(size: 13))
                .foregroundColor(GNTheme.secondaryText)
            Spacer()
            if masterEnabled {
                Text("Modifications active")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(GNTheme.toggleOn)
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 2)

        if !manager.recommendedDaemons().isEmpty {
            GNSwitchRow(
                title: "Recommended",
                subtitle: "Telemetry, analytics & tracking",
                isOn: Binding(
                    get: { manager.isEnabled(manager.recommendedDaemons()) },
                    set: { on in
                        manager.setEnabled(manager.recommendedDaemons(), on)
                        if on { masterOn() }
                    }
                ),
                enabled: masterEnabled
            )
        }

        // Analytics, Data Tracking & Logging
        if !adlDaemons.isEmpty {
            GNSectionHeader(title: "Analytics, Data Tracking & Logging (\(adlDaemons.count))")
            GNSwitchRow(
                title: "Select all analytics, tracking & logging daemons",
                isOn: Binding(
                    get: { manager.isEnabled(adlDaemons) },
                    set: { on in
                        manager.setEnabled(adlDaemons, on)
                        if on { masterOn() }
                    }
                ),
                enabled: masterEnabled
            )
            ForEach(adlDaemons) { daemon in
                daemonRow(daemon)
            }
        }

        // Other
        if !otherDaemons.isEmpty {
            GNSectionHeader(title: "Other (\(otherDaemons.count))")
            ForEach(otherDaemons) { daemon in
                daemonRow(daemon)
            }
        }

        // Screen Time (dedicated section, matches PC)
        if screenTimeDaemon != nil {
            GNSectionHeader(title: "Disable Screen Time Agent")
            if let screenTime = screenTimeDaemon {
                daemonRow(screenTime)
            }
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        if matchingDaemons.isEmpty {
            Text("No daemons match “\(search)”")
                .font(.system(size: 15))
                .foregroundColor(GNTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 40)
        } else {
            GNSectionHeader(title: "Search Results (\(matchingDaemons.count))")
            ForEach(matchingDaemons) { daemon in
                daemonRow(daemon)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(GNTheme.secondaryText)
            TextField("Search daemons", text: $search)
                .foregroundColor(GNTheme.primaryText)
                .autocorrectionDisabled()
            if !search.isEmpty {
                Button {
                    search = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(GNTheme.secondaryText)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(GNTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private func daemonRow(_ daemon: DaemonDef) -> some View {
        GNSwitchRow(
            title: daemon.title,
            subtitle: daemon.description,
            isOn: Binding(
                get: { manager.isOn(daemon) },
                set: { on in
                    manager.setEnabled(daemon, on)
                    if on { masterOn() }
                    if on, daemon.title.contains("Location") {
                        locationWarning()
                    }
                }
            ),
            enabled: masterEnabled
        )
        .help(daemon.description)
    }

    // MARK: Derived data

    private var masterEnabled: Bool {
        manager.masterEnabled
    }

    private func masterOn() {
        manager.masterEnabled = true
        applyHandler.setTweakEnabled(.Daemons, isEnabled: true)
    }

    private var adlDaemons: [DaemonDef] {
        manager.adlDaemons().filter { !isScreenTime($0) }
    }

    private var otherDaemons: [DaemonDef] {
        manager.daemons(in: .OTHER)
    }

    private var screenTimeDaemon: DaemonDef? {
        manager.catalog.daemons.first(where: { isScreenTime($0) })
    }

    private func isScreenTime(_ daemon: DaemonDef) -> Bool {
        daemon.title.lowercased().contains("screen time")
    }

    private var matchingDaemons: [DaemonDef] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return manager.catalog.daemons.filter {
            $0.title.lowercased().contains(q) ||
            $0.description.lowercased().contains(q) ||
            $0.name.lowercased().contains(q)
        }
    }

    private func locationWarning() {
        let device = UIDevice.current.type
        if device.isiPhone14 {
            UIApplication.shared.confirmAlert(
                title: "Wallpaper Risk on iPhone 14",
                body: "Disabling Location Services can break PosterBoard wallpapers on iPhone 14. Continue?",
                onOK: {}, noCancel: false
            )
        }
    }
}
