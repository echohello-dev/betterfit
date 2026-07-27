import SwiftUI

// MARK: - Identity

/// Brand artwork for identity moments. This is deliberately not an avatar or mascot.
struct BetterFitIdentityBadge: View {
    var size: CGFloat = 64

    var body: some View {
        Image("IconCombo")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            .accessibilityHidden(true)
    }
}

// MARK: - Profile Avatar

/// Functional profile identity. Guests use the system person glyph; members use initials.
struct ProfileAvatar: View {
    let name: String
    let isGuest: Bool
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            Circle()
                .fill(BFColors.identitySurface)

            Circle()
                .stroke(BFColors.identity.opacity(0.45), lineWidth: 1)

            if isGuest {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(BFColors.identity)
            } else {
                Text(initials)
                    .font(.system(size: size * 0.30, weight: .black, design: .rounded))
                    .foregroundStyle(BFColors.identity)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel(isGuest ? "Guest profile" : "Profile for \(name)")
    }

    private var initials: String {
        let words = name.split(separator: " ").prefix(2)
        let value = words.compactMap(\.first).map(String.init).joined()
        return value.isEmpty ? "BF" : value.uppercased()
    }
}

// MARK: - Workout Movement

enum WorkoutMovementPose {
    case push
    case pull
    case legs
    case cardio

    static func from(workoutName: String) -> WorkoutMovementPose {
        let name = workoutName.lowercased()
        if name.contains("push") || name.contains("chest") { return .push }
        if name.contains("pull") || name.contains("back") { return .pull }
        if name.contains("leg") || name.contains("squat") { return .legs }
        return .cardio
    }
}

/// A shared articulated vector rig. Every workout pose uses the same head,
/// torso, limb weights, and joints; only joint positions and equipment change.
struct WorkoutMovementIllustration: View {
    @Environment(\.colorScheme) private var colorScheme

    let pose: WorkoutMovementPose
    var accent: Color = BFColors.brandAccent

    var body: some View {
        ZStack {
            BFColors.surfaceRaised(for: colorScheme)

            Circle()
                .fill(accent.opacity(0.16))
                .frame(width: 108, height: 108)
                .offset(x: 34, y: -44)

            Canvas { context, size in
                drawMovement(context: &context, size: size)
            }
            .padding(8)
        }
        .clipShape(RoundedRectangle(cornerRadius: BFRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BFRadius.card, style: .continuous)
                .stroke(accent.opacity(0.28), lineWidth: 1)
        }
        .accessibilityHidden(true)
    }

    private func drawMovement(context: inout GraphicsContext, size: CGSize) {
        let rig = rig(in: size)
        let bodyColor = Color.white.opacity(0.94)
        let limbWidth = max(9, size.width * 0.105)

        drawEquipment(context: &context, size: size, rig: rig)

        drawSegment(rig.leftShoulder, rig.leftElbow, width: limbWidth, color: bodyColor, context: &context)
        drawSegment(rig.leftElbow, rig.leftHand, width: limbWidth * 0.82, color: bodyColor, context: &context)
        drawSegment(rig.rightShoulder, rig.rightElbow, width: limbWidth, color: bodyColor, context: &context)
        drawSegment(rig.rightElbow, rig.rightHand, width: limbWidth * 0.82, color: bodyColor, context: &context)
        drawSegment(rig.leftHip, rig.leftKnee, width: limbWidth * 1.16, color: bodyColor, context: &context)
        drawSegment(rig.leftKnee, rig.leftFoot, width: limbWidth * 0.92, color: bodyColor, context: &context)
        drawSegment(rig.rightHip, rig.rightKnee, width: limbWidth * 1.16, color: bodyColor, context: &context)
        drawSegment(rig.rightKnee, rig.rightFoot, width: limbWidth * 0.92, color: bodyColor, context: &context)

        var torso = Path()
        torso.move(to: rig.leftShoulder)
        torso.addQuadCurve(to: rig.leftHip, control: midpoint(rig.leftShoulder, rig.leftHip, xOffset: -4))
        torso.addLine(to: rig.rightHip)
        torso.addQuadCurve(to: rig.rightShoulder, control: midpoint(rig.rightHip, rig.rightShoulder, xOffset: 4))
        torso.closeSubpath()
        context.fill(torso, with: .color(bodyColor))

        let headSize = max(15, size.width * 0.17)
        context.fill(
            Path(
                ellipseIn: CGRect(
                    x: rig.head.x - headSize / 2,
                    y: rig.head.y - headSize / 2,
                    width: headSize,
                    height: headSize
                )
            ),
            with: .color(bodyColor)
        )
    }

    private func drawEquipment(
        context: inout GraphicsContext,
        size: CGSize,
        rig: MovementRig
    ) {
        let width = max(4, size.width * 0.045)

        switch pose {
        case .push:
            drawDumbbell(at: rig.leftHand, width: width, context: &context)
            drawDumbbell(at: rig.rightHand, width: width, context: &context)
        case .pull:
            drawSegment(
                point(0.14, 0.12, in: size),
                point(0.86, 0.12, in: size),
                width: width,
                color: accent,
                context: &context
            )
        case .legs:
            drawSegment(
                point(0.15, 0.31, in: size),
                point(0.85, 0.31, in: size),
                width: width,
                color: accent,
                context: &context
            )
            drawPlate(at: point(0.15, 0.31, in: size), size: width * 2.4, context: &context)
            drawPlate(at: point(0.85, 0.31, in: size), size: width * 2.4, context: &context)
        case .cardio:
            for index in 0..<3 {
                let vertical = 0.38 + CGFloat(index) * 0.10
                drawSegment(
                    point(0.05, vertical, in: size),
                    point(0.19 - CGFloat(index) * 0.02, vertical, in: size),
                    width: width * 0.55,
                    color: accent.opacity(0.9 - Double(index) * 0.18),
                    context: &context
                )
            }
        }
    }

