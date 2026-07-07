//
//  ChatView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import PhotosUI
#endif

struct ChatView: View {
    let conversa: Conversa
    var cliente: Cliente?

    @ObservedObject private var chatService = ChatService.shared
    @ObservedObject private var auth = AuthService.shared
    @StateObject private var gravador = AudioRecorder()
    @StateObject private var player = AudioPlayer()

    @State private var texto = ""
    @State private var enviando = false

    #if os(iOS)
    @State private var selectedItem: PhotosPickerItem?
    #else
    @State private var showingFileImporter = false
    #endif

    private var meuId: String { auth.uid ?? "" }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(chatService.mensagens) { mensagem in
                            MensagemBubbleView(
                                mensagem: mensagem,
                                ehMinha: mensagem.remetenteId == meuId,
                                player: player
                            )
                            .id(mensagem.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatService.mensagens.count) { _, _ in
                    if let ultima = chatService.mensagens.last?.id {
                        withAnimation { proxy.scrollTo(ultima, anchor: .bottom) }
                    }
                }
            }

            if gravador.gravando {
                HStack {
                    Image(systemName: "mic.fill")
                        .foregroundStyle(.red)
                    Text("Gravando... \(Int(gravador.duracao))s")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Cancelar") { gravador.cancelar() }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.white.opacity(0.7))
                    Button("Enviar") { Task { await enviarAudio() } }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.azulPrimario)
                }
                .padding()
                .background(Color.red.opacity(0.15))
            }

            HStack(spacing: 12) {
                #if os(iOS)
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(AppTheme.azulClaro)
                }
                .onChange(of: selectedItem) { _, item in
                    Task { await enviarFoto(from: item) }
                }
                #else
                Button { showingFileImporter = true } label: {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(AppTheme.azulClaro)
                }
                .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.image]) { result in
                    if case .success(let url) = result,
                       url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource() }
                        if let data = try? Data(contentsOf: url) {
                            Task { await enviarFotoData(data) }
                        }
                    }
                }
                #endif

                Button {
                    if gravador.gravando {
                        Task { await enviarAudio() }
                    } else {
                        gravador.iniciar()
                    }
                } label: {
                    Image(systemName: gravador.gravando ? "stop.circle.fill" : "mic")
                        .font(.title3)
                        .foregroundStyle(gravador.gravando ? .red : AppTheme.azulClaro)
                }

                TextField("Mensagem...", text: $texto)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .foregroundStyle(.white)
                    #if os(iOS)
                    .textInputAutocapitalization(.sentences)
                    #endif

                Button {
                    Task { await enviarTexto() }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(
                            texto.trimmingCharacters(in: .whitespaces).isEmpty || enviando
                                ? .white.opacity(0.3)
                                : AppTheme.azulClaro
                        )
                }
                .disabled(texto.trimmingCharacters(in: .whitespaces).isEmpty || enviando)
            }
            .padding()
            .background(Color.white.opacity(0.06))
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
            }
        }
        .navigationTitle(conversa.clienteNome)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .toolbar {
            if cliente?.temWhatsApp == true {
                ToolbarItem(placement: .automatic) {
                    HStack(spacing: 4) {
                        Image(systemName: "message.fill")
                            .foregroundStyle(Color(red: 0.15, green: 0.78, blue: 0.44))
                        Text("WhatsApp")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
        }
        .onAppear {
            if let id = conversa.id {
                chatService.observarMensagens(conversaId: id)
            }
        }
        .onDisappear {
            chatService.pararObservacaoMensagens()
            player.parar()
        }
    }

    private func enviarTexto() async {
        guard let conversaId = conversa.id,
              !texto.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        enviando = true
        let msg = texto
        texto = ""
        await chatService.enviarTexto(
            conversaId: conversaId,
            texto: msg,
            remetenteId: meuId,
            remetenteNome: auth.nomeOuEmail
        )
        enviando = false
    }

    #if os(iOS)
    private func enviarFoto(from item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let conversaId = conversa.id else { return }
        let comprimida = ImageCompressor.compressJPEG(data) ?? data
        await chatService.enviarFoto(
            conversaId: conversaId,
            data: comprimida,
            remetenteId: meuId,
            remetenteNome: auth.nomeOuEmail
        )
        selectedItem = nil
    }
    #endif

    private func enviarFotoData(_ data: Data) async {
        guard let conversaId = conversa.id else { return }
        let comprimida = ImageCompressor.compressJPEG(data) ?? data
        await chatService.enviarFoto(
            conversaId: conversaId,
            data: comprimida,
            remetenteId: meuId,
            remetenteNome: auth.nomeOuEmail
        )
    }

    private func enviarAudio() async {
        guard let conversaId = conversa.id,
              let resultado = gravador.parar() else { return }
        await chatService.enviarAudio(
            conversaId: conversaId,
            data: resultado.data,
            duracao: resultado.duracao,
            remetenteId: meuId,
            remetenteNome: auth.nomeOuEmail
        )
    }
}

struct MensagemBubbleView: View {
    let mensagem: Mensagem
    let ehMinha: Bool
    @ObservedObject var player: AudioPlayer

    var body: some View {
        HStack {
            if ehMinha { Spacer(minLength: 60) }

            VStack(alignment: ehMinha ? .trailing : .leading, spacing: 4) {
                if !ehMinha {
                    Text(mensagem.remetenteNome)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.45))
                }

                Group {
                    switch mensagem.tipo {
                    case .texto:
                        Text(mensagem.texto ?? "")
                    case .foto:
                        fotoView
                    case .audio:
                        audioView
                    }
                }
                .padding(10)
                .background(
                    ehMinha
                        ? AnyShapeStyle(AppTheme.gradienteBotao)
                        : AnyShapeStyle(Color.white.opacity(0.1)),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .foregroundStyle(.white)

                Text(Formatters.dataCurta.string(from: mensagem.data))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))
            }

            if !ehMinha { Spacer(minLength: 60) }
        }
    }

    @ViewBuilder
    private var fotoView: some View {
        if let urlString = mensagem.mediaURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                default:
                    ProgressView()
                }
            }
            .frame(maxWidth: 220, maxHeight: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var audioView: some View {
        Button {
            if let urlString = mensagem.mediaURL, let url = URL(string: urlString) {
                player.reproduzir(url: url, mensagemId: mensagem.id ?? "")
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: player.mensagemIdAtual == mensagem.id && player.reproduzindo ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
                Text("\(Int(mensagem.duracaoAudio ?? 0))s")
                    .font(.subheadline)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        FundoTecnologicoView()
        ChatView(conversa: Conversa(
            clienteId: "1",
            clienteNome: "João",
            vendedorId: "2",
            vendedorNome: "Vendedor",
            participantes: ["1", "2"]
        ), cliente: nil)
    }
    .preferredColorScheme(.dark)
}
