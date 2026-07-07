//
//  PesquisaDefeitosView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct PesquisaDefeitosView: View {
    @State private var tipoSelecionado: TipoProduto?
    @State private var modelo = ""
    @State private var numeracao = ""
    @State private var resultado: ModeloDefeitosService.ResultadoPesquisa?
    @State private var pesquisou = false

    var body: some View {
        LayoutTelaView(
            titulo: "Pesquisa de defeitos",
            subtitulo: "Consulte falhas conhecidas por modelo ou numeração Axxxx"
        ) {
            VStack(alignment: .leading, spacing: 20) {
                formularioBusca
                sugestoesRapidas

                if pesquisou {
                    resultadoBusca
                }
            }
        }
    }

    private var formularioBusca: some View {
        CartaoVidroView {
            VStack(alignment: .leading, spacing: 16) {
                Label("Buscar aparelho", systemImage: "magnifyingglass")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Informe o modelo comercial (ex: iPhone 14 Pro) e/ou a numeração do aparelho (ex: A2650), encontrada na caixa ou em Ajustes → Geral → Sobre.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))

                tipoPicker

                CampoAppView(
                    icone: "iphone",
                    placeholder: "Modelo (ex: iPhone 14 Pro Max)",
                    texto: $modelo
                )

                CampoAppView(
                    icone: "number",
                    placeholder: "Numeração / modelo Axxxx (ex: A2650)",
                    texto: $numeracao
                )

                HStack(spacing: 12) {
                    BotaoSecundarioView(titulo: "Limpar") {
                        limpar()
                    }
                    Spacer()
                    BotaoPrimarioView(
                        titulo: "Pesquisar",
                        desabilitado: !podePesquisar
                    ) {
                        executarPesquisa()
                    }
                    .frame(maxWidth: 180)
                }
            }
        }
    }

    private var tipoPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tipo de produto")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    botaoTipo(nil, titulo: "Automático")
                    ForEach(TipoProduto.allCases) { tipo in
                        botaoTipo(tipo, titulo: tipo.rawValue)
                    }
                }
            }
        }
    }

    private func botaoTipo(_ tipo: TipoProduto?, titulo: String) -> some View {
        Button {
            tipoSelecionado = tipo
        } label: {
            HStack(spacing: 6) {
                if let tipo {
                    Image(systemName: tipo.sfSymbol)
                        .font(.caption)
                }
                Text(titulo)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(tipoSelecionado == tipo ? .white : .white.opacity(0.55))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                if tipoSelecionado == tipo {
                    Capsule().fill(AppTheme.gradienteBotao)
                } else {
                    Capsule().fill(Color.white.opacity(0.08))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var sugestoesRapidas: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sugestões rápidas")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ModeloDefeitosService.sugestoesModelo(), id: \.self) { sugestao in
                        Button {
                            modelo = sugestao
                            executarPesquisa()
                        } label: {
                            Text(sugestao)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.azulClaro)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(AppTheme.azulPrimario.opacity(0.15), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var resultadoBusca: some View {
        if let resultado {
            if resultado.temResultado {
                CartaoVidroView {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            if let tipo = resultado.tipoProduto {
                                Image(systemName: tipo.sfSymbol)
                                    .font(.title2)
                                    .foregroundStyle(AppTheme.azulClaro)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(resultado.modeloIdentificado ?? "Modelo não identificado")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                HStack(spacing: 12) {
                                    if let tipo = resultado.tipoProduto {
                                        Text(tipo.rawValue)
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.45))
                                    }
                                    if let codigo = resultado.numeracaoIdentificada {
                                        Text("Nº \(codigo)")
                                            .font(.caption.monospaced())
                                            .foregroundStyle(AppTheme.azulClaro)
                                    }
                                }
                            }
                            Spacer()
                            BadgeAppView(
                                texto: "\(resultado.problemas.count) alerta(s)",
                                cor: .orange
                            )
                        }

                        Divider().overlay(Color.white.opacity(0.1))

                        SecaoProblemasModeloView(
                            problemas: resultado.problemas,
                            titulo: "Falhas e defeitos conhecidos"
                        )
                    }
                }
            } else {
                CartaoVidroView {
                    EstadoVazioView(
                        icone: "questionmark.circle",
                        titulo: "Nenhum resultado",
                        mensagem: "Não encontramos defeitos para os dados informados. Tente outro modelo ou a numeração Axxxx do aparelho."
                    )
                }
            }
        }
    }

    private var podePesquisar: Bool {
        !modelo.trimmingCharacters(in: .whitespaces).isEmpty
            || !numeracao.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func executarPesquisa() {
        pesquisou = true
        resultado = ModeloDefeitosService.pesquisar(
            tipo: tipoSelecionado,
            modelo: modelo,
            numeracao: numeracao
        )
    }

    private func limpar() {
        modelo = ""
        numeracao = ""
        tipoSelecionado = nil
        resultado = nil
        pesquisou = false
    }
}

#Preview {
    PesquisaDefeitosView()
}