    private func drawSegment(
        _ start: CGPoint,
        _ end: CGPoint,
        width: CGFloat,
        color: Color,
        context: inout GraphicsContext
    ) {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        context.stroke(
            path,
            with: .color(color),
            style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)
        )
    }

    private func drawDumbbell(at center: CGPoint, width: CGFloat, context: inout GraphicsContext) {
        let halfLength = width * 1.7
        drawSegment(
            CGPoint(x: center.x - halfLength, y: center.y),
            CGPoint(x: center.x + halfLength, y: center.y),
            width: width * 0.55,
            color: accent,
            context: &context
        )
        drawPlate(at: CGPoint(x: center.x - halfLength, y: center.y), size: width * 1.8, context: &context)
        drawPlate(at: CGPoint(x: center.x + halfLength, y: center.y), size: width * 1.8, context: &context)
    }

    private func drawPlate(at center: CGPoint, size: CGFloat, context: inout GraphicsContext) {
        context.fill(
            Path(
                roundedRect: CGRect(
                    x: center.x - size / 2,
                    y: center.y - size / 2,
                    width: size,
                    height: size
                ),
                cornerRadius: size * 0.28
            ),
            with: .color(accent)
        )
    }

    private func rig(in size: CGSize) -> MovementRig {
        switch pose {
        case .push: pushRig(in: size)
        case .pull: pullRig(in: size)
        case .legs: legsRig(in: size)
        case .cardio: cardioRig(in: size)
        }
    }

    private func pushRig(in size: CGSize) -> MovementRig {
        MovementRig(
            head: point(0.50, 0.19, in: size),
            leftShoulder: point(0.39, 0.31, in: size), rightShoulder: point(0.61, 0.31, in: size),
            leftElbow: point(0.29, 0.20, in: size), rightElbow: point(0.71, 0.20, in: size),
            leftHand: point(0.28, 0.08, in: size), rightHand: point(0.72, 0.08, in: size),
            leftHip: point(0.44, 0.58, in: size), rightHip: point(0.56, 0.58, in: size),
            leftKnee: point(0.40, 0.76, in: size), rightKnee: point(0.61, 0.76, in: size),
            leftFoot: point(0.35, 0.92, in: size), rightFoot: point(0.67, 0.92, in: size)
        )
    }

    private func pullRig(in size: CGSize) -> MovementRig {
        MovementRig(
            head: point(0.50, 0.25, in: size),
            leftShoulder: point(0.39, 0.35, in: size), rightShoulder: point(0.61, 0.35, in: size),
            leftElbow: point(0.31, 0.25, in: size), rightElbow: point(0.69, 0.25, in: size),
            leftHand: point(0.25, 0.12, in: size), rightHand: point(0.75, 0.12, in: size),
            leftHip: point(0.44, 0.61, in: size), rightHip: point(0.56, 0.61, in: size),
            leftKnee: point(0.39, 0.78, in: size), rightKnee: point(0.61, 0.78, in: size),
            leftFoot: point(0.35, 0.93, in: size), rightFoot: point(0.66, 0.93, in: size)
        )
    }

    private func legsRig(in size: CGSize) -> MovementRig {
        MovementRig(
            head: point(0.50, 0.20, in: size),
            leftShoulder: point(0.38, 0.32, in: size), rightShoulder: point(0.62, 0.32, in: size),
            leftElbow: point(0.28, 0.38, in: size), rightElbow: point(0.72, 0.38, in: size),
            leftHand: point(0.34, 0.31, in: size), rightHand: point(0.66, 0.31, in: size),
            leftHip: point(0.43, 0.57, in: size), rightHip: point(0.57, 0.57, in: size),
            leftKnee: point(0.30, 0.70, in: size), rightKnee: point(0.70, 0.70, in: size),
            leftFoot: point(0.18, 0.88, in: size), rightFoot: point(0.82, 0.88, in: size)
        )
    }

    private func cardioRig(in size: CGSize) -> MovementRig {
        MovementRig(
            head: point(0.55, 0.18, in: size),
            leftShoulder: point(0.46, 0.30, in: size), rightShoulder: point(0.65, 0.34, in: size),
            leftElbow: point(0.31, 0.37, in: size), rightElbow: point(0.78, 0.25, in: size),
            leftHand: point(0.22, 0.29, in: size), rightHand: point(0.86, 0.35, in: size),
            leftHip: point(0.46, 0.58, in: size), rightHip: point(0.57, 0.60, in: size),
            leftKnee: point(0.31, 0.74, in: size), rightKnee: point(0.72, 0.73, in: size),
            leftFoot: point(0.17, 0.89, in: size), rightFoot: point(0.88, 0.82, in: size)
        )
    }

    private func point(_ horizontal: CGFloat, _ vertical: CGFloat, in size: CGSize) -> CGPoint {
        CGPoint(x: size.width * horizontal, y: size.height * vertical)
    }

    private func midpoint(_ start: CGPoint, _ end: CGPoint, xOffset: CGFloat) -> CGPoint {
        CGPoint(x: (start.x + end.x) / 2 + xOffset, y: (start.y + end.y) / 2)
    }
}

private struct MovementRig {
    let head: CGPoint
    let leftShoulder: CGPoint
    let rightShoulder: CGPoint
    let leftElbow: CGPoint
    let rightElbow: CGPoint
    let leftHand: CGPoint
    let rightHand: CGPoint
    let leftHip: CGPoint
    let rightHip: CGPoint
    let leftKnee: CGPoint
    let rightKnee: CGPoint
    let leftFoot: CGPoint
    let rightFoot: CGPoint
}
