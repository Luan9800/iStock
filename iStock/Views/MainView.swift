//
//  MainView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

enum SidebarItem: String, Identifiable, CaseIterable, Hashable {
    case cadastro
    case produtos

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cadastro: return "Cadastrar"
        case .produtos: return "Produtos"
        }
    }

    var symbol: String {
        switch self {
        case .cadastro: return "plus.rectangle.on.rectangle"
        case .produtos: return "shippingbox"
        }
    }
}

struct MainView: View {
    @ObservedObject private var auth = AuthService.shared
    @State private var selection: SidebarItem? = .cadastro

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selection) { item in
                Label(item.title, systemImage: item.symbol)
            }
            .listStyle(.sidebar)
            .navigationTitle("iStock")
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 280)
        } detail: {
            Group {
                switch selection {
                case .cadastro:
                    CadastroProdutoView()
                case .produtos:
                    ListaProdutosView()
                case .none:
                    ContentUnavailableView(
                        "Selecione uma opção",
                        systemImage: "sidebar.left",
                        description: Text("Escolha uma seção na barra lateral.")
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        #if os(macOS)
        .frame(minWidth: 900, minHeight: 600)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if auth.estaLogado {
                    Label(auth.nomeOuEmail, systemImage: "person.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
