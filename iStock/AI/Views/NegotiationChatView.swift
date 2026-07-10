<<<<<<< HEAD
//
//  NegotiationChatView.swift
//  iStock
//
//  Created by Luan Carlos on 08/07/26.
//


import SwiftUI

struct NegotiationChatView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "handshake.fill")
                .font(.system(size: 70))
                .foregroundStyle(.green)

            Text("Assistente de Negociação")
                .font(.largeTitle.bold())

            Text("""
Descreva a negociação normalmente.

Exemplo:

• Cliente quer pagar R$ 3.900.

• Cliente quer trocar um iPhone 13 em um 15 Pro.

• Cliente pediu desconto.
""")
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)

            Spacer()

        }
        .padding()
        .navigationTitle("Negociação")
    }

=======
import SwiftUI

struct NegotiationChatView: View {
    @StateObject private var viewModel = NegociacaoChatViewModel()
    @State private var texto = ""
    @FocusState private var campoFocado: Bool

    private let verdeNegociacao = Color(red: 0.18, green: 0.72, blue: 0.45)

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            cabecalhoChat

                            ForEach(viewModel.mensagens) { mensagem in
                                BolhaNegociacaoView(
                                    mensagem: mensagem,
                                    corAssistente: verdeNegociacao
                                )
                                .id(mensagem.id)
                            }

                            if viewModel.processando {
                                indicadorDigitando
                                    .id("digitando")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: viewModel.mensagens.count) { _, _ in
                        rolarParaFinal(proxy: proxy)
                    }
                    .onChange(of: viewModel.processando) { _, processando in
                        if processando {
                            withAnimation { proxy.scrollTo("digitando", anchor: .bottom) }
                        }
                    }
                }

                sugestoesRapidas

                barraEntrada
            }
        }
        .navigationTitle("Negociação")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.limparConversa()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundStyle(AppTheme.azulClaro)
                }
                .disabled(viewModel.processando)
            }
        }
        .onAppear { viewModel.iniciar() }
        .preferredColorScheme(.dark)
    }

    // MARK: - Subviews

    private var cabecalhoChat: some View {
        VStack(spacing: 8) {
            Image(systemName: "handshake.fill")
                .font(.system(size: 36))
                .foregroundStyle(verdeNegociacao)
                .padding(.top, 4)

            Text("Descreva a negociação")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            Text("Descontos, trocas, contrapropostas e fechamento")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }

    private var indicadorDigitando: some View {
        HStack {
            HStack(spacing: 6) {
                ProgressView()
                    .controlSize(.small)
                    .tint(verdeNegociacao)
                Text("Digitando...")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Spacer(minLength: 48)
        }
    }

    private var sugestoesRapidas: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.sugestoes) { sugestao in
                    Button {
                        Task { await viewModel.usarSugestao(sugestao) }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: sugestao.icone)
                                .font(.caption)
                            Text(sugestao.texto)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.08), in: Capsule())
                        .overlay {
                            Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.processando)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.white.opacity(0.03))
    }

    private var barraEntrada: some View {
        HStack(spacing: 12) {
            TextField("Ex: cliente quer pagar R$ 3.900...", text: $texto, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .foregroundStyle(.white)
                .focused($campoFocado)
                #if os(iOS)
                .textInputAutocapitalization(.sentences)
                #endif

            Button {
                Task { await enviarMensagem() }
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundStyle(
                        podeEnviar ? verdeNegociacao : .white.opacity(0.3)
                    )
            }
            .disabled(!podeEnviar)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.06))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
        }
    }

    private var podeEnviar: Bool {
        !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.processando
    }

    private func enviarMensagem() async {
        let mensagem = texto
        texto = ""
        campoFocado = false
        await viewModel.enviar(mensagem)
    }

    private func rolarParaFinal(proxy: ScrollViewProxy) {
        if let ultima = viewModel.mensagens.last?.id {
            withAnimation { proxy.scrollTo(ultima, anchor: .bottom) }
        }
    }
}

// MARK: - Bolha de mensagem

private struct BolhaNegociacaoView: View {
    let mensagem: MensagemNegociacao
    let corAssistente: Color

    private var ehUsuario: Bool { mensagem.papel == .usuario }

    var body: some View {
        HStack(alignment: .top) {
            if ehUsuario { Spacer(minLength: 48) }

            VStack(alignment: ehUsuario ? .trailing : .leading, spacing: 4) {
                if !ehUsuario {
                    Label("Assistente", systemImage: "sparkles")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(corAssistente)
                }

                Text(mensagem.texto.attributedMarkdown)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(ehUsuario ? .trailing : .leading)
                    .padding(12)
                    .background(fundoBolha, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text(Formatters.dataCurta.string(from: mensagem.data))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
            }

            if !ehUsuario { Spacer(minLength: 48) }
        }
    }

    private var fundoBolha: some ShapeStyle {
        if ehUsuario {
            return AnyShapeStyle(AppTheme.gradienteBotao)
        }
        return AnyShapeStyle(Color.white.opacity(0.1))
    }
}

private extension String {
    var attributedMarkdown: AttributedString {
        (try? AttributedString(markdown: self, options: AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        ))) ?? AttributedString(self)
    }
}

#Preview {
    NavigationStack {
        NegotiationChatView()
    }
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
}
