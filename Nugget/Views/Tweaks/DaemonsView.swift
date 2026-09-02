//
//  DaemonsView.swift
//  Golden Nugget
//
//  Created for the Nugget-Mobile fork (GoldenNugget daemons).
//  UI mirrors the PC GoldenNugget iOS-style dark theme.
//

import SwiftUI

// MARK: - GoldenNugget palette (matches ios_theme.qss)

enum GNColor {
    static let background = Color(red: 0x1e / 255.0, green: 0x1e / 255.0, blue: 0x1e / 255.0)
    static let card = Color(red: 0x1c / 255.0, green: 0x1c / 255.0, blue: 0x1e / 255.0)
    static let hairline = Color(red: 0x3a / 255.0, green: 0x3a / 255.0, blue: 0x3c / 255.0)
    static let primaryText = Color(red: 1.0, green: 1.0, blue: 1.0)
    static let secondaryText = Color(red: 0x8e / 255.0, green: 0x8e / 255.0, blue: 0x93 / 255.0)
    static let accent = Color(red: 0.0, green: 0x7a / 255.0, blue: 1.0)
    static let toggleOn = Color(red: 0x30 / 255.0, green: 0xd1 / 255.0, blue: 0x58 / 255.0)
    static let toggleOff = Color(red: 0x3a / 255.0, green: 0x3a / 255.0, blue: 0x3c / 255.0)
    static let divider = Color(red: 0x38 / 255.0, green: 0x38 / 255.0, blue: 0x3a / 255.0)
}

// MARK: - iOS-style toggle (green when on)

struct GNSwitch: View {
    @Binding var isOn: Bool
    var onColor: Color = GNColor.toggleOn

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(isOn ? onColor : GNColor.toggleOff)
                    .frame(width: 51, height: 31)
                Circle()
                    .fill(.white)
                    .frame(width: 27, height: 27)
                    .padding(.leading, isOn ? 22 : 2)
            }
            .animation(.easeInOut(duration: 0.2), value: isOn)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOn ? "On" : "Off")
    }
}

// MARK: - Section header (iOS Settings style, uppercase gray)

struct GNSectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .tracking(0.5)
            .foregroundColor(GNColor.secondaryText)
            .padding(.leading, 4)
    }
}

// MARK: - Card row containing a switch + label

struct GNSwitchRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(GNColor.primaryText)
            Spacer()
            GNSwitch(isOn: $isOn)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(GNColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Daemons view

struct DaemonsView: View {
    @StateObject var manager = DaemonsManager.shared
    @StateObject var applyHandler = ApplyHandler.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                GNSectionHeader(title: "Daemons to Disable")

                GNSwitchRow(
                    title: "Enable Daemon Modifications",
                    isOn: Binding(
                        get: { applyHandler.isTweakEnabled(.Daemons) },
                        set: { applyHandler.setTweakEnabled(.Daemons, isEnabled: $0) }
                    )
                )

                recommendedRow()

                GNSectionHeader(title: "Analytics, Data Tracking & Logging")
                GNSwitchRow(
                    title: "Select all analytics, tracking & logging daemons",
                    isOn: Binding(
                        get: { manager.isEnabled(adlDaemons) },
                        set: { on in
                            manager.setEnabled(adlDaemons, on)
                            if on { applyHandler.setTweakEnabled(.Daemons, isEnabled: true) }
                        }
                    )
                )
                ForEach(adlDaemons) { daemon in
                    GNSwitchRow(
                        title: daemon.title,
                        isOn: daemon.bind(on: manager, applyHandler: applyHandler)
                    )
                    .help(daemon.description)
                }

                GNSectionHeader(title: "Other")
                ForEach(otherDaemons) { daemon in
                    GNSwitchRow(
                        title: daemon.title,
                        isOn: daemon.bind(on: manager, applyHandler: applyHandler)
                    )
                    .help(daemon.description)
                }
            }
            .padding(16)
        }
        .background(GNColor.background)
        .preferredColorScheme(.dark)
        .navigationTitle("Daemons")
    }

    private var adlDaemons: [DaemonDef] {
        manager.adlDaemons().filter { !$0.title.lowercased().contains("screen time") }
    }

    private var otherDaemons: [DaemonDef] {
        manager.daemons(in: .OTHER)
    }

    @ViewBuilder
    private func recommendedRow() -> some View {
        let rec = manager.recommendedDaemons()
        if !rec.isEmpty {
            GNSwitchRow(
                title: "Recommended",
                isOn: Binding(
                    get: { manager.isEnabled(rec) },
                    set: { on in
                        manager.setEnabled(rec, on)
                        if on { applyHandler.setTweakEnabled(.Daemons, isEnabled: true) }
                    }
                )
            )
        }
    }}

extension DaemonDef {
    func bind(on manager: DaemonsManager, applyHandler: ApplyHandler) -> Binding<Bool> {
        Binding(
            get: { manager.isOn(self) },
            set: { on in
                manager.setEnabled(self, on)
                if on { applyHandler.setTweakEnabled(.Daemons, isEnabled: true) }
            }
        )
    }
}
