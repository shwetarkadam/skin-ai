import SwiftUI

struct PhotoCaptureView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var bodyAnalysisVM: BodyAnalysisViewModel
    @State private var showImagePicker = false
    @State private var navigateToProfile = false
    @State private var selectedImage: UIImage?
    @State private var showPhotoGuidelines = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.title)
                        .foregroundStyle(AppColors.accentGradient)
                        .frame(width: 56, height: 56)
                        .background(AppColors.surfaceGlass)
                        .clipShape(Circle())

                    Text("Body Photo (Optional)")
                        .font(.title2.weight(.bold))
                        .foregroundColor(AppColors.textPrimary)

                    Text("Upload a full-body photo to refine your body shape analysis. This improves accuracy significantly.")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: { showPhotoGuidelines = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle")
                            Text("Tips for best results")
                                .font(.caption)
                        }
                        .foregroundColor(AppColors.accentTeal)
                    }
                    .padding(.top, 4)
                }
                .padding(.top, 20)
                .sheet(isPresented: $showPhotoGuidelines) {
                    BodyPhotoGuidelinesSheet()
                }

                Spacer()

                // Photo area
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 350)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                .stroke(AppColors.accentTeal.opacity(0.4), lineWidth: 2)
                        )
                        .shadow(color: AppColors.accentTeal.opacity(0.2), radius: 15)
                        .padding(.horizontal)

                    if bodyAnalysisVM.isAnalyzing {
                        HStack(spacing: 10) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentTeal))
                            Text("Analyzing body proportions...")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding()
                    }
                } else {
                    // Upload area
                    Button(action: { showImagePicker = true }) {
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.rectangle.badge.plus")
                                .font(.system(size: 48))
                                .foregroundStyle(AppColors.accentGradient)

                            Text("Tap to upload a full-body photo")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Stand straight, arms slightly away from body")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .background(
                            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
                                .foregroundColor(AppColors.accentTeal.opacity(0.4))
                        )
                        .background(AppColors.surfaceGlass.clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius)))
                        .padding(.horizontal)
                    }
                }

                if let error = bodyAnalysisVM.analysisError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(AppColors.danger)
                        .padding(.horizontal)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    if selectedImage != nil {
                        Button(action: { showImagePicker = true }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Choose Different Photo")
                            }
                            .secondaryButton()
                        }
                    }

                    Button(action: {
                        completeSetup()
                    }) {
                        HStack {
                            Text(selectedImage != nil ? "Complete Setup" : "Skip for Now")
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .primaryButton()
                    }
                    .disabled(bodyAnalysisVM.isAnalyzing)
                }
                .padding(.horizontal, AppConstants.padding)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                bodyAnalysisVM.bodyImage = image
                Task {
                    await bodyAnalysisVM.analyzePhoto()
                }
            }
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            BodyProfileView()
                .navigationBarBackButtonHidden(true)
        }
    }

    private func completeSetup() {
        // Save photo if available
        if let image = selectedImage {
            onboardingVM.profile.bodyPhotoPath = bodyAnalysisVM.saveBodyPhoto(image)
        }

        // Complete onboarding with classification
        onboardingVM.completeOnboarding()

        // Refine with vision data if available
        if bodyAnalysisVM.proportions != nil {
            bodyAnalysisVM.refineClassification(profile: &onboardingVM.profile)
        }

        hasCompletedOnboarding = true
    }
}
