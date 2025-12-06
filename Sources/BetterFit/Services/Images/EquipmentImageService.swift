import Foundation

/// Service for managing clean consistent 3D/AI equipment images
public class EquipmentImageService {
    private var imageCache: [String: EquipmentImage] = [:]
    
    public init() {
        initializeDefaultImages()
    }
    
    /// Get image for equipment type
    public func getImage(for equipment: Equipment) -> EquipmentImage? {
        return imageCache[equipment.rawValue]
    }
    
    /// Get image for exercise
    public func getImage(for exercise: Exercise) -> EquipmentImage? {
        if let customURL = exercise.imageURL {
            return imageCache[customURL]
        }
        return getImage(for: exercise.equipmentRequired)
    }
    
    /// Cache an image
    public func cacheImage(_ image: EquipmentImage, for key: String) {
        imageCache[key] = image
    }
    
    /// Get all available images
    public func getAllImages() -> [EquipmentImage] {
        return Array(imageCache.values)
    }
    
    /// Initialize default equipment images
    private func initializeDefaultImages() {
        for equipment in Equipment.allCases {
            let image = EquipmentImage(
                id: UUID(),
                equipmentType: equipment,
                url: "https://betterfit.app/images/equipment/\(equipment.rawValue).png",
                is3D: true,
                isAIGenerated: true
            )
            imageCache[equipment.rawValue] = image
        }
    }
    
    /// Load custom image from URL
    public func loadCustomImage(url: String, for equipment: Equipment) async throws -> EquipmentImage {
        // In a real implementation, this would fetch the image
        let image = EquipmentImage(
            id: UUID(),
            equipmentType: equipment,
            url: url,
            is3D: false,
            isAIGenerated: false
        )
        
        imageCache[url] = image
        return image
    }
    
    /// Generate AI image for custom exercise
    public func generateAIImage(
        for exercise: Exercise,
        style: ImageStyle = .realistic3D
    ) async throws -> EquipmentImage {
        // In a real implementation, this would call an AI image generation service
        let image = EquipmentImage(
            id: UUID(),
            equipmentType: exercise.equipmentRequired,
            url: "https://betterfit.app/images/generated/\(exercise.id).png",
            is3D: style == .realistic3D,
            isAIGenerated: true
        )
        
        let key = exercise.imageURL ?? exercise.id.uuidString
        imageCache[key] = image
        return image
    }
}

/// Equipment image model
public struct EquipmentImage: Identifiable, Equatable {
    public let id: UUID
    public var equipmentType: Equipment
    public var url: String
    public var is3D: Bool
    public var isAIGenerated: Bool
    
    public init(
        id: UUID = UUID(),
        equipmentType: Equipment,
        url: String,
        is3D: Bool,
        isAIGenerated: Bool
    ) {
        self.id = id
        self.equipmentType = equipmentType
        self.url = url
        self.is3D = is3D
        self.isAIGenerated = isAIGenerated
    }
}

/// Image generation styles
public enum ImageStyle: String, CaseIterable {
    case realistic3D
    case cartoon
    case schematic
    case photographic
}
