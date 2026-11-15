import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 22) {
            HStack { VStack(alignment: .leading, spacing: 6) { Text("Bienvenue dans TF800 CONTROL").font(.system(size: 25, weight: .bold)); Text("Gérez votre clavier T-WOLF depuis votre Mac.").foregroundStyle(.secondary) }; Spacer() }
            HStack(spacing: 12) {
                metric("PÉRIPHÉRIQUE", store.deviceConnected ? "Connecté" : "Déconnecté", store.deviceConnected ? "checkmark.circle.fill" : "cable.connector.slash", store.deviceConnected ? .green : .gray)
                metric("ÉCLAIRAGE", store.lightingState.rawValue, "lightbulb", .cyan)
                metric("PROFIL ACTIF", store.activeProfile?.name ?? "—", "person.crop.square", .purple)
            }
            Panel(title: "VOTRE T-WOLF TF800") {
                Image(store.lightingState == .on ? "TF800Lit" : "TF800Unlit")
                    .resizable().aspectRatio(contentMode: .fit).frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                HStack { Label(store.deviceName, systemImage: "keyboard").font(.system(size: 12)).foregroundStyle(.secondary); Spacer(); Text(store.statusMessage).font(.system(size: 11)).foregroundStyle(.secondary) }
                Text("L'image est une référence visuelle. La connexion est vérifiée par les identifiants USB C0F4:0FF5. L'état RGB reste inconnu : l'image éteinte est affichée par défaut pour ne pas simuler un éclairage actif.").font(.system(size: 11)).foregroundStyle(.secondary)
            }
            Panel(title: "ÉTAT DES FONCTIONNALITÉS") {
                feature("Détection USB HID", "Active", true)
                feature("Profils locaux", "Disponible", true)
                feature("Remappage global propre au TF800", "En attente d'identification HID", false)
                feature("Commandes RGB matérielles", "Protocole non identifié", false)
            }
        }.padding(26) }
    }
    private func metric(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) { Image(systemName: icon).font(.system(size: 18)).foregroundStyle(color); Text(title).font(.system(size: 9, weight: .bold)).tracking(1.2).foregroundStyle(.secondary); Text(value).font(.system(size: 17, weight: .semibold)) }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 10))
    }
    private func feature(_ name: String, _ value: String, _ ready: Bool) -> some View { HStack { Text(name).font(.system(size: 12)); Spacer(); Text(value).font(.system(size: 11)).foregroundStyle(ready ? .green : .orange) } }
}
