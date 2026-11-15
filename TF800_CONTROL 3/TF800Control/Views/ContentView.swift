import SwiftUI

private enum Page: String, CaseIterable, Identifiable {
    case dashboard = "Accueil", keys = "Touches", lighting = "Éclairage", profiles = "Profils", macros = "Macros", updates = "Mises à jour"
    var id: String { rawValue }
    var icon: String {
        switch self { case .dashboard: "square.grid.2x2.fill"; case .keys: "keyboard"; case .lighting: "lightbulb"; case .profiles: "person.crop.square"; case .macros: "command"; case .updates: "arrow.down.circle" }
    }
}

struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @State private var page: Page = .dashboard
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    ZStack { RoundedRectangle(cornerRadius: 9).fill(Color.cyan.opacity(0.18)); Image(systemName: "keyboard.fill").foregroundStyle(.cyan) }.frame(width: 36, height: 36)
                    VStack(alignment: .leading, spacing: 1) { Text("TF800").font(.system(size: 15, weight: .bold)); Text("CONTROL").font(.system(size: 10, weight: .semibold)).tracking(2).foregroundStyle(.secondary) }
                }.padding(.horizontal, 18).padding(.top, 22).padding(.bottom, 24)
                ForEach(Page.allCases) { item in
                    Button { page = item } label: {
                        HStack(spacing: 12) { Image(systemName: item.icon).frame(width: 20); Text(item.rawValue); Spacer() }
                            .font(.system(size: 13, weight: page == item ? .semibold : .regular))
                            .foregroundStyle(page == item ? .white : Color.white.opacity(0.58))
                            .padding(.horizontal, 14).padding(.vertical, 11)
                            .background(page == item ? Color.cyan.opacity(0.18) : .clear, in: RoundedRectangle(cornerRadius: 8))
                    }.buttonStyle(.plain).padding(.horizontal, 10)
                }
                Spacer()
                HStack(spacing: 8) { Circle().fill(store.deviceConnected ? .green : .gray).frame(width: 7, height: 7); Text(store.deviceConnected ? "TF800 connecté" : "Déconnecté").font(.system(size: 11)).foregroundStyle(.secondary) }.padding(18)
            }.frame(width: 210).background(Color(red: 0.075, green: 0.08, blue: 0.09))
            VStack(spacing: 0) {
                HStack { VStack(alignment: .leading, spacing: 3) { Text(page.rawValue.uppercased()).font(.system(size: 11, weight: .bold)).tracking(1.8); Text("T-WOLF TF800 · macOS").font(.system(size: 11)).foregroundStyle(.secondary) }; Spacer(); HStack(spacing: 8) { Circle().fill(store.deviceConnected ? .green : .gray).frame(width: 8,height: 8); Text(store.deviceConnected ? "CONNECTÉ" : "NON CONNECTÉ").font(.system(size: 10, weight: .bold)).tracking(1).foregroundStyle(store.deviceConnected ? Color.green : Color.gray) }.padding(.horizontal, 12).padding(.vertical, 8).background(Color.white.opacity(0.05), in: Capsule()) }.padding(.horizontal, 28).padding(.vertical, 18)
                Divider().overlay(.white.opacity(0.06))
                Group { switch page {
                    case .dashboard: DashboardView()
                    case .keys: KeysView()
                    case .lighting: LightingView()
                    case .profiles: ProfilesView()
                    case .macros: MacrosView()
                    case .updates: UpdatesView()
                }}.frame(maxWidth: .infinity, maxHeight: .infinity)
            }.background(Color(red: 0.105, green: 0.11, blue: 0.12))
        }.foregroundStyle(.white)
    }
}

struct Panel<Content: View>: View {
    let title: String; @ViewBuilder var content: Content
    var body: some View { VStack(alignment: .leading, spacing: 16) { Text(title).font(.system(size: 13, weight: .semibold)); content }.padding(18).background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12)).overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.07))) }
}
