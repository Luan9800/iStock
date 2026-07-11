//
//  AppleConsultantView.swift
//  iStock
//

import SwiftUI

struct AppleConsultantView: View {
    let modoInicial: ModoConsultorApple

    @StateObject private var viewModel = ConsultorAppleChatViewModel()

    init(modo: ModoConsultorApple = .cliente) {
        self.modoInicial = modo
    }

    var body: some View {
        AssistenteChatView(
            titulo: modoInicial.titulo,
            sugestoes: modoInicial.sugestoesChat,
            mensagens: viewModel.mensagens,
            processando: viewModel.processando,
            onEnviar: { texto in await viewModel.enviar(texto) },
            onLimpar: { viewModel.limparConversa() }
        )
        .onAppear {
            viewModel.modo = modoInicial
            viewModel.iniciar()
        }
    }
}

// MARK: - Chat compartilhado do Assistente

struct FormatarRespostaIAView: View {
    let texto: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(texto.components(separatedBy: "\n").enumerated()), id: \.offset) { _, linha in
                if linha.trimmingCharacters(in: .whitespaces).isEmpty {
                    Spacer().frame(height: 4)
                } else if linha.hasPrefix("### ") {
                    Text(String(linha.dropFirst(4)))
                        .font(.subheadline.weight(.bold))
                } else {
                    Text(linha.replacingOccurrences(of: "**", with: ""))
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct AssistenteChatView: View {
    let titulo: String
    let sugestoes: [String]
    let mensagens: [MensagemNegociacao]
    let processando: Bool
    let onEnviar: (String) async -> Void
    let onLimpar: () -> Void

    @State private var texto = ""
    @FocusState private var campoFocado: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(mensagens) { mensagem in
                            bolha(mensagem)
                                .id(mensagem.id)
                        }

                        if processando {
                            HStack {
                                ProgressView()
                                    .tint(AppTheme.azulClaro)
                                Text("Assistente pensando…")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            .id("digitando")
                        }
                    }
                    .padding()
                }
                .onChange(of: mensagens.count) { _, _ in
                    scrollParaFim(proxy)
                }
                .onChange(of: processando) { _, ativo in
                    if ativo { scrollParaFim(proxy) }
                }
            }

            if !processando && !sugestoes.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(sugestoes, id: \.self) { sugestao in
                            Button {
                                Task { await onEnviar(sugestao) }
                            } label: {
                                Text(sugestao)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.azulPrimario.opacity(0.35), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .disabled(processando)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }

            Divider()

            HStack(spacing: 10) {
                TextField("Descreva a situação…", text: $texto, axis: .vertical)
                    .lineLimit(1...4)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .focused($campoFocado)
                    .disabled(processando)
                    .onSubmit { enviar() }

                Button {
                    enviar()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            (texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || processando)
                                ? AppTheme.azulPrimario.opacity(0.35)
                                : AppTheme.azulPrimario,
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
                .disabled(texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || processando)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .navigationTitle(titulo)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    onLimpar()
                    texto = ""
                } label: {
                    Label("Nova conversa", systemImage: "plus.bubble")
                }
                .disabled(processando)
            }
        }
    }

    private func bolha(_ mensagem: MensagemNegociacao) -> some View {
        HStack {
            if mensagem.papel == .usuario { Spacer(minLength: 40) }

            VStack(alignment: mensagem.papel == .usuario ? .trailing : .leading, spacing: 6) {
                if mensagem.papel == .assistente {
                    Label("Assistente iStock", systemImage: "sparkles")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.azulClaro)
                }

                Group {
                    if mensagem.papel == .assistente {
                        FormatarRespostaIAView(texto: mensagem.texto)
                    } else {
                        Text(mensagem.texto)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                }
                .padding(12)
                .background(
                    mensagem.papel == .usuario
                        ? AppTheme.azulPrimario.opacity(0.85)
                        : Color.white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )

                Text(mensagem.data, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if mensagem.papel == .assistente { Spacer(minLength: 40) }
        }
    }

    private func enviar() {
        let pergunta = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !pergunta.isEmpty else { return }
        texto = ""
        campoFocado = false
        Task { await onEnviar(pergunta) }
    }

    private func scrollParaFim(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation {
                if processando {
                    proxy.scrollTo("digitando", anchor: .bottom)
                } else if let ultima = mensagens.last?.id {
                    proxy.scrollTo(ultima, anchor: .bottom)
                }
            }
        }
    }
}
