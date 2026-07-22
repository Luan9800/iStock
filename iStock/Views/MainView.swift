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
        Group {
            #if os(macOS)
            layoutMac
            #else
            layoutIOS
            #endif
        }
        .preferredColorScheme(.dark)
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

    // MARK: - macOS (espelha MainLayout WEB)

    #if os(macOS)
    private var layoutMac: some View {
        ZStack {
            FundoTecnologicoView()

            HStack(spacing: 0) {
                sidebarMac
                    .frame(width: AppTheme.sidebarWidth)
                    .frame(maxHeight: .infinity)

                VStack(spacing: 0) {
                    topbarMac
                    detalheView
                        .id(selection)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 980, minHeight: 640)
    }

    private var sidebarMac: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text("iStock")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 18)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 4) {
                    ForEach(abasPermitidas) { item in
                        Button {
                            selection = item
                        } label: {
                            HStack(spacing: 10) {
                                Label(item.title, systemImage: item.symbol)
                                    .font(.subheadline.weight(selection == item ? .semibold : .regular))
                                    .foregroundStyle(selection == item ? .white : .white.opacity(0.65))
                                Spacer(minLength: 4)
                                badgeSidebar(para: item)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 11)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                if selection == item {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(AppTheme.gradienteBotao)
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        selection == item ? AppTheme.azulClaro.opacity(0.4) : .clear,
                                        lineWidth: 1
                                    )
                            }
                            .shadow(
                                color: selection == item ? AppTheme.azulPrimario.opacity(0.28) : .clear,
                                radius: 10,
                                y: 4
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
            }

            Spacer(minLength: 12)

            Button {
                mostrandoExclusao = true
            } label: {
                Label("Excluir conta", systemImage: "trash")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.vermelho.opacity(0.9))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.bottom, 16)
        }
        .background {
            PainelSidebarView()
        }
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 1)
        }
    }

    private var topbarMac: some View {
        HStack(spacing: 12) {
            Spacer(minLength: 0)

            SyncStatusBanner()
                .frame(maxWidth: 320)

            if auth.estaLogado && auth.usandoLoginLocal {
                BadgeAppView(texto: "Local", cor: AppTheme.laranja)
            }

            if let papel = auth.papelAtual {
                BadgeAppView(texto: papel.rotuloExibicao, cor: papel.corMac, amplo: true)
            }

            Button {
                auth.sair()
            } label: {
                Label("Sair", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.azulClaro)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func badgeSidebar(para item: SidebarItem) -> some View {
        if item == .painel && !notificacoesPainel.naoLidas.isEmpty {
            Image(systemName: "bell.fill")
                .font(.caption)
                .foregroundStyle(AppTheme.laranja)
        }
        if item == .produtos && quantidadeParados > 0 {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption)
                .foregroundStyle(AppTheme.vermelho.opacity(0.85))
        }
        if item == .avaliacoes && !avaliacoes.emAvaliacao.isEmpty {
            Image(systemName: "clock.fill")
                .font(.caption)
                .foregroundStyle(AppTheme.laranja)
        }
        if item == .avaliacoes && !avaliacoes.aprovadasSemPagamento.isEmpty {
            Image(systemName: "banknote")
                .font(.caption)
                .foregroundStyle(AppTheme.laranja)
        }
    }
    #endif

    // MARK: - iOS (inalterado)

    #if os(iOS)
    private var layoutIOS: some View {
        NavigationSplitView {
            sidebarIOS
        } detail: {
            detalheView
                .id(selection)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .top, spacing: 0) {
                    SyncStatusBanner()
                }
        }
        .background {
            FundoTecnologicoView()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if auth.estaLogado && auth.usandoLoginLocal {
                    BadgeAppView(texto: "Local", cor: .orange)
                }
            }
            .semFundoAutomatico()
            ToolbarItem(placement: .automatic) {
                if let papel = auth.papelAtual {
                    BadgeAppView(texto: papel.rotuloExibicao, cor: papel.cor, amplo: true)
                }
            }
            .semFundoAutomatico()
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
    }

    private var sidebarIOS: some View {
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
    }
    #endif

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

#if os(macOS)
private extension PapelUsuario {
    var corMac: Color {
        switch self {
        case .administrador: return AppTheme.mint
        case .consultorVendas: return AppTheme.azulClaro
        case .cliente: return AppTheme.laranja
        }
    }
}
#endif

#Preview {
    MainView()
}
