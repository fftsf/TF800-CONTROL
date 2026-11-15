import Foundation

struct KeyAssignment: Codable, Identifiable, Equatable {
    var id: String { source }
    var source: String
    var destination: String?
    var disabled: Bool = false
}

struct MacroAction: Codable, Identifiable, Equatable {
    var id = UUID()
    var key: String
    var delayMilliseconds: Int = 50
}

struct KeyMacro: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var actions: [MacroAction] = []
}

struct DeviceProfile: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var assignments: [KeyAssignment] = []
    var macros: [KeyMacro] = []
}

struct ProfileDocument: Codable {
    var activeProfileID: UUID
    var profiles: [DeviceProfile]
}

enum HardwareLightingState: String {
    case unknown = "Non vérifié"
    case on = "Allumé"
    case off = "Éteint"
}
