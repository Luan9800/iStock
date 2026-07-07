//
//  ListaClientesView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct ListaClientesView: View {
    @ObservedObject private var clienteService = ClienteService.shared
    @ObservedObject private var auth = AuthService.shared

    @State private var mostrandoCadastro = false
    @State private var clienteEditando: Cliente?

    var body: some View {
        LayoutTelaView(
            titulo: "Clientes",
            subtitulo: "Gerencie contatos e preferências de ofertas",
            trailing: {
                Button {
                    clienteEditando = nil
                    mostrandoCadastro = true
                } label: {
                    Label("Novo", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.gradienteBotao, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        ) {
            if clienteService.clientes.isEmpty {
                CartaoVidroView {
                    EstadoVazioView(
                        icone: "person.2",
                        titulo: "Nenhum cliente",
                        mensagem: "Cadastre clientes e defina quais ofertas eles desejam receber."
                    )
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(clienteService.clientes) { cliente in
                        ClienteRowView(
                            cliente: cliente,
                            onEditar: { clienteEditando = cliente },
                            onMensagem: { Task { await abrirMensagens(com: cliente) } }
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $mostrandoCadastro) {
            CadastroClienteView()
        }
        .sheet(item: $clienteEditando) { cliente in
            CadastroClienteView(clienteParaEditar: cliente)
        }
    }

    private func abrirMensagens(com cliente: Cliente) async {
        guard auth.estaLogado else { return }
        await NavegacaoApp.shared.abrirMensagens(com: cliente)
    }
}

struct ClienteRowView: View {
    let cliente: Cliente
    let onEditar: () -> Void
    let onMensagem: () -> Void

    var body: some View {
        ItemVidroView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.azulClaro)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cliente.nome)
                            .font(.headline)
                            .foregroundStyle(.white)
                        if let email = cliente.email {
                            Text(email)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        if let telefone = cliente.telefone, !telefone.isEmpty {
                            HStack(spacing: 4) {
                                Text(telefone)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                                if cliente.temWhatsApp {
                                    Image(systemName: "message.fill")
                                        .font(.caption2)
                                        .foregroundStyle(Color(red: 0.15, green: 0.78, blue: 0.44))
                                }
                            }
                        }
                    }
                    Spacer()

                    if cliente.temWhatsApp {
                        BotaoWhatsAppMensagemView(acao: onMensagem)
                    } else {
                        Button(action: onMensagem) {
                            Image(systemName: "bubble.left.fill")
                                .foregroundStyle(AppTheme.azulClaro)
                        }
                        .buttonStyle(.borderless)
                        .help("Conversar na aba Mensagens")
                    }
                }

                if !cliente.tiposNotificacao.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(cliente.tiposNotificacao) { tipo in
                                Label(tipo.rawValue, systemImage: tipo.sfSymbol)
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.azulClaro)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.azulPrimario.opacity(0.15), in: Capsule())
                            }
                        }
                    }
                } else {
                    Text("Sem preferências de notificação")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onEditar)
    }
}

#Preview {
    ListaClientesView()
}
