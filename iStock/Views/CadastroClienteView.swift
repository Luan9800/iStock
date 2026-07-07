//
//  CadastroClienteView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct CadastroClienteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var service = ClienteService.shared
    @ObservedObject private var auth = AuthService.shared

    var clienteParaEditar: Cliente?

    @State private var nome = ""
    @State private var email = ""
    @State private var telefone = ""
    @State private var possuiWhatsApp = false
    @State private var tiposNotificacao: Set<TipoProduto> = []
    @State private var salvo = false

    private var titulo: String {
        clienteParaEditar == nil ? "Cadastrar Cliente" : "Editar Cliente"
    }

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TituloTelaView(titulo: titulo, subtitulo: "Dados e preferências de notificação")

                    CartaoVidroView {
                        VStack(alignment: .leading, spacing: 20) {
                            CampoAppView(icone: "person", placeholder: "Nome completo", texto: $nome)
                            CampoAppView(icone: "envelope", placeholder: "E-mail", texto: $email)
                            CampoAppView(icone: "phone", placeholder: "Telefone", texto: $telefone)

                            Toggle(isOn: $possuiWhatsApp) {
                                Label("Possui WhatsApp", systemImage: "message.fill")
                                    .foregroundStyle(.white)
                            }
                            .tint(.green)
                            .disabled(telefone.trimmingCharacters(in: .whitespaces).isEmpty)
                            .onChange(of: telefone) { _, novo in
                                if novo.trimmingCharacters(in: .whitespaces).isEmpty {
                                    possuiWhatsApp = false
                                }
                            }

                            if possuiWhatsApp {
                                Text("Você poderá enviar mensagens pelo app na aba Mensagens.")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.45))
                            }

                            SelecaoNotificacaoView(selecionados: $tiposNotificacao)

                            if salvo {
                                Label("Cliente salvo!", systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.azulClaro)
                            }

                            HStack(spacing: 12) {
                                BotaoSecundarioView(titulo: "Cancelar") { dismiss() }
                                Spacer()
                                BotaoPrimarioView(
                                    titulo: "Salvar Cliente",
                                    desabilitado: nome.trimmingCharacters(in: .whitespaces).isEmpty
                                ) {
                                    salvar()
                                }
                                .frame(maxWidth: 200)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { carregarDados() }
    }

    private func carregarDados() {
        guard let cliente = clienteParaEditar else { return }
        nome = cliente.nome
        email = cliente.email ?? ""
        telefone = cliente.telefone ?? ""
        possuiWhatsApp = cliente.possuiWhatsApp
        tiposNotificacao = Set(cliente.tiposNotificacao)
    }

    private func salvar() {
        let cliente = Cliente(
            id: clienteParaEditar?.id,
            nome: nome.trimmingCharacters(in: .whitespaces),
            email: email.isEmpty ? nil : email,
            telefone: telefone.isEmpty ? nil : telefone,
            possuiWhatsApp: possuiWhatsApp,
            tiposNotificacao: Array(tiposNotificacao),
            ativo: true,
            data: clienteParaEditar?.data ?? .now,
            criadoPor: auth.nomeOuEmail
        )
        service.salvar(cliente)
        salvo = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
    }
}

#Preview {
    CadastroClienteView()
}
