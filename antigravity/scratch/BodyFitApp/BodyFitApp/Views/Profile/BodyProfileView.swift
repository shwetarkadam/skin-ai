import SwiftUI

struct BodyProfileView: View {
    @State private var profile: BodyProfile = BodyProfile.load() ?? BodyProfile()
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Shape result
                    if let shape = profile.detectedShape {
                        ShapeVisualizer(shape: shape, confidence: profile.shapeConfidence)
                            .padding(.top, 20)

                        // Description
                        AnimatedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("About Your Shape", systemImage: "info.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                Text(shape.description)
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineSpacing(4)
                            }
                        }
                    }

                    if profile.visionPoseSource != nil {
                        AnimatedCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Label("From your photo", systemImage: "figure.stand")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                if let source = profile.visionPoseSource {
                                    Text(source)
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                if let h = profile.visionBodyHeightMeters, h > 0 {
                                    measurementRow("Estimated height (pose)", String(format: "%.2f m", h))
                                }

                                if let sh = profile.visionShoulderToHipRatio, sh > 0 {
                                    measurementRow("Shoulder / hip span", String(format: "%.2f", sh))
                                }
                                if let wh = profile.visionWaistToHipRatio, wh > 0 {
                                    measurementRow("Waist / hip span", String(format: "%.2f", wh))
                                }
                                if let bh = profile.visionBustToHipRatio, bh > 0 {
                                    measurementRow("Upper torso / hip span", String(format: "%.2f", bh))
                                }

                                Text("Ratios come from on-device Apple Vision pose; body shape also uses your tape measurements when confidence is low.")
                                    .font(.caption2)
                                    .foregroundColor(AppColors.textMuted)
                                    .padding(.top, 4)
                            }
                        }
                    }

                    // Measurements summary
                    AnimatedCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Your Measurements", systemImage: "ruler.fill")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            measurementRow("Height", "\(Int(profile.height)) cm")
                            measurementRow("Weight", "\(Int(profile.weight)) kg")
                            measurementRow("Bust", "\(Int(profile.bustCircumference)) cm")
                            measurementRow("Waist", "\(Int(profile.waistCircumference)) cm")
                            measurementRow("Hips", "\(Int(profile.hipCircumference)) cm")
                            if profile.shoulderWidth > 0 {
                                measurementRow("Shoulders", "\(Int(profile.shoulderWidth)) cm")
                            }
                            measurementRow("BMI", String(format: "%.1f", profile.bmi))
                        }
                    }

                    // Styling tips
                    if let shape = profile.detectedShape {
                        AnimatedCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Label("Styling Tips", systemImage: "sparkles")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                ForEach(shape.stylingTips, id: \.self) { tip in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColors.accentTeal)
                                            .font(.caption)
                                            .padding(.top, 3)
                                        Text(tip)
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                        }
                    }

                    // Body concerns
                    if !profile.concerns.isEmpty {
                        AnimatedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Your Concerns", systemImage: "heart.text.square.fill")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                FlowLayout(spacing: 8) {
                                    ForEach(profile.concerns) { concern in
                                        HStack(spacing: 6) {
                                            Image(systemName: concern.icon)
                                                .font(.caption)
                                            Text(concern.rawValue)
                                                .font(.caption)
                                        }
                                        .foregroundColor(AppColors.accentPink)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppColors.accentPink.opacity(0.12))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(AppConstants.padding)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Body Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func measurementRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: .init(width: bounds.width, height: bounds.height), subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxHeight = max(maxHeight, y + rowHeight)
        }

        return (CGSize(width: maxWidth, height: maxHeight), positions)
    }
}
