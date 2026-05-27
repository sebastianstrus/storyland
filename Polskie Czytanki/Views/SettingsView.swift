//
//  SettingsView.swift
//  Світ Казок
//

import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(ProgressStore.self) private var progress
    @Environment(StoreManager.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showResetConfirmation = false
    @State private var showOnboarding = false
    @State private var showPaywall = false

    var body: some View {
        @Bindable var bindableSettings = settings

        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.00, green: 0.95, blue: 0.84),
                    Color(red: 1.00, green: 0.88, blue: 0.92),
                    Color(red: 0.88, green: 0.92, blue: 1.00)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    sectionHeader("Premium")
                    SettingsCard {
                        premiumRow
                    }

                    sectionHeader("Відтворення")
                    SettingsCard {
                        Toggle(isOn: $bindableSettings.showPlayButton) {
                            HStack(spacing: 14) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(AppTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Показати кнопку відтворення")
                                        .font(.appHeadline)
                                        .foregroundStyle(.primary)
                                    Text("Сховай її, щоб дитина могла читати без звуку.")
                                        .font(.appCaption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .tint(Color(red: 0.31, green: 0.81, blue: 0.55))
                        .onChange(of: bindableSettings.showPlayButton) { _, _ in
                            HapticManager.selection()
                        }
                    }

                    sectionHeader("Вступ")
                    SettingsCard {
                        Button {
                            HapticManager.tap()
                            showOnboarding = true
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "sparkles")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(AppTheme.secondaryGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Показати вступ")
                                        .font(.appHeadline)
                                        .foregroundStyle(.primary)
                                    Text("Подивися знову вітальні екрани програми.")
                                        .font(.appCaption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    sectionHeader("Прогрес")
                    SettingsCard {
                        Button {
                            HapticManager.warning()
                            showResetConfirmation = true
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.96, green: 0.42, blue: 0.42),
                                                Color(red: 0.86, green: 0.20, blue: 0.30)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Скинути прогрес")
                                        .font(.appHeadline)
                                        .foregroundStyle(.primary)
                                    Text("Завершено: \(progress.completedCount)")
                                        .font(.appCaption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 16)

                    versionLabel

                    Spacer(minLength: 8)
                }
                .padding(20)
            }
        }
        .navigationTitle(Text("Налаштування"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 1.00, green: 0.95, blue: 0.84), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .confirmationDialog(
            Text("Скинути весь прогрес?"),
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                HapticManager.success()
                progress.resetAll()
            } label: {
                Text("Скинути")
            }
            Button(role: .cancel) {} label: {
                Text("Скасувати")
            }
        } message: {
            Text("Це очистить завершення усіх 320 казок.")
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {}
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    @ViewBuilder
    private var premiumRow: some View {
        if store.isPremium {
            HStack(spacing: 14) {
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.successGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Premium активний")
                        .font(.appHeadline)
                        .foregroundStyle(.primary)
                    Text("Ти маєш доступ до всіх 320 казок.")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(Color(red: 0.31, green: 0.81, blue: 0.55))
            }
        } else {
            VStack(spacing: 12) {
                Button {
                    HapticManager.tap()
                    showPaywall = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "crown.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(AppTheme.secondaryGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Активувати Premium")
                                .font(.appHeadline)
                                .foregroundStyle(.primary)
                            Text("Розблокуй усі казки назавжди.")
                                .font(.appCaption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)

                Divider()

                Button {
                    HapticManager.tap()
                    Task { await store.restorePurchases() }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(AppTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Відновити покупку")
                                .font(.appHeadline)
                                .foregroundStyle(.primary)
                            Text("Якщо ти вже купив Premium на цьому акаунті.")
                                .font(.appCaption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var versionLabel: some View {
        VStack(spacing: 4) {
            Text("Світ Казок")
                .font(.appCaption.weight(.bold))
                .foregroundStyle(.secondary)
            Text(versionString)
                .font(.appCaption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var versionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "Версія \(version) (\(build))"
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        HStack {
            Text(key)
                .font(.appCaption.weight(.heavy))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, 6)
    }
}

private struct SettingsCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 6)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(SettingsStore())
            .environment(ProgressStore())
            .environment(StoreManager())
    }
}
