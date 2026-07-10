//
<<<<<<< HEAD
//  AppleConsul.swift
=======
//  AppleConsultantView.swift
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
//  iStock
//
//  Created by Luan Carlos on 08/07/26.
//

import SwiftUI

struct AppleConsultantView: View {
<<<<<<< HEAD
    var body: some View {
        
        List {
            Section("Esse atendimento é para") {
                NavigationLink("Meu cliente") {
                    
                    Text("Chat para vendas")
                        .navigationTitle("Consultor Apple")
                    
                }
                
                NavigationLink("Minha dúvida pessoal") {
                    Text("Chat técnico Apple")
                        .navigationTitle("Consultor Apple")
                }
            }
        }
        .navigationTitle("Consultor Apple")
        
=======
    @StateObject private var viewModel = ConsultorAppleChatViewModel()
    @State private var texto = ""
    @FocusState private var campoFocado: Bool

    private let azulConsultor = Color(red: 0.35, green: 0.55, blue: 0.78)

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            VStack(spacing: 0) {
                seletorModo

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            cabecalhoChat

                            ForEach(viewModel.mensagens) { mensagem in
                                BolhaConsultorView(
                                    mensagem: mensagem,
                                    corAssistente: azulConsultor
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
        .navigationTitle("Consultor Apple")
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

    private var seletorModo: some View {
        Picker("Modo", selection: Binding(
            get: { viewModel.modo },
            set: { viewModel.alterarModo($0) }
        )) {
            ForEach(ModoConsultorApple.allCases) { modo in
                Label(modo.titulo, systemImage: modo.icone)
                    .tag(modo)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.04))
    }

    private var cabecalhoChat: some View {
        VStack(spacing: 8) {
            Image(systemName: "apple.logo")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(azulConsultor)
                .padding(.top, 4)

            Text(viewModel.modo == .cliente ? "Argumentos para seu cliente" : "Tire sua dúvida")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            Text("Vendas, comparação de modelos e ecossistema")
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
                    .tint(azulConsultor)
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
            TextField("Ex: iPhone 14 ou 15 Pro?", text: $texto, axis: .vertical)
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
                        podeEnviar ? azulConsultor : .white.opacity(0.3)
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

private struct BolhaConsultorView: View {
    let mensagem: MensagemNegociacao
    let corAssistente: Color

    private var ehUsuario: Bool { mensagem.papel == .usuario }

    var body: some View {
        HStack(alignment: .top) {
            if ehUsuario { Spacer(minLength: 48) }

            VStack(alignment: ehUsuario ? .trailing : .leading, spacing: 4) {
                if !ehUsuario {
                    Label("Consultor Apple", systemImage: "apple.logo")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(corAssistente)
                }

                Text(mensagem.texto.textoMarkdown)
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
    var textoMarkdown: AttributedString {
        (try? AttributedString(markdown: self, options: AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        ))) ?? AttributedString(self)
    }
}

#Preview {
    NavigationStack {
        AppleConsultantView()
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
    }
}
