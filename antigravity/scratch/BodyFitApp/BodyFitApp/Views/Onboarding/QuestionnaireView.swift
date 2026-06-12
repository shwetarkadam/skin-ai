import SwiftUI

struct QuestionnaireView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @State private var navigateToPhoto = false

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                progressBar

                // Step header
                stepHeader

                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        stepContent
                    }
                    .padding(AppConstants.padding)
                }

                // Navigation buttons
                navigationButtons
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToPhoto) {
            PhotoCaptureView()
        }
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.surfaceGlass)
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.accentGradient)
                    .frame(width: geo.size.width * onboardingVM.progress, height: 6)
                    .animation(.easeInOut(duration: 0.3), value: onboardingVM.progress)
            }
        }
        .frame(height: 6)
        .padding(.horizontal, AppConstants.padding)
        .padding(.top, 12)
    }

    // MARK: - Step Header
    private var stepHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: onboardingVM.currentStep.icon)
                .font(.title)
                .foregroundStyle(AppColors.accentGradient)
                .frame(width: 56, height: 56)
                .background(AppColors.surfaceGlass)
                .clipShape(Circle())

            Text(onboardingVM.currentStep.title)
                .font(.title2.weight(.bold))
                .foregroundColor(AppColors.textPrimary)

            Text(onboardingVM.currentStep.subtitle)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    // MARK: - Step Content
    @ViewBuilder
    private var stepContent: some View {
        switch onboardingVM.currentStep {
        case .basicInfo:
            basicInfoStep
        case .measurements:
            measurementsStep
        case .concerns:
            concernsStep
        case .fitPreference:
            fitPreferenceStep
        case .problemAreas:
            problemAreasStep
        }
    }

    // MARK: - Step 1: Basic Info
    private var basicInfoStep: some View {
        AnimatedCard {
            VStack(spacing: 16) {
                MeasurementInput(label: "Height", unit: "cm", icon: "arrow.up.and.down", value: $onboardingVM.heightText, placeholder: "165")
                Divider().background(AppColors.textMuted)
                MeasurementInput(label: "Weight", unit: "kg", icon: "scalemass.fill", value: $onboardingVM.weightText, placeholder: "65")
                Divider().background(AppColors.textMuted)
                MeasurementInput(label: "Age", unit: "years", icon: "calendar", value: $onboardingVM.ageText, placeholder: "25")
            }
        }
    }

    // MARK: - Step 2: Measurements
    private var measurementsStep: some View {
        VStack(spacing: 16) {
            AnimatedCard {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(AppColors.accentTeal)
                        Text("How to measure")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                    }
                    Text("Use a flexible tape measure. Wrap it around the fullest part of each area, keeping it level and snug but not tight.")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            AnimatedCard {
                VStack(spacing: 16) {
                    MeasurementInput(label: "Bust", unit: "cm", icon: "circle.bottomhalf.filled", value: $onboardingVM.bustText, placeholder: "90")
                    Divider().background(AppColors.textMuted)
                    MeasurementInput(label: "Waist", unit: "cm", icon: "rectangle.compress.vertical", value: $onboardingVM.waistText, placeholder: "72")
                    Divider().background(AppColors.textMuted)
                    MeasurementInput(label: "Hips", unit: "cm", icon: "triangle.fill", value: $onboardingVM.hipText, placeholder: "96")
                    Divider().background(AppColors.textMuted)
                    MeasurementInput(label: "Shoulders", unit: "cm (optional)", icon: "arrow.left.and.right", value: $onboardingVM.shoulderText, placeholder: "40")
                }
            }
        }
    }

    // MARK: - Step 3: Body Concerns
    private var concernsStep: some View {
        AnimatedCard {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(BodyConcern.allCases) { concern in
                    ConcernChip(
                        concern: concern,
                        isSelected: onboardingVM.selectedConcerns.contains(concern),
                        action: { onboardingVM.toggleConcern(concern) }
                    )
                }
            }
        }
    }

    // MARK: - Step 4: Fit Preference
    private var fitPreferenceStep: some View {
        VStack(spacing: 12) {
            ForEach(FitPreference.allCases) { preference in
                AnimatedCard {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            onboardingVM.fitPreference = preference
                        }
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: preference.icon)
                                .font(.title2)
                                .foregroundStyle(
                                    onboardingVM.fitPreference == preference ?
                                    AnyShapeStyle(AppColors.accentGradient) :
                                    AnyShapeStyle(AppColors.textMuted)
                                )
                                .frame(width: 44, height: 44)
                                .background(
                                    onboardingVM.fitPreference == preference ?
                                    AppColors.accentTeal.opacity(0.15) :
                                    AppColors.surfaceGlass
                                )
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(preference.rawValue)
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                Text(preference.description)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            if onboardingVM.fitPreference == preference {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(AppColors.accentTeal)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 5: Problem Areas
    private var problemAreasStep: some View {
        AnimatedCard {
            VStack(spacing: 12) {
                ForEach(ProblemArea.allCases) { area in
                    Button(action: { onboardingVM.toggleProblemArea(area) }) {
                        HStack(spacing: 14) {
                            Image(systemName: area.icon)
                                .font(.title3)
                                .foregroundStyle(
                                    onboardingVM.selectedProblemAreas.contains(area) ?
                                    AnyShapeStyle(AppColors.accentGradient) :
                                    AnyShapeStyle(AppColors.textMuted)
                                )
                                .frame(width: 36, height: 36)
                                .background(
                                    onboardingVM.selectedProblemAreas.contains(area) ?
                                    AppColors.accentTeal.opacity(0.15) :
                                    AppColors.surfaceGlass
                                )
                                .clipShape(Circle())

                            Text(area.rawValue)
                                .font(.subheadline)
                                .foregroundColor(
                                    onboardingVM.selectedProblemAreas.contains(area) ?
                                    AppColors.textPrimary : AppColors.textSecondary
                                )

                            Spacer()

                            if onboardingVM.selectedProblemAreas.contains(area) {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(AppColors.accentTeal)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if onboardingVM.currentStep.rawValue > 0 {
                Button(action: { onboardingVM.previousStep() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .secondaryButton()
                }
            }

            Button(action: {
                if onboardingVM.currentStep == .problemAreas {
                    navigateToPhoto = true
                } else {
                    onboardingVM.nextStep()
                }
            }) {
                HStack {
                    Text(onboardingVM.currentStep == .problemAreas ? "Continue" : "Next")
                    Image(systemName: "chevron.right")
                }
                .primaryButton()
            }
            .disabled(!onboardingVM.canProceed)
            .opacity(onboardingVM.canProceed ? 1 : 0.5)
        }
        .padding(AppConstants.padding)
        .background(AppColors.surfaceDark.opacity(0.95))
    }
}

// MARK: - Concern Chip
struct ConcernChip: View {
    let concern: BodyConcern
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: concern.icon)
                    .font(.title3)
                    .foregroundStyle(
                        isSelected ? AnyShapeStyle(AppColors.accentGradient) : AnyShapeStyle(AppColors.textMuted)
                    )
                Text(concern.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppColors.accentTeal.opacity(0.12) : AppColors.surfaceGlass)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? AppColors.accentTeal.opacity(0.4) : Color.clear, lineWidth: 1)
                    )
            )
        }
    }
}
