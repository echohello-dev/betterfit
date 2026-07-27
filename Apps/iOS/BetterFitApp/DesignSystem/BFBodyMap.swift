@preconcurrency import BetterFit
import SwiftUI

// MARK: - Recovery Body Map

/// Front/back vector anatomy whose regions map directly to `BodyRegion`.
/// Each region remains independent so it can be recolored or made interactive.
struct RecoveryBodyMap: View {
    let regions: [BodyRegion: RecoveryStatus]
    var showsBack = true

    var body: some View {
        HStack(spacing: showsBack ? 10 : 0) {
            AnatomicalFigure(side: .front, regions: regions)

            if showsBack {
                AnatomicalFigure(side: .back, regions: regions)
            }
        }
        .aspectRatio(showsBack ? 0.82 : 0.38, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Muscle recovery body map")
        .accessibilityValue(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        BodyRegion.allCases
            .filter { $0 != .other }
            .map { region in
                let status = regions[region] ?? .recovered
                return "\(region.bfLabel) \(status.bfLabel)"
            }
            .joined(separator: ", ")
    }
}

/// Compact use of the same addressable anatomy used by the full recovery view.
struct BodyMapCompanion: View {
    @Environment(\.colorScheme) private var colorScheme

    let regions: [BodyRegion: RecoveryStatus]
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            Circle()
                .fill(BFColors.surfaceRaised(for: colorScheme))

            RecoveryBodyMap(regions: regions, showsBack: false)
                .frame(width: size * 0.36, height: size * 0.80)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Anatomical Figure

private struct AnatomicalFigure: View {
    let side: BodySide
    let regions: [BodyRegion: RecoveryStatus]

    private var visibleRegions: [BodyRegion] {
        side == .front
            ? [.shoulders, .chest, .arms, .core, .legs]
            : [.shoulders, .back, .arms, .core, .legs]
    }

    var body: some View {
        ZStack {
            AnatomyBaseShape()
                .fill(Color.white.opacity(0.10))

            ForEach(visibleRegions, id: \.self) { region in
                AnatomyRegionShape(region: region)
                    .fill((regions[region] ?? .recovered).bfColor.opacity(0.88))
                    .overlay {
                        AnatomyRegionShape(region: region)
                            .stroke(Color.black.opacity(0.28), lineWidth: 0.7)
                    }
            }

            AnatomyHeadShape()
                .fill(Color.white.opacity(0.72))
        }
        .aspectRatio(0.42, contentMode: .fit)
    }
}

private enum BodySide {
    case front
    case back
}

private struct AnatomyHeadShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(
            in: anatomyRect(horizontal: 39, vertical: 4, width: 22, height: 24, in: rect)
        )
        path.addRoundedRect(
            in: anatomyRect(horizontal: 45, vertical: 25, width: 10, height: 12, in: rect),
            cornerSize: anatomySize(width: 3, height: 3, in: rect)
        )
        return path
    }
}

private struct AnatomyBaseShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addPath(AnatomyHeadShape().path(in: rect))
        path.addPath(AnatomyRegionShape(region: .shoulders).path(in: rect))
        path.addPath(AnatomyRegionShape(region: .chest).path(in: rect))
        path.addPath(AnatomyRegionShape(region: .arms).path(in: rect))
        path.addPath(AnatomyRegionShape(region: .core).path(in: rect))
        path.addPath(AnatomyRegionShape(region: .legs).path(in: rect))
        return path
    }
}

private struct AnatomyRegionShape: Shape {
    let region: BodyRegion

    func path(in rect: CGRect) -> Path {
        switch region {
        case .chest:
            torsoPath(topY: 42, bottomY: 73, topInset: 34, bottomInset: 39, in: rect)
        case .back:
            torsoPath(topY: 39, bottomY: 78, topInset: 33, bottomInset: 39, in: rect)
        case .shoulders:
            shouldersPath(in: rect)
        case .arms:
            armsPath(in: rect)
        case .core:
            corePath(in: rect)
        case .legs:
            legsPath(in: rect)
        case .other:
            Path()
        }
    }

    private func shouldersPath(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(
            in: anatomyRect(horizontal: 23, vertical: 35, width: 24, height: 19, in: rect),
            cornerSize: anatomySize(width: 8, height: 8, in: rect)
        )
        path.addRoundedRect(
            in: anatomyRect(horizontal: 53, vertical: 35, width: 24, height: 19, in: rect),
            cornerSize: anatomySize(width: 8, height: 8, in: rect)
        )
        return path
    }

    private func torsoPath(
        topY: CGFloat,
        bottomY: CGFloat,
        topInset: CGFloat,
        bottomInset: CGFloat,
        in rect: CGRect
    ) -> Path {
        polygon(
            [
                (topInset, topY),
                (100 - topInset, topY),
                (100 - bottomInset, bottomY),
                (bottomInset, bottomY)
            ],
            in: rect
        )
    }

    private func armsPath(in rect: CGRect) -> Path {
        var path = Path()
        path.addPath(polygon([(27, 43), (35, 49), (27, 91), (18, 91), (20, 58)], in: rect))
        path.addPath(polygon([(73, 43), (65, 49), (73, 91), (82, 91), (80, 58)], in: rect))
        return path
    }

    private func corePath(in rect: CGRect) -> Path {
        polygon([(39, 72), (61, 72), (58, 106), (42, 106)], in: rect)
    }

    private func legsPath(in rect: CGRect) -> Path {
        var path = Path()
        path.addPath(
            polygon([(34, 101), (50, 103), (47, 151), (43, 214), (31, 214), (34, 151)], in: rect)
        )
        path.addPath(
            polygon([(50, 103), (66, 101), (66, 151), (69, 214), (57, 214), (53, 151)], in: rect)
        )
        return path
    }

    private func polygon(_ points: [(CGFloat, CGFloat)], in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: anatomyPoint(horizontal: first.0, vertical: first.1, in: rect))
        for point in points.dropFirst() {
            path.addLine(to: anatomyPoint(horizontal: point.0, vertical: point.1, in: rect))
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Geometry

private func anatomyPoint(horizontal: CGFloat, vertical: CGFloat, in rect: CGRect) -> CGPoint {
    CGPoint(
        x: rect.minX + rect.width * horizontal / 100,
        y: rect.minY + rect.height * vertical / 220
    )
}

private func anatomyRect(
    horizontal: CGFloat,
    vertical: CGFloat,
    width: CGFloat,
    height: CGFloat,
    in rect: CGRect
) -> CGRect {
    CGRect(
        x: rect.minX + rect.width * horizontal / 100,
        y: rect.minY + rect.height * vertical / 220,
        width: rect.width * width / 100,
        height: rect.height * height / 220
    )
}

private func anatomySize(width: CGFloat, height: CGFloat, in rect: CGRect) -> CGSize {
    CGSize(width: rect.width * width / 100, height: rect.height * height / 220)
}

private extension BodyRegion {
    var bfLabel: String {
        switch self {
        case .chest: return "Chest"
        case .back: return "Back"
        case .shoulders: return "Shoulders"
        case .arms: return "Arms"
        case .core: return "Core"
        case .legs: return "Legs"
        case .other: return "Other"
        }
    }
}
