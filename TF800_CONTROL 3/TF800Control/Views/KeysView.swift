import SwiftUI

struct KeysView: View {
    @EnvironmentObject private var store: AppStore
    @State private var destination = ""
    @State private var disabled = false
    private let rows = [["ESC","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"], ["1","2","3","4","5","6","7","8","9","0","-","="], ["Q","W","E","R","T","Y","U","I","O","P"], ["A","S","D","F","G","H","J","K","L"], ["Z","X","C","V","B","N","M","SPACE"]]
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            ScrollView { VStack(alignment: .leading, spacing: 18) {
                Text("Sélectionnez une touche pour préparer sa configuration.").font(.system(size: 13)).foregroundStyle(.secondary)
                Panel(title: "CLAVIER · SÉLECTION DES TOUCHES") {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 5) { ForEach(row, id: \.self) { key in
                            Button { select(key) } label: { Text(key).font(.system(size: key == "SPACE" ? 9 : 10, weight: .medium)).frame(maxWidth: .infinity).frame(height: 42).background(keyColor(key), in: RoundedRectangle(cornerRadius: 5)).overlay(RoundedRectangle(cornerRadius: 5).stroke(store.selectedKey == key ? Color.cyan : .white.opacity(0.08), lineWidth: store.selectedKey == key ? 2 : 1)) }.buttonStyle(.plain)
                        }}
                    }
                    Text("Disposition simplifiée pour configurer les touches courantes. La correspondance physique complète devra être confirmée sur le TF800.").font(.system(size: 10)).foregroundStyle(.secondary)
                }
            }.padding(24).frame(maxWidth: .infinity, alignment: .leading) }
            Panel(title: "CONFIGURATION") {
                if let key = store.selectedKey {
                    Text("Touche sélectionnée").font(.system(size: 11)).foregroundStyle(.secondary)
                    Text(key).font(.system(size: 30, weight: .bold)).foregroundStyle(.cyan)
                    Toggle("Désactiver cette touche", isOn: $disabled).toggleStyle(.switch)
                    Text("Remplacer par").font(.system(size: 11)).foregroundStyle(.secondary)
                    TextField("Ex. SPACE, A, ENTER", text: $destination).textFieldStyle(.roundedBorder)
                    Button("Enregistrer dans le profil") { store.setAssignment(source: key, destination: destination.isEmpty ? nil : destination.uppercased(), disabled: disabled); destination = "" }.buttonStyle(.borderedProminent).tint(.cyan)
                    Button("Restaurer la fonction d'origine") { store.setAssignment(source: key, destination: nil, disabled: false); disabled = false; destination = "" }.buttonStyle(.bordered)
                    Divider().overlay(.white.opacity(0.1))
                    Text("Important : les modifications sont enregistrées dans le profil, mais ne sont pas encore injectées dans macOS. Le remappage exclusif au TF800 nécessite une identification HID et une méthode d'interception par périphérique.").font(.system(size: 11)).foregroundStyle(.orange)
                } else { Text("Cliquez sur une touche du clavier pour afficher ses options.").font(.system(size: 12)).foregroundStyle(.secondary) }
            }.frame(width: 290).padding(.trailing, 24).padding(.top, 24)
        }
    }
    private func select(_ key: String) { store.selectedKey = key; let a = store.activeProfile?.assignments.first {$0.source == key}; destination = a?.destination ?? ""; disabled = a?.disabled ?? false }
    private func keyColor(_ key: String) -> Color { if store.activeProfile?.assignments.contains(where: {$0.source == key}) == true { return .orange.opacity(0.22) }; return Color.white.opacity(0.07) }
}
