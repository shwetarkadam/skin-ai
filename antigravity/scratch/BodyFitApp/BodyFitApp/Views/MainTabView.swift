import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)

            NavigationStack {
                ClothingGalleryView()
            }
            .tabItem {
                Image(systemName: "tshirt.fill")
                Text("Wardrobe")
            }
            .tag(1)

            NavigationStack {
                BodyProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(2)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
            .tag(3)
        }
        .tint(AppColors.accentTeal)
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor(AppColors.surfaceDark)
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var clothingVM: ClothingViewModel
    @State private var profile: BodyProfile = BodyProfile.load() ?? BodyProfile()
    @State private var animateCards = false

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    headerSection

                    // Body shape card
                    if let shape = profile.detectedShape {
                        bodyShapeCard(shape)
                    }

                    // Dress-first CTA
                    tryOnDressCard

                    // Quick actions
                    quickActions

                    // Recent clothing (dresses first)
                    if !clothingVM.clothingItems.isEmpty {
                        recentClothing
                    }
                }
                .padding(AppConstants.padding)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            profile = BodyProfile.load() ?? profile
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { animateCards = true }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome to")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Text("BodyFit")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppColors.accentGradient)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
    }

    private func bodyShapeCard(_ shape: BodyShape) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Body Shape")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(shape.icon)
                            .font(.title)
                        Text(shape.rawValue)
                            .font(.title2.weight(.bold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Text("\(Int(profile.shapeConfidence * 100))% match")
                        .font(.caption)
                        .foregroundColor(AppColors.accentTeal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppColors.accentTeal.opacity(0.12))
                        .clipShape(Capsule())
                }

                Spacer()

                NavigationLink(destination: BodyProfileView()) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppColors.accentGradient)
                }
            }

            // Quick tips
            if let tip = shape.stylingTips.first {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(AppColors.warning)
                        .font(.caption)
                    Text(tip)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(12)
                .background(AppColors.warning.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(AppConstants.padding)
        .glassCard()
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
    }

    private var tryOnDressCard: some View {
        NavigationLink(destination: TryOnDressView()) {
            HStack(spacing: 16) {
                Image(systemName: "figure.dress.line.vertical.figure")
                    .font(.title)
                    .foregroundStyle(AppColors.accentGradient)
                    .frame(width: 52, height: 52)
                    .background(AppColors.surfaceGlass)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Try on a dress")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Virtual try-on — see how it looks on you")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(AppConstants.padding)
            .glassCard()
        }
        .buttonStyle(.plain)
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 15)
    }

    private var quickActions: some View {
        HStack(spacing: 14) {
            NavigationLink(destination: ClothingUploadView()) {
                actionCard(icon: "plus.circle.fill", title: "Add Clothing", color: AppColors.accentTeal)
            }

            NavigationLink(destination: ClothingGalleryView()) {
                actionCard(icon: "rectangle.grid.2x2.fill", title: "My Wardrobe", color: AppColors.accentPink)
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 15)
    }

    private func actionCard(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .glassCard()
    }

    private var recentClothing: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Items")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                NavigationLink(destination: ClothingGalleryView()) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(AppColors.accentTeal)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(recentItemsSortedWithDressesFirst) { item in
                        NavigationLink(destination: TryOnView(clothing: item)) {
                            VStack(spacing: 8) {
                                if let image = item.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 120)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.surfaceGlass)
                                        .frame(width: 100, height: 120)
                                        .overlay(
                                            Image(systemName: item.category.icon)
                                                .foregroundColor(AppColors.textMuted)
                                        )
                                }
                                Text(item.name)
                                    .font(.caption2)
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineLimit(1)
                                    .frame(width: 100)
                            }
                        }
                    }
                }
            }
        }
        .opacity(animateCards ? 1 : 0)
    }

    private var recentItemsSortedWithDressesFirst: [ClothingItem] {
        let sorted = clothingVM.clothingItems.sorted { a, b in
            if a.category == .dress && b.category != .dress { return true }
            if a.category != .dress && b.category == .dress { return false }
            return a.dateAdded > b.dateAdded
        }
        return Array(sorted.suffix(5))
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var apiToken: String = UserDefaults.standard.string(forKey: "hf_api_token") ?? ""
    @State private var showResetAlert = false
    @AppStorage("tryOnMode") private var tryOnModeRaw: String = TryOnMode.cloud.rawValue

    private var tryOnMode: TryOnMode {
        TryOnMode(rawValue: tryOnModeRaw) ?? .cloud
    }

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Try-On Mode
                    AnimatedCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Try-On Mode", systemImage: "sparkles.tv")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text(tryOnMode.description)
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)

                            Picker("Try-On Mode", selection: $tryOnModeRaw) {
                                ForEach(TryOnMode.allCases) { mode in
                                    Text(mode.rawValue)
                                        .tag(mode.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    // API Token
                    AnimatedCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Hugging Face API Token", systemImage: "key.fill")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Required for virtual try-on feature. Get a free token at huggingface.co/settings/tokens")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)

                            SecureField("hf_...", text: $apiToken)
                                .font(.body)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(12)
                                .background(AppColors.surfaceGlass)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            Button(action: {
                                UserDefaults.standard.set(apiToken, forKey: "hf_api_token")
                            }) {
                                Text("Save Token")
                                    .primaryButton()
                            }
                        }
                    }

                    // Reset profile
                    AnimatedCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Reset Profile", systemImage: "arrow.counterclockwise")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Start fresh with a new body profile and questionnaire")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)

                            Button(action: { showResetAlert = true }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Reset Everything")
                                }
                                .font(.headline)
                                .foregroundColor(AppColors.danger)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: AppConstants.buttonCornerRadius)
                                        .stroke(AppColors.danger, lineWidth: 1.5)
                                )
                            }
                        }
                    }

                    // About
                    AnimatedCard {
                        VStack(spacing: 8) {
                            Image(systemName: "figure.dress.line.vertical.figure")
                                .font(.largeTitle)
                                .foregroundStyle(AppColors.accentGradient)

                            Text("BodyFit MVP")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Version 1.0")
                                .font(.caption)
                                .foregroundColor(AppColors.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(AppConstants.padding)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset Profile?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) {
                UserDefaults.standard.removeObject(forKey: BodyProfile.storageKey)
                UserDefaults.standard.removeObject(forKey: "clothing_items")
                hasCompletedOnboarding = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete your body profile and all saved clothing items. This cannot be undone.")
        }
    }
}
