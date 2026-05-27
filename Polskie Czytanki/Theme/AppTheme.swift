//
//  AppTheme.swift
//  Світ Казок
//

import SwiftUI

enum AppTheme {
    static let primaryGradient = LinearGradient(
        colors: [
            Color(red: 0.99, green: 0.61, blue: 0.27),
            Color(red: 0.96, green: 0.31, blue: 0.51)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let secondaryGradient = LinearGradient(
        colors: [
            Color(red: 0.40, green: 0.69, blue: 0.97),
            Color(red: 0.55, green: 0.36, blue: 0.95)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [
            Color(red: 0.31, green: 0.81, blue: 0.55),
            Color(red: 0.10, green: 0.62, blue: 0.45)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardBackground = Color(.systemBackground).opacity(0.92)
    static let softShadow = Color.black.opacity(0.12)

    static let cornerRadiusSmall: CGFloat = 12
    static let cornerRadiusMedium: CGFloat = 18
    static let cornerRadiusLarge: CGFloat = 28
}

extension Font {
    static let appTitle = Font.system(size: 44, weight: .heavy, design: .rounded)
    static let appSubtitle = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let appHeadline = Font.system(size: 22, weight: .bold, design: .rounded)
    static let appBody = Font.system(size: 17, weight: .regular, design: .rounded)
    static let appButton = Font.system(size: 20, weight: .bold, design: .rounded)
    static let appCaption = Font.system(size: 14, weight: .medium, design: .rounded)
}
