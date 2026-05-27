//
//  QuestionCard.swift
//  Світ Казок
//

import SwiftUI

struct QuestionCard: View {
    let questionNumber: Int
    let totalQuestions: Int
    let question: Question

    @Binding var selectedOption: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                Text("\(questionNumber)")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.secondaryGradient, in: Circle())

                Text("Питання \(questionNumber) з \(totalQuestions)")
                    .font(.appCaption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }

            Text(question.question)
                .font(.appHeadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(Array(question.options.enumerated()), id: \.element) { index, option in
                    OptionButton(
                        letter: letter(at: index),
                        text: option,
                        isSelected: selectedOption == option
                    ) {
                        selectedOption = option
                        HapticManager.selection()
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(Color.white)
        )
        .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 6)
    }

    private func letter(at index: Int) -> String {
        let scalars: [String] = ["A", "B", "C", "D", "E", "F"]
        return scalars[safe: index] ?? "?"
    }
}

struct OptionButton: View {
    let letter: String
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(badgeForeground)
                    .frame(width: 32, height: 32)
                    .background(badgeBackground, in: Circle())

                Text(text)
                    .font(.appBody.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(BouncyButtonStyle())
    }

    private var cardBackground: Color {
        isSelected
            ? Color(red: 0.40, green: 0.69, blue: 0.97).opacity(0.18)
            : Color(.secondarySystemBackground)
    }

    private var borderColor: Color {
        Color(red: 0.40, green: 0.69, blue: 0.97)
    }

    private var badgeBackground: AnyShapeStyle {
        isSelected
            ? AnyShapeStyle(AppTheme.secondaryGradient)
            : AnyShapeStyle(Color.secondary.opacity(0.15))
    }

    private var badgeForeground: Color {
        isSelected ? .white : .secondary
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
