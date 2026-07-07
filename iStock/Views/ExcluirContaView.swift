//
//  ExcluirContaView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct ExcluirContaView: View {
    @ObservedObject private var auth = AuthService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var senha = ""

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    TituloTelaView(titulo: "Excluir conta", subtitulo: auth.descricaoMetodoExclusao)

                    CartaoVidroView {
                        VStack(alignment: .leading, spacing: 16) {
                            Label(
                                "Esta ação é permanente e não pode ser desfeita.",
                                systemImage: "exclamationmark.triangle.fill"
                            )
                            .font(.caption)
                            .foregroundStyle(.orange)

                            if auth.exigeSenhaParaExcluir {
                                CampoAppView(icone: "lock.fill", placeholder: "Senha", texto: $senha, ehSenha: true)
                            }

                            if let erro = auth.erro {
                                Label(erro, systemImage: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.9))
                            }

                            BotaoDestrutivoView(
                                titulo: "Excluir permanentemente",
                                desabilitado: botaoDesabilitado || auth.carregando
                            ) {
                                Task { await excluir() }
                            }

                            if auth.carregando {
                                ProgressView()
                                    .tint(AppTheme.azulClaro)
                                    .frame(maxWidth: .infinity)
                            }

                            Button("Cancelar") { dismiss() }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.azulClaro)
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: 440)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var botaoDesabilitado: Bool {
        auth.exigeSenhaParaExcluir && senha.isEmpty
    }

    private func excluir() async {
        auth.erro = nil
        await auth.excluirConta(senha: senha.isEmpty ? nil : senha)
        if auth.erro == nil && !auth.estaLogado {
            dismiss()
        }
    }
}

struct BotaoDestrutivoView: View {
    let titulo: String
    var desabilitado = false
    let acao: () -> Void

    var body: some View {
        Button(action: acao) {
            Text(titulo)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(desabilitado ? Color.white.opacity(0.15) : Color.red.opacity(0.85))
                }
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(desabilitado)
    }
}

#Preview {
    ExcluirContaView()
}
