import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct TryOnView: View {
    let clothing: ClothingItem
    @EnvironmentObject var tryOnVM: TryOnViewModel
    @EnvironmentObject var clothingVM: ClothingViewModel
    @State private var profile: BodyProfile = BodyProfile.load() ?? BodyProfile()
    /// Use current item from VM so saved try-on result appears immediately after save.
    private var currentClothing: ClothingItem {
        clothingVM.clothingItems.first(where: { $0.id == clothing.id }) ?? clothing
    }
    @State private var bodyImage: UIImage?
    @State private var showBodyPicker = false
    @State private var showPhotoGuidelines = false
    @AppStorage("tryOnMode") private var tryOnModeRaw: String = TryOnMode.cloud.rawValue

    private var tryOnMode: TryOnMode {
        TryOnMode(rawValue: tryOnModeRaw) ?? .cloud
    }

    private static let ciContext = CIContext()

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Clothing preview
                    clothingPreview

                    // Fit recommendation
                    if let rec = tryOnVM.recommendation {
                        fitRecommendationCard(rec)
                    } else {
                        // Generate recommendation on appear
                        Color.clear.onAppear {
                            tryOnVM.generateFitRecommendation(profile: profile, clothing: clothing)
                        }
                    }

                    // Last saved try-on (if any)
                    if let savedResult = currentClothing.lastTryOnImage, tryOnVM.tryOnResult == nil {
                        VStack(spacing: 8) {
                            Text("Last saved try-on")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textMuted)
                            Image(uiImage: savedResult)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                        .stroke(AppColors.surfaceGlass, lineWidth: 1)
                                )
                        }
                    }

                    // Virtual Try-On section
                    virtualTryOnSection

                    // Try-on result
                    if let result = tryOnVM.tryOnResult {
                        // For cloud mode, show a stylized outline/diagram version of the result image
                        let displayImage: UIImage = {
                            if tryOnMode == .cloud, let outlined = outlineImage(from: result) {
                                return outlined
                            }
                            return result
                        }()
                        VStack(spacing: 12) {
                            Text("✨ Virtual Try-On Result")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Image(uiImage: displayImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 400)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                        .stroke(AppColors.accentTeal.opacity(0.3), lineWidth: 2)
                                )
                                .shadow(color: AppColors.accentTeal.opacity(0.3), radius: 20)

                            Button(action: {
                                _ = clothingVM.saveTryOnResult(for: currentClothing, image: result)
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down.fill")
                                    Text("Save Result")
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(AppColors.accentTeal)
                            }
                        }
                    }

                    if let error = tryOnVM.errorMessage {
                        VStack(spacing: 12) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppColors.warning)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(AppColors.warning)
                            }
                            Button(action: {
                                tryOnVM.clearError()
                                Task { await startTryOn() }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Retry")
                                }
                                .font(.caption.weight(.medium))
                                .foregroundColor(AppColors.accentTeal)
                            }
                        }
                        .padding()
                        .glassCard()
                    }
                }
                .padding(AppConstants.padding)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Try On")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBodyPicker) {
            PhotoPicker(image: $bodyImage)
        }
        .alert("Hugging Face API Token", isPresented: $tryOnVM.showTokenAlert) {
            TextField("hf_...", text: $tryOnVM.apiToken)
            Button("Save") { tryOnVM.saveToken() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your free Hugging Face API token to enable virtual try-on. Get one at huggingface.co/settings/tokens")
        }
        .onDisappear {
            tryOnVM.clearResult()
        }
    }

    private var clothingPreview: some View {
        VStack(spacing: 12) {
            if let image = clothing.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
            }

            VStack(spacing: 4) {
                Text(clothing.name)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(AppColors.textPrimary)
                HStack(spacing: 6) {
                    Text(clothing.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textMuted)
                    if let size = clothing.size, !size.isEmpty {
                        Text("• Size \(size)")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textMuted)
                    }
                }
            }
        }
        .padding()
        .glassCard()
    }

    private func fitRecommendationCard(_ rec: FitRecommendation) -> some View {
        AnimatedCard {
            VStack(alignment: .leading, spacing: 16) {
                // Score header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fit Analysis")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Text(rec.fitLevel.rawValue)
                            .font(.subheadline)
                            .foregroundColor(fitLevelColor(rec.fitLevel))
                    }

                    Spacer()

                    // Score circle
                    ZStack {
                        Circle()
                            .stroke(AppColors.surfaceGlass, lineWidth: 4)
                            .frame(width: 56, height: 56)

                        Circle()
                            .trim(from: 0, to: CGFloat(rec.overallScore) / 10)
                            .stroke(fitLevelColor(rec.fitLevel), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 56, height: 56)
                            .rotationEffect(.degrees(-90))

                        Text("\(rec.overallScore)")
                            .font(.title3.weight(.bold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                Divider().background(AppColors.textMuted.opacity(0.3))

                // Tight areas
                if !rec.tightAreas.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("May Feel Tight", systemImage: "exclamationmark.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColors.warning)

                        ForEach(rec.tightAreas, id: \.self) { area in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(AppColors.warning)
                                Text(area)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                }

                // Loose areas
                if !rec.looseAreas.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("May Feel Loose", systemImage: "info.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColors.accentTeal)

                        ForEach(rec.looseAreas, id: \.self) { area in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(AppColors.accentTeal)
                                Text(area)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                }

                // Suggestions
                if !rec.suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Suggestions", systemImage: "lightbulb.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColors.accentTeal)

                        ForEach(rec.suggestions, id: \.self) { suggestion in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "sparkle")
                                    .font(.caption2)
                                    .foregroundColor(AppColors.accentTeal)
                                    .padding(.top, 2)
                                Text(suggestion)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                }

                // Size recommendation
                if let sizeAdvice = rec.sizeAdvice {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "ruler.fill")
                            .foregroundColor(AppColors.accentTeal)
                            .font(.caption)
                        Text(sizeAdvice)
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 4)
                }
                if let recSize = rec.recommendedSize, rec.sizeAdvice == nil {
                    Text("Recommended size for your measurements: \(recSize)")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                        .padding(.top, 4)
                }

                // Style advice
                Text(rec.styleAdvice)
                    .font(.caption)
                    .foregroundColor(AppColors.textMuted)
                    .padding(.top, 4)
            }
        }
    }

    private var virtualTryOnSection: some View {
        AnimatedCard {
            VStack(spacing: 16) {
                Label("Virtual Try-On", systemImage: "wand.and.stars")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Button(action: { showPhotoGuidelines = true }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Tips for best results")
                            .font(.caption)
                    }
                    .foregroundColor(AppColors.accentTeal)
                }
                .buttonStyle(.plain)

                if tryOnMode == .localOnly {
                    Text("Virtual try-on is turned off in Local Only mode. You still get full on-device fit analysis above.")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                } else if !tryOnVM.hasToken {
                    Text("Add your Hugging Face API token in Settings to enable virtual try-on. Fit analysis above works without it.")
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                if bodyImage != nil {
                    Text("Body photo selected ✓")
                        .font(.subheadline)
                        .foregroundColor(AppColors.success)
                } else if profile.bodyPhotoPath != nil {
                    Text("Using your profile photo")
                        .font(.subheadline)
                        .foregroundColor(AppColors.success)
                }

                HStack(spacing: 12) {
                    Button(action: { showBodyPicker = true }) {
                        HStack {
                            Image(systemName: "person.crop.rectangle")
                            Text(bodyImage != nil ? "Change" : "Select Photo")
                        }
                        .secondaryButton()
                    }

                    if tryOnMode == .cloud {
                        Button(action: {
                            Task { await startTryOn() }
                        }) {
                            HStack {
                                if tryOnVM.isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Processing...")
                                } else {
                                    Image(systemName: "sparkles")
                                    Text("Try On")
                                }
                            }
                            .primaryButton()
                        }
                        .disabled(tryOnVM.isProcessing || (bodyImage == nil && profile.bodyPhotoPath == nil))
                        .opacity((bodyImage != nil || profile.bodyPhotoPath != nil) ? 1 : 0.5)
                    }
                }
            }
        }
        .sheet(isPresented: $showPhotoGuidelines) {
            BodyPhotoGuidelinesSheet()
        }
    }

    private func startTryOn() async {
        let body: UIImage
        if let selected = bodyImage {
            body = selected
        } else if let path = profile.bodyPhotoPath, let saved = UIImage(contentsOfFile: path) {
            body = saved
        } else {
            return
        }

        guard let clothImage = clothing.image else { return }
        await tryOnVM.generateTryOn(bodyImage: body, clothingImage: clothImage)
    }

    private func fitLevelColor(_ level: FitLevel) -> Color {
        switch level {
        case .perfect: return AppColors.success
        case .good: return AppColors.accentTeal
        case .moderate: return AppColors.warning
        case .challenging: return Color.orange
        case .poor: return AppColors.danger
        }
    }

    // MARK: - Outline / diagram filter
    private func outlineImage(from image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let edges = CIFilter.edges()
        edges.inputImage = ciImage
        edges.intensity = 3.0

        guard let edged = edges.outputImage else { return nil }

        let mono = CIFilter.colorMonochrome()
        mono.inputImage = edged
        mono.intensity = 1.0
        mono.color = CIColor(red: 0.9, green: 0.95, blue: 1.0)

        guard let output = mono.outputImage,
              let cgImage = Self.ciContext.createCGImage(output, from: output.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Body Photo Guidelines
struct BodyPhotoGuidelinesSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundGradient.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        guidelineRow(icon: "figure.stand", title: "Pose", text: "Stand straight, facing the camera. Arms slightly away from your body so the outline is clear.")
                        guidelineRow(icon: "sun.max.fill", title: "Lighting", text: "Use even lighting — avoid strong shadows or backlight. Indoor room light or overcast outdoor works best.")
                        guidelineRow(icon: "photo.fill", title: "Background", text: "Plain, uncluttered background helps the AI. Stand a few steps in front of a wall or door.")
                        guidelineRow(icon: "camera.fill", title: "Frame", text: "Full body in frame from head to ankles. Camera at waist height works well.")
                    }
                    .padding(AppConstants.padding)
                }
            }
            .navigationTitle("Tips for Best Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.accentTeal)
                }
            }
        }
    }

    private func guidelineRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.accentTeal)
                .frame(width: 44, height: 44)
                .background(AppColors.surfaceGlass)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text(text)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background(AppColors.surfaceGlass)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
    }
}
