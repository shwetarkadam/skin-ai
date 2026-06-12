import SwiftUI

struct ClothingUploadView: View {
    @EnvironmentObject var clothingVM: ClothingViewModel
    @State private var showImagePicker = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Photo area
                    if let image = clothingVM.clothingImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                    .stroke(AppColors.accentTeal.opacity(0.3), lineWidth: 1.5)
                            )
                            .shadow(color: AppColors.accentTeal.opacity(0.15), radius: 10)

                        Button(action: { showImagePicker = true }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Change Photo")
                            }
                            .font(.subheadline)
                            .foregroundColor(AppColors.accentTeal)
                        }
                    } else {
                        Button(action: { showImagePicker = true }) {
                            VStack(spacing: 16) {
                                Image(systemName: "tshirt.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(AppColors.accentGradient)

                                Text("Upload Clothing Photo")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                Text("Take a photo or choose from your gallery")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 220)
                            .background(
                                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
                                    .foregroundColor(AppColors.accentTeal.opacity(0.4))
                            )
                            .background(AppColors.surfaceGlass.clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius)))
                        }
                    }

                    // Name input
                    AnimatedCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Item Name (Optional)")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)

                            TextField("e.g., Blue Floral Dress", text: $clothingVM.clothingName)
                                .font(.body)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(12)
                                .background(AppColors.surfaceGlass)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    // Category selection
                    AnimatedCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(ClothingCategory.allCases) { category in
                                    Button(action: {
                                        withAnimation { clothingVM.selectedCategory = category }
                                    }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: category.icon)
                                                .font(.title3)
                                            Text(category.rawValue)
                                                .font(.caption)
                                        }
                                        .foregroundColor(
                                            clothingVM.selectedCategory == category ?
                                            AppColors.accentTeal : AppColors.textMuted
                                        )
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(
                                                    clothingVM.selectedCategory == category ?
                                                    AppColors.accentTeal.opacity(0.12) : AppColors.surfaceGlass
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(
                                                            clothingVM.selectedCategory == category ?
                                                            AppColors.accentTeal.opacity(0.4) : Color.clear,
                                                            lineWidth: 1
                                                        )
                                                )
                                        )
                                    }
                                }
                            }
                        }
                    }

                    // Size selection
                    AnimatedCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Size (Optional)")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                            Text("Helps us recommend fit and compare with your measurements")
                                .font(.caption2)
                                .foregroundColor(AppColors.textMuted)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 10) {
                                ForEach(GarmentSize.allCases) { gs in
                                    Button(action: {
                                        withAnimation {
                                            clothingVM.selectedSize = clothingVM.selectedSize == gs.rawValue ? nil : gs.rawValue
                                        }
                                    }) {
                                        Text(gs.rawValue)
                                            .font(.caption.weight(.medium))
                                            .foregroundColor(
                                                clothingVM.selectedSize == gs.rawValue ? .black : AppColors.textSecondary
                                            )
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(
                                                        clothingVM.selectedSize == gs.rawValue ?
                                                        AppColors.accentTeal : AppColors.surfaceGlass
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                    }

                    // Add button
                    if clothingVM.clothingImage != nil {
                        Button(action: {
                            clothingVM.addClothing()
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add to Wardrobe")
                            }
                            .primaryButton()
                        }
                    }
                }
                .padding(AppConstants.padding)
            }
        }
        .navigationTitle("Add Clothing")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(image: $clothingVM.clothingImage)
        }
    }
}

struct ClothingGalleryView: View {
    @EnvironmentObject var clothingVM: ClothingViewModel
    @State private var showAddClothing = false

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            if clothingVM.clothingItems.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(clothingVM.clothingItemsSortedWithDressesFirst) { item in
                            NavigationLink(destination: TryOnView(clothing: item)) {
                                ClothingCard(item: item)
                            }
                        }
                    }
                    .padding(AppConstants.padding)
                }
            }
        }
        .navigationTitle("My Wardrobe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: ClothingUploadView()) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.accentGradient)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "tshirt.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.accentGradient)
                .opacity(0.5)

            Text("Your Wardrobe is Empty")
                .font(.title3.weight(.semibold))
                .foregroundColor(AppColors.textPrimary)

            Text("Add clothing items to see how they'll look on you")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            NavigationLink(destination: ClothingUploadView()) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Your First Item")
                }
                .primaryButton()
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

// MARK: - Try On a Dress (virtual try-on flow)
struct TryOnDressView: View {
    @EnvironmentObject var clothingVM: ClothingViewModel

    private var dresses: [ClothingItem] {
        clothingVM.clothingItems.filter { $0.category == .dress }
    }

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            if dresses.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Pick a dress to see virtual try-on")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(dresses) { item in
                                NavigationLink(destination: TryOnView(clothing: item)) {
                                    VStack(spacing: 0) {
                                        if let image = item.image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 200)
                                                .clipped()
                                        } else {
                                            Rectangle()
                                                .fill(AppColors.surfaceGlass)
                                                .frame(height: 200)
                                                .overlay(
                                                    Image(systemName: "figure.dress.line.vertical.figure")
                                                        .font(.largeTitle)
                                                        .foregroundColor(AppColors.textMuted)
                                                )
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(.caption.weight(.semibold))
                                                .foregroundColor(AppColors.textPrimary)
                                                .lineLimit(1)
                                            Text("Tap for virtual try-on")
                                                .font(.caption2)
                                                .foregroundColor(AppColors.accentTeal)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(10)
                                        .background(AppColors.surfaceCard)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .padding(AppConstants.padding)
                }
            }
        }
        .navigationTitle("Try on a dress")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: AddDressView()) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.accentGradient)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.dress.line.vertical.figure")
                .font(.system(size: 56))
                .foregroundStyle(AppColors.accentGradient)
                .opacity(0.8)

            Text("No dresses yet")
                .font(.title3.weight(.semibold))
                .foregroundColor(AppColors.textPrimary)

            Text("Add a dress to see how it will look on you with virtual try-on")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            NavigationLink(destination: AddDressView()) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add a dress")
                }
                .primaryButton()
            }
            .padding(.horizontal, 40)
        }
    }
}

/// Opens Add Clothing with category pre-set to Dress so user adds a dress, then can try it on.
struct AddDressView: View {
    @EnvironmentObject var clothingVM: ClothingViewModel

    var body: some View {
        ClothingUploadView()
            .onAppear { clothingVM.selectedCategory = .dress }
    }
}

struct ClothingCard: View {
    let item: ClothingItem

    var body: some View {
        VStack(spacing: 0) {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
            } else {
                Rectangle()
                    .fill(AppColors.surfaceGlass)
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: item.category.icon)
                            .font(.largeTitle)
                            .foregroundColor(AppColors.textMuted)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(item.category.rawValue)
                        .font(.caption2)
                        .foregroundColor(AppColors.textMuted)
                    if let size = item.size, !size.isEmpty {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(AppColors.textMuted)
                        Text(size)
                            .font(.caption2)
                            .foregroundColor(AppColors.textMuted)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(AppColors.surfaceCard)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
