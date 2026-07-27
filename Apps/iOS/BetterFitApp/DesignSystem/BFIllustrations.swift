import SwiftUI

// MARK: - BetterFit Mark Mascot

enum EmberMood: Equatable {
    case ready
    case proud
    case resting
}

/// BetterFit identity moment. Per the design system, the brand mark combines
/// three compressed oval forms (plates on a barbell, repetition, forward
/// momentum) rendered in identity yellow with black content for contrast.
/// Reserved for greeting, profile identity and active-session celebration.
struct EmberMascot: View {
    let mood: EmberMood
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(BFColors.identitySurface)

            BetterFitMark(size: size * 0.78)
                .foregroundStyle(BFColors.identity)

            EmberFace(mood: mood, size: size * 0.78)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// Three compressed oval forms stacked vertically, mirroring the
/// BetterFit brand mark. Yellow identity field, black ink for overlays.
private struct BetterFitMark: View {
    let size: CGFloat

    var body: some View {
        VStack(spacing: size * 0.06) {
            Capsule()
                .fill(BFColors.identity)
                .frame(width: size * 0.96, height: size * 0.16)

            Capsule()
                .fill(BFColors.identity)
                .frame(width: size, height: size * 0.18)

            Capsule()
                .fill(BFColors.identity)
                .frame(width: size * 0.96, height: size * 0.16)
        }
    }
}

private struct EmberFace: View {
    let mood: EmberMood
    let size: CGFloat

    var body: some View {
        VStack(spacing: size * 0.10) {
            HStack(spacing: size * 0.22) {
                EmberEye(isResting: mood == .resting, size: size)
                EmberEye(isResting: mood == .resting, size: size)
            }

            switch mood {
            case .ready:
                Capsule()
                    .fill(BFColors.identityInk)
                    .frame(width: size * 0.26, height: size * 0.10)
            case .proud:
                Capsule()
                    .fill(BFColors.identityInk)
                    .frame(width: size * 0.42, height: size * 0.10)
            case .resting:
                Capsule()
                    .fill(BFColors.identityInk.opacity(0.6))
                    .frame(width: size * 0.14, height: size * 0.045)
            }
        }
    }
}

private struct EmberEye: View {
    let isResting: Bool
    let size: CGFloat

    var body: some View {
        Group {
            if isResting {
                Capsule()
                    .fill(BFColors.identityInk)
                    .frame(width: size * 0.14, height: size * 0.045)
            } else {
                Capsule()
                    .fill(BFColors.identityInk)
                    .frame(width: size * 0.14, height: size * 0.10)
            }
        }
    }
}

// MARK: - Body Map

struct BodyMapCompanion: View {
    let recovery: Double
    var size: CGFloat = 56

    private var tint: Color {
        switch recovery {
        case 0..<35: BFColors.danger
        case 35..<70: BFColors.warning
        default: BFColors.success
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.12))

            bodyFigure

            Circle()
                .fill(tint)
                .frame(width: size * 0.13, height: size * 0.13)
                .overlay(Circle().stroke(Color.white.opacity(0.45), lineWidth: 1))
                .offset(x: size * 0.17, y: -size * 0.03)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Body recovery")
        .accessibilityValue("\(Int(recovery)) percent")
    }

    private var bodyFigure: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.84))
                .frame(width: size * 0.17, height: size * 0.17)
                .offset(y: -size * 0.28)

            Capsule()
                .fill(Color.white.opacity(0.78))
                .frame(width: size * 0.22, height: size * 0.36)
                .offset(y: -size * 0.02)

            limb(
                width: size * 0.09,
                height: size * 0.34,
                rotation: 24,
                xOffsetFactor: -0.15,
                yOffsetFactor: -0.01
            )
            limb(
                width: size * 0.09,
                height: size * 0.34,
                rotation: -24,
                xOffsetFactor: 0.15,
                yOffsetFactor: -0.01
            )
            limb(
                width: size * 0.10,
                height: size * 0.34,
                rotation: 12,
                xOffsetFactor: -0.07,
                yOffsetFactor: 0.26
            )
            limb(
                width: size * 0.10,
                height: size * 0.34,
                rotation: -12,
                xOffsetFactor: 0.07,
                yOffsetFactor: 0.26
            )
        }
    }

    private func limb(
        width: CGFloat,
        height: CGFloat,
        rotation: Double,
        xOffsetFactor: CGFloat,
        yOffsetFactor: CGFloat
    ) -> some View {
        Capsule()
            .fill(Color.white.opacity(0.68))
            .frame(width: width, height: height)
            .rotationEffect(.degrees(rotation))
            .offset(x: size * xOffsetFactor, y: size * yOffsetFactor)
    }
}

