//
//  GNTheme.swift
//  Golden Nugget
//
//  Golden Nugget shared palette + iOS-dark theme helpers.
//  Mirrors the PC GoldenNugget iOS theme, with a gold brand accent.
//

import SwiftUI

enum GNTheme {
    // Brand gold accent
    static let gold = Color(red: 0xF0 / 255.0, green: 0xB9 / 255.0, blue: 0x0B / 255.0)
    static let goldBright = Color(red: 1.0, green: 0xD7 / 255.0, blue: 0x3D / 255.0)
    static let goldDark = Color(red: 0xC8 / 255.0, green: 0x99 / 255.0, blue: 0x0A / 255.0)

    // Neutrals (matches PC ios_theme.qss)
    static let background = Color(red: 0x1e / 255.0, green: 0x1e / 255.0, blue: 0x1e / 255.0)
    static let card = Color(red: 0x1c / 255.0, green: 0x1c / 255.0, blue: 0x1e / 255.0)
    static let cardElevated = Color(red: 0x23 / 255.0, green: 0x23 / 255.0, blue: 0x25 / 255.0)
    static let hairline = Color(red: 0x3a / 255.0, green: 0x3a / 255.0, blue: 0x3c / 255.0)
    static let divider = Color(red: 0x38 / 255.0, green: 0x38 / 255.0, blue: 0x3a / 255.0)
    static let primaryText = Color(red: 1.0, green: 1.0, blue: 1.0)
    static let secondaryText = Color(red: 0x8e / 255.0, green: 0x8e / 255.0, blue: 0x93 / 255.0)
    static let disabledText = Color(red: 0x8e / 255.0, green: 0x8e / 255.0, blue: 0x93 / 255.0)

    // iOS green for switches
    static let toggleOn = Color(red: 0x30 / 255.0, green: 0xd1 / 255.0, blue: 0x58 / 255.0)
    static let toggleOff = Color(red: 0x3a / 255.0, green: 0x3a / 255.0, blue: 0x3c / 255.0)

    // Status
    static let success = GNTheme.toggleOn
    static let error = Color(red: 0xff / 255.0, green: 0x45 / 255.0, blue: 0x3a / 255.0)
}

/// iOS-style toggle switch (custom, green when on, matches PC IOSSwitch 51x31).
struct GNSwitch: View {
    @Binding var isOn: Bool
    var onColor: Color = GNTheme.toggleOn

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(isOn ? onColor : GNTheme.toggleOff)
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

/// iOS Settings-style uppercase gray section header.
struct GNSectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .tracking(0.5)
            .foregroundColor(GNTheme.secondaryText)
            .padding(.leading, 4)
            .padding(.top, 12)
    }
}

/// A card row with a leading label (and optional subtitle/description) and a trailing switch.
struct GNSwitchRow: View {
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    var enabled: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(enabled ? GNTheme.primaryText : GNTheme.disabledText)
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(GNTheme.secondaryText)
                        .lineLimit(3)
                }
            }
            Spacer()
            GNSwitch(isOn: $isOn)
                .disabled(!enabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(GNTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
