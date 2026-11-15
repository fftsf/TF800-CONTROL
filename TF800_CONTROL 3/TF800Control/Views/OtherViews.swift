import SwiftUI

struct LightingView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View { VStack(alignment: .leading, spacing: 20) {
        Text("Contrôle du rétroéclairage").font(.system(size: 24, weight: .bold))
        Panel(title: "ÉTAT MATÉRIEL") {
            HStack { Image("TF800Unlit").resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 520); Spacer() }
            HStack { Text("État actuel"); Spacer(); Text(store.lightingState.rawValue).foregroundStyle(.orange) }
            Text("Les commandes ON/OFF sont volontairement désactivées : le protocole de contrôle du T-WOLF TF800 n'a pas encore été identifié. L'application ne prétend donc pas piloter le RGB.").font(.system(size: 12)).foregroundStyle(.secondary)
            HStack { Button("Allumer").disabled(true); Button("Éteindre").disabled(true) }
        }
        Spacer()
    }.padding(26) }
}

struct ProfilesView: View {
    @EnvironmentObject private var store: AppStore
    @State private var rename = ""
    var body: some View { VStack(alignment: .leading, spacing: 18) {
        HStack { VStack(alignment: .leading, spacing: 5) { Text("Profils").font(.system(size: 24, weight: .bold)); Text("Les profils sont sauvegardés localement sur ce Mac.").foregroundStyle(.secondary) }; Spacer(); Button { store.addProfile() } label: { Label("Nouveau profil", systemImage: "plus") }.buttonStyle(.borderedProminent).tint(.cyan) }
        ForEach(store.profiles) { profile in
            HStack(spacing: 14) {
                Image(systemName: "person.crop.square").font(.system(size: 22)).foregroundStyle(.cyan)
                VStack(alignment: .leading, spacing: 4) { Text(profile.name).font(.system(size: 14, weight: .semibold)); Text("\(profile.assignments.count) modifications · \(profile.macros.count) macros").font(.system(size: 11)).foregroundStyle(.secondary) }
                Spacer()
                if profile.id == store.activeProfileID { Text("ACTIF").font(.system(size: 9, weight: .bold)).foregroundStyle(.green) }
                Button("Utiliser") { store.selectProfile(profile.id) }.disabled(profile.id == store.activeProfileID)
                Button(role: .destructive) { store.deleteProfile(profile.id) } label: { Image(systemName: "trash") }.disabled(store.profiles.count <= 1)
            }.padding(16).background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 10))
        }
        Panel(title: "RENOMMER LE PROFIL ACTIF") { TextField("Nom du profil", text: $rename).textFieldStyle(.roundedBorder); Button("Renommer") { if !rename.trimmingCharacters(in: .whitespaces).isEmpty { store.renameProfile(store.activeProfileID, to: rename); rename = "" } }.buttonStyle(.bordered) }
        Spacer()
    }.padding(26) }
}

struct MacrosView: View {
    @EnvironmentObject private var store: AppStore
    @State private var macroName = "Nouvelle macro"
    @State private var key = "A"
    @State private var delay = 50.0
    var body: some View { VStack(alignment: .leading, spacing: 18) {
        Text("Macros").font(.system(size: 24, weight: .bold))
        Panel(title: "ÉDITEUR DE SÉQUENCES") {
            TextField("Nom de la macro", text: $macroName).textFieldStyle(.roundedBorder)
            HStack { TextField("Touche", text: $key).frame(width: 130); Slider(value: $delay, in: 0...1000, step: 10); Text("\(Int(delay)) ms").font(.system(size: 11)).monospacedDigit() }
            Button("Ajouter la séquence au profil") {
                guard let i = store.profiles.firstIndex(where: {$0.id == store.activeProfileID}) else { return }
                if let existing = store.profiles[i].macros.firstIndex(where: {$0.name == macroName}) { store.profiles[i].macros[existing].actions.append(MacroAction(key: key.uppercased(), delayMilliseconds: Int(delay))) }
                else { store.profiles[i].macros.append(KeyMacro(name: macroName, actions: [MacroAction(key: key.uppercased(), delayMilliseconds: Int(delay))])) }
                store.save()
            }.buttonStyle(.borderedProminent).tint(.cyan)
        }
        Panel(title: "MACROS DU PROFIL ACTIF") {
            if let macros = store.activeProfile?.macros, !macros.isEmpty {
                ForEach(macros) { macro in VStack(alignment: .leading, spacing: 5) { Text(macro.name).font(.system(size: 13, weight: .semibold)); Text(macro.actions.map { "\($0.key) (\($0.delayMilliseconds) ms)" }.joined(separator: " → ")).font(.system(size: 11)).foregroundStyle(.secondary) } }
            } else { Text("Aucune macro enregistrée.").foregroundStyle(.secondary) }
            Text("L'éditeur enregistre des séquences. Leur exécution et leur association à une touche attendent une méthode matérielle/HID compatible et les autorisations macOS nécessaires.").font(.system(size: 11)).foregroundStyle(.orange)
        }
        Spacer()
    }.padding(26) }
}

struct UpdatesView: View {
    var body: some View { VStack(alignment: .leading, spacing: 20) {
        Text("Mises à jour").font(.system(size: 24, weight: .bold))
        Panel(title: "VERSION DE L'APPLICATION") {
            HStack { Text("Version installée"); Spacer(); Text("0.1.0 · Prototype natif").foregroundStyle(.secondary) }
            HStack { Text("Version disponible"); Spacer(); Text("Non configurée").foregroundStyle(.secondary) }
            Button("Vérifier les mises à jour") {}.disabled(true)
            Text("Aucun serveur de mise à jour n'est configuré dans cette version. Aucune mise à jour firmware n'est proposée : il faut d'abord une procédure officielle du fabricant.").font(.system(size: 11)).foregroundStyle(.secondary)
        }
        Spacer()
    }.padding(26) }
}
