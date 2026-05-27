//
//  PrimaryButton.swift
//  Storyland
//

import SwiftUI

struct PrimaryButton: View {
    let titleKey: LocalizedStringKey
    let systemImage: String?
    let gradient: LinearGradient
    let action: () -> Void

    init(
        _ titleKey: LocalizedStringKey,
        systemImage: String? = nil,
        gradient: LinearGradient = AppTheme.primaryGradient,
        action: @escaping () -> Void
    ) {
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.gradient = gradient
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.tap()
            action()
        } label: {
            HStack(spacing: 12) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.title2.weight(.bold))
                }
                Text(titleKey)
                    .font(.appButton)
            }
            .foregroundStyle(.white)
            .padding(.vertical, 18)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .fill(gradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: AppTheme.softShadow, radius: 18, x: 0, y: 10)
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.32, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
