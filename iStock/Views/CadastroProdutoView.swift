//
//  CadastroProdutoView.swift
//  iStock
//
//  Created by Luan Carlos on 04/07/26.
//

import SwiftUI

struct CadastroProdutoView: View {
    @ObservedObject private var service = LancamentoService.shared
    @ObservedObject private var auth = AuthService.shared

    @State private var dados = DadosProdutoFormulario()
    @State private var salvo = false
    @State private var salvando = false

    var body: some View {
        AppShellView(titulo: "Cadastrar Produto", subtitulo: "Adicione um novo item ao estoque Apple") {
            VStack(alignment: .leading, spacing: 20) {
                FormularioProdutoView(dados: $dados, criadoPor: auth.nomeOuEmail)

                if salvo {
                    Label("Produto salvo!", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.azulClaro)
                }

                if let erro = service.erro {
                    Text(erro)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.9))
                }

                BotaoPrimarioView(titulo: "Salvar Produto", desabilitado: !dados.valido || salvando) {
                    salvar()
                }
            }
        }
        .overlay {
            if salvando {
                ProgressView("Salvando...")
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
        }
    }

    private func salvar() {
        salvando = true
        let item = dados.paraLancamento(criadoPor: auth.nomeOuEmail)
        service.salvar(item)
        dados = DadosProdutoFormulario()
        salvando = false

        if service.erro == nil {
            salvo = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { salvo = false }
        }
    }
}

#Preview {
    CadastroProdutoView()
}
