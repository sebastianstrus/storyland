//
//  StoryRowView.swift
//  Storyland
//

import SwiftUI

struct StoryRowView: View {
    let story: Story
    let isCompleted: Bool
    let isLocked: Bool

    init(story: Story, isCompleted: Bool, isLocked: Bool = false) {
        self.story = story
        self.isCompleted = isCompleted
        self.isLocked = isLocked
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack(alignment: .topTrailing) {
                Image(story.smallImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 92, height: 92)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(color: AppTheme.softShadow, radius: 6, y: 3)
                    .overlay {
                        if isLocked {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.black.opacity(0.45))
                                .overlay(
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundStyle(.white)
                                        .shadow(color: .black.opacity(0.45), radius: 4, y: 2)
                                )
                        }
                    }

                Text("\(story.number)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.primaryGradient, in: Capsule())
                    .overlay(Capsule().stroke(Color.white, lineWidth: 2))
                    .offset(x: 6, y: -6)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(story.title)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                statusBadge
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(trailingIconBackground)
                    .frame(width: 32, height: 32)
                Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                    .font(.footnote.weight(.heavy))
                    .foregroundStyle(trailingIconColor)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(Color.white)
        )
        .shadow(color: AppTheme.softShadow, radius: 10, x: 0, y: 5)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if isLocked {
            HStack(spacing: 6) {
                Image(systemName: "crown.fill")
                    .font(.footnote.weight(.bold))
                Text("Premium")
                    .font(.appCaption.weight(.bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.secondaryGradient, in: Capsule())
        } else if isCompleted {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.footnote.weight(.bold))
                Text("Completed")
                    .font(.appCaption.weight(.bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.successGradient, in: Capsule())
        } else {
            HStack(spacing: 6) {
                Image(systemName: "hand.tap.fill")
                    .font(.caption.weight(.bold))
                Text("Tap to read")
                    .font(.appCaption)
            }
            .foregroundStyle(.secondary)
        }
    }

    private var trailingIconBackground: some ShapeStyle {
        if isLocked {
            return AnyShapeStyle(AppTheme.secondaryGradient.opacity(0.18))
        }
        return AnyShapeStyle(AppTheme.primaryGradient.opacity(0.18))
    }

    private var trailingIconColor: Color {
        if isLocked {
            return Color(red: 0.55, green: 0.36, blue: 0.95)
        }
        return Color(red: 0.96, green: 0.31, blue: 0.51)
    }
}