// MARK: - Athlete

enum AthletePose {
    case push
    case pull
    case legs
    case cardio

    static func from(workoutName: String) -> AthletePose {
        let name = workoutName.lowercased()
        if name.contains("push") || name.contains("chest") { return .push }
        if name.contains("pull") || name.contains("back") { return .pull }
        if name.contains("leg") || name.contains("squat") { return .legs }
        return .cardio
    }
}

/// Workout card hero artwork. Stays on the ember product accent because
/// workout cards are ordinary product UI, not identity moments.
struct AthleteIllustration: View {
    let pose: AthletePose
    var accent: Color = BFColors.brandAccent

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [accent.opacity(0.30), accent.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(accent.opacity(0.16))
                .frame(width: 92, height: 92)
                .offset(x: 30, y: -40)

            Canvas { context, size in
                drawAthlete(context: &context, size: size)
            }
            .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: BFRadius.card, style: .continuous))
        .accessibilityHidden(true)
    }

    private func drawAthlete(context: inout GraphicsContext, size: CGSize) {
        let color = Color.white.opacity(0.92)
        let width = max(4, size.width * 0.055)
        let style = StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)

        context.fill(
            Path(ellipseIn: CGRect(x: size.width * 0.45, y: size.height * 0.12, width: 15, height: 15)),
            with: .color(color)
        )

        for segment in segments(in: size) {
            var path = Path()
            path.move(to: segment.0)
            path.addLine(to: segment.1)
            context.stroke(path, with: .color(color), style: style)
        }

        if pose == .push {
            var bar = Path()
            bar.move(to: point(0.15, 0.37, in: size))
            bar.addLine(to: point(0.88, 0.37, in: size))
            context.stroke(bar, with: .color(accent), style: StrokeStyle(lineWidth: width * 0.55, lineCap: .round))
        }
    }

    private func segments(in size: CGSize) -> [(CGPoint, CGPoint)] {
        switch pose {
        case .push:
            return [
                (point(0.50, 0.25, in: size), point(0.50, 0.62, in: size)),
                (point(0.50, 0.34, in: size), point(0.26, 0.48, in: size)),
                (point(0.26, 0.48, in: size), point(0.22, 0.37, in: size)),
                (point(0.50, 0.34, in: size), point(0.74, 0.48, in: size)),
                (point(0.74, 0.48, in: size), point(0.78, 0.37, in: size)),
                (point(0.50, 0.62, in: size), point(0.34, 0.88, in: size)),
                (point(0.50, 0.62, in: size), point(0.68, 0.88, in: size))
            ]
        case .pull:
            return [
                (point(0.48, 0.26, in: size), point(0.56, 0.60, in: size)),
                (point(0.52, 0.37, in: size), point(0.28, 0.53, in: size)),
                (point(0.28, 0.53, in: size), point(0.17, 0.72, in: size)),
                (point(0.52, 0.37, in: size), point(0.76, 0.50, in: size)),
                (point(0.76, 0.50, in: size), point(0.86, 0.68, in: size)),
                (point(0.56, 0.60, in: size), point(0.37, 0.88, in: size)),
                (point(0.56, 0.60, in: size), point(0.72, 0.88, in: size))
            ]
        case .legs:
            return [
                (point(0.50, 0.26, in: size), point(0.50, 0.57, in: size)),
                (point(0.50, 0.36, in: size), point(0.27, 0.48, in: size)),
                (point(0.50, 0.36, in: size), point(0.73, 0.48, in: size)),
                (point(0.50, 0.57, in: size), point(0.28, 0.68, in: size)),
                (point(0.28, 0.68, in: size), point(0.18, 0.88, in: size)),
                (point(0.50, 0.57, in: size), point(0.72, 0.68, in: size)),
                (point(0.72, 0.68, in: size), point(0.82, 0.88, in: size))
            ]
        case .cardio:
            return [
                (point(0.50, 0.25, in: size), point(0.46, 0.58, in: size)),
                (point(0.48, 0.36, in: size), point(0.25, 0.48, in: size)),
                (point(0.48, 0.36, in: size), point(0.70, 0.25, in: size)),
                (point(0.46, 0.58, in: size), point(0.25, 0.82, in: size)),
                (point(0.46, 0.58, in: size), point(0.74, 0.73, in: size)),
                (point(0.74, 0.73, in: size), point(0.86, 0.88, in: size))
            ]
        }
    }

    private func point(_ horizontal: CGFloat, _ vertical: CGFloat, in size: CGSize) -> CGPoint {
        CGPoint(x: size.width * horizontal, y: size.height * vertical)
    }
}
