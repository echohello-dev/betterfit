import Foundation

// MARK: - Superset store
//
// Lightweight, app-wide registry of which exercises are paired as supersets.
// Owned by the Plan tab; consulted by the Live session to flip between
// paired exercises (A1 → B1 → rest → A2 → B2 …) and render the badge.

@MainActor
final class BFSupersetStore: ObservableObject {
    static let shared = BFSupersetStore()

    /// Exercise id → shared group id.
    @Published private(set) var group: [UUID: UUID] = [:]

    func isLinked(_ id: UUID) -> Bool { group[id] != nil }

    func partner(of id: UUID) -> UUID? {
        guard let groupID = group[id] else { return nil }
        return group.first(where: { $0.key != id && $0.value == groupID })?.key
    }

    /// Link two exercises into the same group. No-op if already in the same group.
    func link(_ exerciseA: UUID, _ exerciseB: UUID) {
        if exerciseA == exerciseB { return }
        let existingA = group[exerciseA]
        let existingB = group[exerciseB]
        let newGroup = existingA ?? existingB ?? UUID()
        group[exerciseA] = newGroup
        group[exerciseB] = newGroup
    }

    func unlink(_ id: UUID) {
        guard let groupID = group[id] else { return }
        for key in Array(group.keys) where group[key] == groupID {
            group.removeValue(forKey: key)
        }
    }

    func reset() { group.removeAll() }

/// Plain dictionary snapshot for read-only consumers (e.g. live session).
func snapshot() -> [UUID: UUID] { group }
}