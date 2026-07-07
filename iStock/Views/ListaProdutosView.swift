//
//  ListaProdutosView.swift
//  iStock
//
//  Created by Luan Carlos on 04/07/26.
//

import Combine
import SwiftUI

enum FiltroEstoque: String, CaseIterable, Identifiable {
    case todos = "Todos"
    case disponivel = "Disponíveis"
    case reservado = "Reservados"
    case vendido = "Vendidos"
    case parados = "Parados"

    var id: String { rawValue }
}

struct ListaProdutosView: View {
    @ObservedObject private var service = LancamentoService.shared

    @State private var busca = ""
    @State private var filtro: FiltroEstoque = .todos
    @State private var ordenacao: OrdenacaoProduto = .dataRecente
    @State private var produtoSelecionado: Lancamento?

    private let colunas = [
        GridItem(.adaptive(minimum: 220), spacing: 16)
    ]

    private var produtosFiltrados: [Lancamento] {
        var lista = service.lancamentos

        switch filtro {
        case .todos: break
        case .disponivel: lista = lista.filter { $0.status == .disponivel }
        case .reservado: lista = lista.filter { $0.status == .reservado }
        case .vendido: lista = lista.filter { $0.status == .vendido }
        case .parados: lista = lista.filter(\.estaHaMuitoTempoNoEstoque)
        }

        if !busca.isEmpty {
            let termo = busca.lowercased()
            lista = lista.filter {
                $0.nome.lowercased().contains(termo)
                || ($0.modelo?.lowercased().contains(termo) ?? false)
                || ($0.serial?.lowercased().contains(termo) ?? false)
                || ($0.cor?.lowercased().contains(termo) ?? false)
                || $0.tipoProduto.rawValue.lowercased().contains(termo)
            }
        }

        switch ordenacao {
        case .dataRecente: lista.sort { $0.data > $1.data }
        case .dataAntiga: lista.sort { $0.data < $1.data }
        case .precoMaior: lista.sort { $0.valor > $1.valor }
        case .precoMenor: lista.sort { $0.valor < $1.valor }
        case .nome: lista.sort { $0.tituloExibicao.localizedCompare($1.tituloExibicao) == .orderedAscending }
        }

        return lista
    }

    var body: some View {
        LayoutTelaView(
            titulo: "Produtos",
            subtitulo: "\(service.noEstoque.count) em estoque · \(service.vendidos.count) vendidos"
        ) {
            VStack(alignment: .leading, spacing: 16) {
                barraBusca
                filtros
                ordenacaoPicker

                if !service.paradosNoEstoque.isEmpty && filtro != .parados {
                    alertaEstoqueBanner
                }

                if produtosFiltrados.isEmpty {
                    CartaoVidroView {
                        EstadoVazioView(
                            icone: "shippingbox",
                            titulo: "Nenhum produto",
                            mensagem: busca.isEmpty
                                ? "Cadastre seu primeiro produto na aba Cadastrar."
                                : "Nenhum resultado para \"\(busca)\"."
                        )
                    }
                } else {
                    LazyVGrid(columns: colunas, spacing: 16) {
                        ForEach(produtosFiltrados) { item in
                            Button {
                                produtoSelecionado = item
                            } label: {
                                ProdutoCardView(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .sheet(item: $produtoSelecionado) { produto in
            DetalheProdutoView(produto: produto)
        }
    }

    private var barraBusca: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.45))
            TextField("Buscar por nome, modelo, serial...", text: $busca)
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var filtros: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FiltroEstoque.allCases) { item in
                    Button {
                        filtro = item
                    } label: {
                        Text(item.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(filtro == item ? .white : .white.opacity(0.55))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background {
                                if filtro == item {
                                    Capsule().fill(AppTheme.gradienteBotao)
                                } else {
                                    Capsule().fill(Color.white.opacity(0.08))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var ordenacaoPicker: some View {
        HStack {
            Text("Ordenar:")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
            Picker("Ordenação", selection: $ordenacao) {
                ForEach(OrdenacaoProduto.allCases) { ordem in
                    Text(ordem.rawValue).tag(ordem)
                }
            }
            .labelsHidden()
            .tint(AppTheme.azulClaro)
        }
    }

    private var alertaEstoqueBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
            Text("\(service.paradosNoEstoque.count) produto(s) há mais de \(Lancamento.diasLimiteEstoque) dias no estoque")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.red.opacity(0.35), lineWidth: 1)
        }
    }
}

struct ProdutoCardView: View {
    let item: Lancamento

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: item.tipoProduto.sfSymbol)
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.azulClaro)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.azulPrimario.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))

                if item.estaHaMuitoTempoNoEstoque {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                }

                Spacer()

                BadgeAppView(texto: item.status.rawValue, cor: item.status.cor)
            }

            Text(item.tituloExibicao)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(2)

            if !item.descricaoCompleta.isEmpty && item.modelo != item.nome {
                Text(item.descricaoCompleta)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
            }

            if let telefone = item.telefone, !telefone.isEmpty {
                Label(telefone, systemImage: "phone.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }

            if let serial = item.serial, !serial.isEmpty {
                Label(serial, systemImage: "barcode")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(1)
            }

            HStack(spacing: 6) {
                if item.lacrado {
                    BadgeAppView(texto: "Lacrado", cor: AppTheme.azulClaro)
                } else if let cond = item.condicaoPercentual {
                    BadgeAppView(texto: "\(cond)%", cor: .orange)
                }
                if item.estaHaMuitoTempoNoEstoque {
                    BadgeAppView(texto: "\(item.diasNoEstoque)d", cor: .red)
                }
            }

            Spacer(minLength: 4)

            HStack {
                Text(Formatters.brl(item.valor))
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Spacer()
                Text(Formatters.dataCurta.string(from: item.data))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .padding(14)
        .frame(minHeight: 170)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    item.estaHaMuitoTempoNoEstoque ? Color.red.opacity(0.55) : Color.white.opacity(0.1),
                    lineWidth: item.estaHaMuitoTempoNoEstoque ? 2 : 1
                )
        )
    }
}

#Preview {
    ListaProdutosView()
}
