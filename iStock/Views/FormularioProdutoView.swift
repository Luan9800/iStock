//
//  FormularioProdutoView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct DadosProdutoFormulario {
    var nome = ""
    var modelo = ""
    var capacidade = ""
    var cor = ""
    var telefone = ""
    var serial = ""
    var tipoProduto: TipoProduto = .iphone
    var lacrado = false
    var condicaoPercentual: Double = 100
    var custoCompra: Double = 0
    var valor: Double = 0
    var observacoes = ""

    init() {}

    init(de item: Lancamento) {
        nome = item.nome
        modelo = item.modelo ?? ""
        capacidade = item.capacidade ?? ""
        cor = item.cor ?? ""
        telefone = item.telefone ?? ""
        serial = item.serial ?? ""
        tipoProduto = item.tipoProduto
        lacrado = item.lacrado
        condicaoPercentual = Double(item.condicaoPercentual ?? 100)
        custoCompra = item.custoCompra ?? 0
        valor = item.valor
        observacoes = item.observacoes ?? ""
    }

    func paraLancamento(id: String? = nil, status: StatusProduto = .disponivel, criadoPor: String?) -> Lancamento {
        Lancamento(
            id: id,
            nome: nome.trimmingCharacters(in: .whitespaces),
            tipoProduto: tipoProduto,
            modelo: modelo.isEmpty ? nil : modelo,
            capacidade: capacidade.isEmpty ? nil : capacidade,
            cor: cor.isEmpty ? nil : cor,
            telefone: telefone.isEmpty ? nil : telefone,
            serial: serial.isEmpty ? nil : serial,
            lacrado: lacrado,
            condicaoPercentual: lacrado ? nil : Int(condicaoPercentual),
            custoCompra: custoCompra > 0 ? custoCompra : nil,
            valor: valor,
            status: status,
            criadoPor: criadoPor,
            observacoes: observacoes.isEmpty ? nil : observacoes
        )
    }

    var valido: Bool {
        !nome.isEmpty && !telefone.isEmpty && valor > 0
    }
}

struct FormularioProdutoView: View {
    @Binding var dados: DadosProdutoFormulario
    let cadastroId: String
    let criadoPor: String?
    var mostrarGaleria = true
    var modoAvaliacao = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            seletorTipo

            if mostrarGaleria, let criadoPor {
                GaleriaModeloView(cadastroId: cadastroId, tipo: dados.tipoProduto, criadoPor: criadoPor)
            }

            CampoAppView(icone: "tag", placeholder: "Nome / descrição", texto: $dados.nome)
            CampoAppView(icone: "iphone", placeholder: "Modelo (ex: iPhone 15 Pro)", texto: $dados.modelo)

            if dados.tipoProduto.suportaCapacidade {
                CampoAppView(icone: "internaldrive", placeholder: "Capacidade (ex: 256GB)", texto: $dados.capacidade)
            }

            CampoAppView(icone: "paintpalette", placeholder: "Cor", texto: $dados.cor)
            CampoAppView(icone: "phone", placeholder: "Contato telefônico", texto: $dados.telefone)
            CampoAppView(icone: "barcode", placeholder: "Nº serial / IMEI", texto: $dados.serial)

            Toggle(isOn: $dados.lacrado) {
                Text("Lacrado (novo)")
                    .foregroundStyle(.white)
            }
            .tint(AppTheme.azulPrimario)

            if !dados.lacrado && dados.tipoProduto.suportaBateria {
                Text("Saúde da bateria: \(Int(dados.condicaoPercentual))%")
                    .foregroundStyle(.white.opacity(0.8))
                Slider(value: $dados.condicaoPercentual, in: 1...100, step: 1)
                    .tint(AppTheme.azulPrimario)
            }

            if !modoAvaliacao {
                campoMoeda(titulo: "Custo de compra", valor: $dados.custoCompra)
                campoMoeda(titulo: "Preço de venda", valor: $dados.valor)

                if dados.custoCompra > 0 && dados.valor > 0 {
                    let margem = dados.valor - dados.custoCompra
                    let pct = (margem / dados.custoCompra) * 100
                    Label(
                        "Margem: \(Formatters.brl(margem)) (\(String(format: "%.0f", pct))%)",
                        systemImage: "chart.line.uptrend.xyaxis"
                    )
                    .font(.caption)
                    .foregroundStyle(margem >= 0 ? AppTheme.azulClaro : .red)
                }
            }

            CampoAppView(icone: "note.text", placeholder: "Observações", texto: $dados.observacoes)
        }
    }

    private var seletorTipo: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
            ForEach(TipoProduto.allCases) { tipo in
                Button {
                    dados.tipoProduto = tipo
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tipo.sfSymbol)
                            .font(.system(size: 26))
                            .foregroundStyle(dados.tipoProduto == tipo ? AppTheme.azulClaro : .white.opacity(0.7))
                        Text(tipo.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        dados.tipoProduto == tipo ? AppTheme.azulPrimario.opacity(0.2) : Color.white.opacity(0.06),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(dados.tipoProduto == tipo ? AppTheme.azulClaro : .clear, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func campoMoeda(titulo: String, valor: Binding<Double>) -> some View {
        HStack(spacing: 12) {
            Text(titulo)
                .foregroundStyle(.white.opacity(0.8))
                .frame(width: 130, alignment: .leading)
            TextField("R$ 0,00", value: valor, format: .currency(code: "BRL"))
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .foregroundStyle(.white)
        }
    }
}
