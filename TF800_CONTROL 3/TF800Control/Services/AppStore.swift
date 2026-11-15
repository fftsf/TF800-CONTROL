import Foundation
import Combine

@MainActor final class AppStore: ObservableObject {
    @Published var profiles: [DeviceProfile] = []
    @Published var activeProfileID: UUID
    @Published var selectedKey: String? = nil
    @Published var deviceConnected = false
    @Published var lightingState: HardwareLightingState = .unknown
    @Published var deviceName: String = "Aucun clavier T-WOLF TF800 détecté"
    @Published var statusMessage = "En attente de détection USB"
    private let fileURL: URL
    let detector = TF800HIDDetector()

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("TF800 CONTROL", isDirectory: true)
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("profiles.json")
        let defaults = [DeviceProfile(name: "Gaming"), DeviceProfile(name: "Bureautique"), DeviceProfile(name: "Personnalisé")]
        if let data = try? Data(contentsOf: fileURL), let doc = try? JSONDecoder().decode(ProfileDocument.self, from: data) {
            profiles = doc.profiles.isEmpty ? defaults : doc.profiles
            activeProfileID = doc.profiles.contains(where: {$0.id == doc.activeProfileID}) ? doc.activeProfileID : (doc.profiles.first?.id ?? defaults[0].id)
        } else {
            profiles = defaults
            activeProfileID = defaults[0].id
        }
        detector.onChange = { [weak self] name in
            Task { @MainActor in
                self?.deviceConnected = name != nil
                self?.deviceName = name ?? "Aucun clavier T-WOLF TF800 détecté"
                self?.statusMessage = name == nil
                    ? "Clavier déconnecté"
                    : "USB HID confirmé · VID C0F4 / PID 0FF5"
                // The TF800's lighting protocol/state has not yet been verified.
                self?.lightingState = .unknown
            }
        }
        detector.start()
        save()
    }

    var activeProfile: DeviceProfile? { profiles.first(where: {$0.id == activeProfileID}) }
    func save() {
        let doc = ProfileDocument(activeProfileID: activeProfileID, profiles: profiles)
        guard let data = try? JSONEncoder().encode(doc) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
    func selectProfile(_ id: UUID) { activeProfileID = id; save() }
    func addProfile() {
        let profile = DeviceProfile(name: "Nouveau profil")
        profiles.append(profile); activeProfileID = profile.id; save()
    }
    func renameProfile(_ id: UUID, to name: String) {
        guard let i = profiles.firstIndex(where: {$0.id == id}) else { return }
        profiles[i].name = name; save()
    }
    func deleteProfile(_ id: UUID) {
        guard profiles.count > 1 else { return }
        profiles.removeAll {$0.id == id}
        if activeProfileID == id { activeProfileID = profiles[0].id }
        save()
    }
    func setAssignment(source: String, destination: String?, disabled: Bool) {
        guard let i = profiles.firstIndex(where: {$0.id == activeProfileID}) else { return }
        profiles[i].assignments.removeAll {$0.source == source}
        if disabled || (destination != nil && destination != source) {
            profiles[i].assignments.append(KeyAssignment(source: source, destination: destination, disabled: disabled))
        }
        save()
    }
}
