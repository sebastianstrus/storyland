//
//  PaywallView.swift
//  Storyland
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(StoreManager.self) private var store
    @Environment(\.dismiss) private var dismiss
    // 1. Detect if we are on a compact screen (iPhone) or regular screen (iPad)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var appeared = false
    @State private var showErrorAlert = false

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.36, blue: 0.95),
                    Color(red: 0.96, green: 0.31, blue: 0.51),
                    Color(red: 0.99, green: 0.61, blue: 0.27)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            floatingDecorations

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                ScrollView(isCompact ? [] : .vertical) { // Disable scrolling on iPhone if everything fits
                    VStack(spacing: isCompact ? 16 : 28) { // Tighter spacing on iPhone
                        heroIcon
                            .padding(.top, isCompact ? 5 : 20)

                        titleBlock

                        benefitsList

                        Spacer(minLength: 10)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: 550) // Beautiful constraints for large screens
                }
                .frame(maxWidth: .infinity)

                bottomBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, isCompact ? 16 : 28) // Bring bottom bar up slightly on iPhone
                    .frame(maxWidth: 550)
            }
        }
        .task {
            if store.products.isEmpty {
                await store.loadProducts()
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                appeared = true
            }
        }
        .onChange(of: store.isPremium) { _, newValue in
            if newValue { dismiss() }
        }
        .alert("Something went wrong", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(store.lastError ?? "Please try again later.")
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                HapticManager.tap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.callout.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
            }
            .accessibilityLabel(Text("Close"))
            Spacer()
        }
        .frame(height: 44)
    }

    private var heroIcon: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color.white.opacity(0.35), Color.white.opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                // Scale down icon on iPhone (from 150 to 95)
                .frame(width: isCompact ? 95 : 150, height: isCompact ? 95 : 150)
                .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 2))

            Image(systemName: "crown.fill")
                // Scale down crown graphic on iPhone
                .font(.system(size: isCompact ? 44 : 70, weight: .bold))
                .foregroundStyle(Color.yellow)
                .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
        }
        .scaleEffect(appeared ? 1.0 : 0.6)
        .opacity(appeared ? 1.0 : 0)
    }

    private var titleBlock: some View {
        VStack(spacing: isCompact ? 6 : 10) {
            Text("Unlock all tales")
                // Shrink title typography layout dynamically
                .font(.system(size: isCompact ? 24 : 30, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.35), radius: 8, y: 3)

            Text("One-time purchase. Forever access.")
                .font(isCompact ? .footnote : .appSubtitle)
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
        }
        .opacity(appeared ? 1.0 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private var benefitsList: some View {
        VStack(spacing: isCompact ? 8 : 12) { // Pack items tighter on iPhone
            benefitRow(icon: "books.vertical.fill", title: "320 tales", subtitle: "Full collection of short stories.")
            benefitRow(icon: "speaker.wave.2.fill", title: "Narrator audio", subtitle: "All audio recordings.")
            benefitRow(icon: "questionmark.circle.fill", title: "Questions and quizzes", subtitle: "Check comprehension after every tale.")
            benefitRow(icon: "infinity", title: "Forever access", subtitle: "One purchase, no subscriptions.")
        }
        .opacity(appeared ? 1.0 : 0)
        .offset(y: appeared ? 0 : 30)
    }

    private func benefitRow(icon: String, title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
        HStack(spacing: isCompact ? 10 : 14) {
            Image(systemName: icon)
                .font(isCompact ? .body.weight(.bold) : .title3.weight(.bold))
                .foregroundStyle(.white)
                // Shrink benefit icon container sizes on iPhone
                .frame(width: isCompact ? 36 : 44, height: isCompact ? 36 : 44)
                .background(Color.white.opacity(0.25), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.white.opacity(0.45), lineWidth: 1))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(isCompact ? .subheadline.weight(.bold) : .appHeadline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(isCompact ? .caption2 : .appCaption)
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(isCompact ? 10 : 14)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    }

    private var bottomBar: some View {
        VStack(spacing: isCompact ? 8 : 12) {
            purchaseButton
            restoreButton
            legalText
        }
    }

    @ViewBuilder
    private var purchaseButton: some View {
        Button {
            Task { await handlePurchase() }
        } label: {
            HStack(spacing: 12) {
                if store.isPurchasing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color(red: 0.55, green: 0.36, blue: 0.95))
                } else {
                    Image(systemName: "crown.fill")
                        .font(isCompact ? .body.weight(.bold) : .title2.weight(.bold))
                }
                Text(purchaseButtonTitle)
                    .font(isCompact ? .subheadline.weight(.bold) : .appButton)
            }
            .foregroundStyle(Color(red: 0.55, green: 0.36, blue: 0.95))
            .padding(.vertical, isCompact ? 14 : 18) // Slimmer action button height
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(BouncyButtonStyle())
        .disabled(store.isPurchasing || store.isLoadingProducts || store.premiumProduct == nil)
        .opacity(store.premiumProduct == nil && !store.isLoadingProducts ? 0.6 : 1.0)
    }

    private var purchaseButtonTitle: String {
        if store.isLoadingProducts {
            return "Loading..."
        }
        if let product = store.premiumProduct {
            return "Buy for \(product.displayPrice)"
        }
        return "Product unavailable"
    }

    private var restoreButton: some View {
        Button {
            Task { await handleRestore() }
        } label: {
            Text("Restore purchase")
                .font(.system(size: isCompact ? 11 : 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.vertical, isCompact ? 6 : 10)
                .padding(.horizontal, 18)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.45), lineWidth: 1))
        }
        .disabled(store.isPurchasing)
    }

    private var legalText: some View {
        Text("One-time payment. No auto-renewal.")
            .font(.system(size: isCompact ? 10 : 11, weight: .regular, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
            .multilineTextAlignment(.center)
            .padding(.top, 4)
    }

    private var floatingDecorations: some View {
        GeometryReader { geometry in
            ZStack {
                decorationBubble(size: 90, x: geometry.size.width * 0.15, y: geometry.size.height * 0.15)
                decorationBubble(size: 50, x: geometry.size.width * 0.85, y: geometry.size.height * 0.25)
                decorationBubble(size: 70, x: geometry.size.width * 0.88, y: geometry.size.height * 0.75)
                decorationBubble(size: 40, x: geometry.size.width * 0.12, y: geometry.size.height * 0.85)
            }
        }
        .allowsHitTesting(false)
    }

    private func decorationBubble(size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(Color.white.opacity(0.18))
            .frame(width: size, height: size)
            .blur(radius: 6)
            .position(x: x, y: y)
    }

    private func handlePurchase() async {
        HapticManager.tap()
        let success = await store.purchasePremium()
        if success {
            HapticManager.celebrate()
        } else if store.lastError != nil {
            showErrorAlert = true
        }
    }

    private func handleRestore() async {
        HapticManager.tap()
        await store.restorePurchases()
        if store.lastError != nil {
            showErrorAlert = true
        } else if store.isPremium {
            HapticManager.success()
        }
    }
}

#Preview {
    PaywallView()
        .environment(StoreManager())
}
