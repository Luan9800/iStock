//
//  MainView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

enum SidebarItem: String, Identifiable, CaseIterable, Hashable {
    case painel
    case relatorios
    case avaliacoes
    case pesquisa
    case cadastro
    case produtos
    case clientes
    case mensagens
    case assistenteIA

    var id: String { rawValue }

    var title: String {
        switch self {
        case .painel: return "Painel"
        case .relatorios: return "Relatórios"
        case .avaliacoes: return "Avaliações"
        case .pesquisa: return "Pesquisa"
        case .cadastro: return "Cadastrar"
        case .produtos: return "Produtos"
        case .clientes: return "Clientes"
        case .mensagens: return "Mensagens"
        case .assistenteIA: return "Assistente de IA"
        }
    }

    var symbol: String {
        switch self {
        case .painel: return "chart.bar.doc.horizontal"
        case .relatorios: return "doc.richtext"
        case .avaliacoes: return "clock.badge.checkmark"
        case .pesquisa: return "magnifyingglass"
        case .cadastro: return "plus.rectangle.on.rectangle"
        case .produtos: return "shippingbox"
        case .clientes: return "person.2"
        case .mensagens: return "bubble.left.and.bubble.right"
        case .assistenteIA: return "sparkles"
        }
    }

    static func abas(para papel: PapelUsuario) -> [SidebarItem] {
        switch papel {
        case .administrador:
            return allCases
        case .consultorVendas:
            return [.painel, .avaliacoes, .pesquisa, .cadastro, .produtos, .clientes, .mensagens, .assistenteIA]
        case .cliente:
            return [.avaliacoes, .mensagens, .assistenteIA]
        }
    }
}

struct MainView: View {
    @ObservedObject private var auth = AuthService.shared
    @ObservedObject private var lancamentos = LancamentoService.shared
    @ObservedObject private var avaliacoes = AvaliacaoService.shared
    @ObservedObject private var notificacoesPainel = PainelNotificacaoService.shared
    @ObservedObject private var navegacao = NavegacaoApp.shared
    @State private var selection: SidebarItem = .painel
    @State private var mostrandoExclusao = false

    private var abasPermitidas: [SidebarItem] {
        SidebarItem.abas(para: auth.papelAtual ?? .consultorVendas)
    }

    private var quantidadeParados: Int {
        lancamentos.lancamentos.filter(\.estaHaMuitoTempoNoEstoque).count
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            VStack(spacing: 0) {
                SyncStatusBanner()
                detalheView
                    .id(selection)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background {
            FundoTecnologicoView()
        }
        #if os(macOS)
        .frame(minWidth: 900, minHeight: 600)
        #endif
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if auth.estaLogado && auth.usandoLoginLocal {
                    BadgeAppView(texto: "Local", cor: .orange)
                }
            }
            ToolbarItem(placement: .automatic) {
                if let papel = auth.papelAtual {
                    BadgeAppView(texto: papel.rotuloExibicao, cor: papel.cor, amplo: true)
                }
            }
            ToolbarItem(placement: .automatic) {
                if auth.estaLogado {
                    Menu {
                        Button("Sair", role: .destructive) { auth.sair() }
                        Button("Excluir conta", role: .destructive) { mostrandoExclusao = true }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(AppTheme.azulClaro)
                    }
                    .menuStyle(.borderlessButton)
                }
            }
        }
        .sheet(isPresented: $mostrandoExclusao) {
            ExcluirContaView()
        }
        .task {
            await EstoqueAlertaService.shared.solicitarPermissao()
            RelatorioMensalService.shared.verificarGeracaoAutomatica()
            PainelNotificacaoService.shared.verificarAvaliacoes(avaliacoes.avaliacoes)
        }
        .onChange(of: navegacao.abaDestino) { _, aba in
            if let aba {
                selection = aba
                navegacao.abaDestino = nil
            }
        }
        .onChange(of: auth.papelAtual) { _, _ in
            if !abasPermitidas.contains(selection), let primeira = abasPermitidas.first {
                selection = primeira
            }
        }
        .onAppear {
            if !abasPermitidas.contains(selection), let primeira = abasPermitidas.first {
                selection = primeira
            }
        }
    }

    private var sidebar: some View {
        List {
            ForEach(abasPermitidas) { item in
                Button {
                    selection = item
                } label: {
                    HStack {
                        Label(item.title, systemImage: item.symbol)
                            .foregroundStyle(selection == item ? .white : .white.opacity(0.65))
                        Spacer()
                        if item == .painel && !notificacoesPainel.naoLidas.isEmpty {
                            Image(systemName: "bell.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        if item == .produtos && quantidadeParados > 0 {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        if item == .avaliacoes && !avaliacoes.emAvaliacao.isEmpty {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        if item == .avaliacoes && !avaliacoes.aprovadasSemPagamento.isEmpty {
                            Image(systemName: "banknote")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .listRowBackground(
                    selection == item
                        ? Color.white.opacity(0.1)
                        : Color.clear
                )
                .tag(item)
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(PainelSidebarView())
        .navigationTitle("iStock")
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 280)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                HStack(spacing: 8) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
            }
        }
        #endif
    }

    @ViewBuilder
    private var detalheView: some View {
        switch selection {
        case .painel:
            PainelView()
        case .relatorios:
            RelatoriosView()
        case .avaliacoes:
            AvaliacoesView()
        case .pesquisa:
            PesquisaDefeitosView()
        case .cadastro:
            CadastroProdutoView()
        case .produtos:
            ListaProdutosView()
        case .clientes:
            ListaClientesView()
        case .mensagens:
            ConversasView()
        case .assistenteIA:
            NavigationStack {
                AssistenteIAView()
            }
        }
    }
}

#Preview {
    MainView()
}
