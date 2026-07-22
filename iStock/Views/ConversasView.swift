//
//  ConversasView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct ConversasView: View {
    @ObservedObject private var chatService = ChatService.shared
    @ObservedObject private var auth = AuthService.shared
    @ObservedObject private var navegacao = NavegacaoApp.shared
    @ObservedObject private var clienteService = ClienteService.shared

    @State private var conversaSelecionada: Conversa?

    var body: some View {
        LayoutTelaView(
            titulo: "Mensagens",
            subtitulo: "\(chatService.conversas.count) conversa(s)",
            rolar: false
        ) {
            #if os(macOS)
            layoutMensagensMac
            #else
            layoutMensagensIOS
            #endif
        }
        .onAppear {
            if let uid = auth.uid {
                chatService.iniciarConversasListener(uid: uid)
            }
            selecionarConversaDestino()
        }
        .onChange(of: navegacao.conversaDestino) { _, _ in
            selecionarConversaDestino()
        }
        .onChange(of: chatService.conversas) { _, _ in
            selecionarConversaDestino()
        }
    }

    // MARK: - macOS (layout WEB: lista 280 + chat)

    #if os(macOS)
    private var layoutMensagensMac: some View {
        HStack(spacing: 16) {
            listaConversasMac
                .frame(width: 280)
                .frame(maxHeight: .infinity)

            chatPainelMac
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minHeight: 420)
    }

    private var listaConversasMac: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !auth.estaLogado {
                EstadoVazioView(
                    icone: "person.crop.circle.badge.exclamationmark",
                    titulo: "Faça login",
                    mensagem: "Entre na sua conta para acessar as mensagens."
                )
            } else if chatService.conversas.isEmpty {
                EstadoVazioView(
                    icone: "bubble.left.and.bubble.right",
                    titulo: "Nenhuma conversa",
                    mensagem: "Inicie uma conversa com um cliente na aba Clientes."
                )
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(chatService.conversas) { conversa in
                            Button {
                                conversaSelecionada = conversa
                            } label: {
                                ConversaMsgCardView(
                                    conversa: conversa,
                                    selecionada: conversaSelecionada?.id == conversa.id,
                                    temWhatsApp: clienteService.clientes
                                        .first { $0.id == conversa.clienteId }?.temWhatsApp ?? false
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.trailing, 4)
                }
            }
        }
        .padding(.trailing, 12)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1)
        }
    }

    private var chatPainelMac: some View {
        Group {
            if let conversa = conversaSelecionada {
                ChatView(
                    conversa: conversa,
                    cliente: cliente(da: conversa)
                )
            } else {
                EstadoVazioView(
                    icone: "bubble.left.and.bubble.right",
                    titulo: "Selecione uma conversa",
                    mensagem: "Escolha uma conversa para começar a enviar mensagens."
                )
            }
        }
        .id(conversaSelecionada?.id)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.04))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    #endif

    // MARK: - iOS

    #if os(iOS)
    private var layoutMensagensIOS: some View {
        NavigationSplitView {
            Group {
                if !auth.estaLogado {
                    EstadoVazioView(
                        icone: "person.crop.circle.badge.exclamationmark",
                        titulo: "Faça login",
                        mensagem: "Entre na sua conta para acessar as mensagens."
                    )
                } else if chatService.conversas.isEmpty {
                    EstadoVazioView(
                        icone: "bubble.left.and.bubble.right",
                        titulo: "Nenhuma conversa",
                        mensagem: "Inicie uma conversa com um cliente na aba Clientes."
                    )
                } else {
                    List {
                        ForEach(chatService.conversas) { conversa in
                            Button {
                                conversaSelecionada = conversa
                            } label: {
                                ConversaRowView(
                                    conversa: conversa,
                                    temWhatsApp: clienteService.clientes
                                        .first { $0.id == conversa.clienteId }?.temWhatsApp ?? false
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(
                                conversaSelecionada?.id == conversa.id
                                    ? AppTheme.azulPrimario.opacity(0.25)
                                    : Color.clear
                            )
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationSplitViewColumnWidth(min: 260, ideal: 300, max: 360)
        } detail: {
            ZStack {
                FundoTecnologicoView()

                Group {
                    if let conversa = conversaSelecionada {
                        ChatView(
                            conversa: conversa,
                            cliente: cliente(da: conversa)
                        )
                    } else {
                        EstadoVazioView(
                            icone: "bubble.left.and.bubble.right",
                            titulo: "Selecione uma conversa",
                            mensagem: "Escolha uma conversa para começar a enviar mensagens."
                        )
                    }
                }
            }
            .id(conversaSelecionada?.id)
        }
        .frame(minHeight: 420)
    }
    #endif

    private func selecionarConversaDestino() {
        guard let destino = navegacao.conversaDestino else { return }

        if let atualizada = chatService.conversas.first(where: { $0.id == destino.id }) {
            conversaSelecionada = atualizada
        } else {
            conversaSelecionada = destino
        }
    }

    private func cliente(da conversa: Conversa) -> Cliente? {
        clienteService.clientes.first { $0.id == conversa.clienteId }
    }
}

/// Card de conversa no estilo WEB `.conversa-msg-card` (Mac).
struct ConversaMsgCardView: View {
    let conversa: Conversa
    var selecionada = false
    var temWhatsApp = false

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppTheme.azulPrimario.opacity(0.22))
                .frame(width: 44, height: 44)
                .overlay {
                    if temWhatsApp {
                        Image(systemName: "message.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(red: 0.15, green: 0.78, blue: 0.44))
                    } else {
                        Text(String(conversa.clienteNome.prefix(1)).uppercased())
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.azulClaro)
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(conversa.clienteNome)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                if let ultima = conversa.ultimaMensagem {
                    Text(ultima)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 4)

            if let data = conversa.ultimaMensagemData {
                Text(Formatters.dataCurta.string(from: data))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.gradienteSecao(AppTheme.azulClaro))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    selecionada ? AppTheme.azulClaro.opacity(0.55) : AppTheme.azulClaro.opacity(0.28),
                    lineWidth: selecionada ? 1.5 : 1
                )
        }
        .shadow(color: .black.opacity(selecionada ? 0.35 : 0.28), radius: selecionada ? 14 : 12, x: 0, y: selecionada ? 12 : 10)
        .shadow(color: AppTheme.azulPrimario.opacity(selecionada ? 0.28 : 0.18), radius: selecionada ? 14 : 11, x: 0, y: selecionada ? 12 : 10)
    }
}

struct ConversaRowView: View {
    let conversa: Conversa
    var temWhatsApp = false

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppTheme.azulPrimario.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay {
                    if temWhatsApp {
                        Image(systemName: "message.fill")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.15, green: 0.78, blue: 0.44))
                    } else {
                        Text(String(conversa.clienteNome.prefix(1)).uppercased())
                            .font(.headline)
                            .foregroundStyle(AppTheme.azulClaro)
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(conversa.clienteNome)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                if let ultima = conversa.ultimaMensagem {
                    Text(ultima)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }

            Spacer()

            if let data = conversa.ultimaMensagemData {
                Text(Formatters.dataCurta.string(from: data))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ConversasView()
}
