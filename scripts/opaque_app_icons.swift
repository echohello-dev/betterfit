import AppKit
import Foundation

// Re-export existing icon pixels over their established background, without redrawing artwork.
// Usage: swift scripts/opaque_app_icons.swift <AppIcon.appiconset> <background RGB hex>
guard CommandLine.arguments.count == 3,
    CommandLine.arguments[2].count == 6,
    let hex = UInt32(CommandLine.arguments[2], radix: 16)
else {
    fatalError("Supply an icon catalogue directory and six-digit background RGB hex.")
}
let background = [UInt((hex >> 16) & 255), UInt((hex >> 8) & 255), UInt(hex & 255)]
let catalogue = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let files = try FileManager.default.contentsOfDirectory(at: catalogue, includingPropertiesForKeys: nil)
    .filter { $0.pathExtension.lowercased() == "png" }.sorted { $0.path < $1.path }

for file in files {
    let source = NSBitmapImageRep(data: try Data(contentsOf: file))!
    guard source.hasAlpha else { continue }
    precondition(source.bitsPerSample == 8 && source.samplesPerPixel == 4 && !source.isPlanar)
    let result = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: source.pixelsWide, pixelsHigh: source.pixelsHigh,
        bitsPerSample: 8, samplesPerPixel: 3, hasAlpha: false, isPlanar: false,
        colorSpaceName: source.colorSpaceName, bitmapFormat: [],
        bytesPerRow: source.pixelsWide * 3, bitsPerPixel: 24
    )!
    if let profile = source.value(forProperty: .colorSyncProfileData) {
        result.setProperty(.colorSyncProfileData, withValue: profile)
    }
    let alphaIndex = source.bitmapFormat.contains(.alphaFirst) ? 0 : 3
    let channels = alphaIndex == 0 ? [1, 2, 3] : [0, 1, 2]
    let straightAlpha = source.bitmapFormat.contains(.alphaNonpremultiplied)
    var composited = 0
    for y in 0..<source.pixelsHigh {
        for x in 0..<source.pixelsWide {
            var pixel = [UInt](repeating: 0, count: 4)
            source.getPixel(&pixel, atX: x, y: y)
            let alpha = pixel[alphaIndex]
            var rgb = channels.map { pixel[$0] }
            if alpha < 255 {
                composited += 1
                for channel in 0..<3 {
                    let foreground = straightAlpha ? rgb[channel] * alpha : rgb[channel] * 255
                    rgb[channel] = min(255, (foreground + background[channel] * (255 - alpha) + 127) / 255)
                }
            }
            result.setPixel(&rgb, atX: x, y: y)
        }
    }
    let encoded = result.representation(using: .png, properties: [:])!
    let verified = NSBitmapImageRep(data: encoded)!
    precondition(!verified.hasAlpha)
    // Check encoded pixels too: opaque artwork must survive the export byte-for-byte.
    for y in 0..<source.pixelsHigh {
        for x in 0..<source.pixelsWide {
            var original = [UInt](repeating: 0, count: 4)
            source.getPixel(&original, atX: x, y: y)
            if original[alphaIndex] == 255 {
                var actual = [UInt](repeating: 0, count: 3)
                verified.getPixel(&actual, atX: x, y: y)
                precondition(actual == channels.map { original[$0] }, "Opaque artwork changed during export")
            }
        }
    }
    try encoded.write(to: file, options: .atomic)
    print("\(file.lastPathComponent): RGB PNG, \(composited) transparent pixels composited, opaque artwork unchanged")
}
