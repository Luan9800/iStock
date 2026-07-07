//
//  FotoPickerView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import PhotosUI
#endif

struct GaleriaModeloView: View {
    let cadastroId: String
    let tipo: TipoProduto
    let criadoPor: String?

    @ObservedObject private var service = ModeloFotoService.shared

    #if os(iOS)
    @State private var selectedItem: PhotosPickerItem?
    #else
    @State private var showingFileImporter = false
    #endif
    @State private var enviando = false
    @State private var limiteAtingido = false

    private var fotosDoCadastro: [ModeloFoto] {
        service.fotos(para: cadastroId)
    }

    private var quantidadeFotos: Int {
        service.contagem(para: cadastroId)
    }

    private var podeAdicionar: Bool {
        service.podeAdicionar(cadastroId: cadastroId)
    }

    private var contagemFotos: String {
        "\(quantidadeFotos)/\(ModeloFotoService.maxFotosPorCadastro)"
    }

    private let colunas = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fotos do cadastro")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(tipo.rawValue)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.45))
                }
                Spacer()
                Text(contagemFotos)
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(podeAdicionar ? .white.opacity(0.55) : .orange)
                if enviando {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            if !podeAdicionar {
                Text("Limite de \(ModeloFotoService.maxFotosPorCadastro) fotos atingido para este cadastro.")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            } else if fotosDoCadastro.isEmpty && !enviando {
                Text("Nenhuma foto adicionada neste cadastro.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.45))
            }

            LazyVGrid(columns: colunas, spacing: 12) {
                ForEach(fotosDoCadastro) { foto in
                    FotoModeloThumbnail(foto: foto) {
                        Task { await service.remover(foto) }
                    }
                }

                if podeAdicionar {
                    adicionarFotoButton
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
        .animation(.easeInOut(duration: 0.2), value: cadastroId)
        .animation(.easeInOut(duration: 0.2), value: quantidadeFotos)
        .alert("Limite atingido", isPresented: $limiteAtingido) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Este cadastro já possui o máximo de \(ModeloFotoService.maxFotosPorCadastro) fotos.")
        }
    }

    @ViewBuilder
    private var adicionarFotoButton: some View {
        #if os(iOS)
        PhotosPicker(selection: $selectedItem, matching: .images) {
            adicionarFotoLabel
        }
        .onChange(of: selectedItem) { _, newItem in
            Task { await carregarEEnviar(from: newItem) }
        }
        #else
        Button {
            showingFileImporter = true
        } label: {
            adicionarFotoLabel
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.image]
        ) { result in
            if case .success(let url) = result,
               url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url) {
                    Task { await enviarFoto(data) }
                }
            }
        }
        #endif
    }

    private var adicionarFotoLabel: some View {
        VStack(spacing: 6) {
            Image(systemName: "plus")
                .font(.title2)
            Text("Adicionar")
                .font(.caption)
        }
        .foregroundStyle(AppTheme.azulClaro)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(AppTheme.azulPrimario.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                .foregroundStyle(AppTheme.azulClaro.opacity(0.5))
        )
    }

    #if os(iOS)
    private func carregarEEnviar(from item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            await enviarFoto(data)
            selectedItem = nil
        }
    }
    #endif

    private func enviarFoto(_ data: Data) async {
        guard podeAdicionar else {
            limiteAtingido = true
            return
        }

        enviando = true
        let comprimida = ImageCompressor.compressJPEG(data) ?? data
        let sucesso = await service.adicionar(
            cadastroId: cadastroId,
            tipo: tipo,
            imagemData: comprimida,
            criadoPor: criadoPor
        )
        enviando = false

        if !sucesso {
            limiteAtingido = true
        }
    }
}

struct FotoModeloThumbnail: View {
    let foto: ModeloFoto
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: URL(string: foto.fotoURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                default:
                    ProgressView()
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
            }
            .buttonStyle(.plain)
            .padding(6)
        }
    }
}

struct PlatformImageView: View {
    let data: Data

    var body: some View {
        #if os(macOS)
        if let nsImage = NSImage(data: data) {
            Image(nsImage: nsImage)
                .resizable()
        }
        #else
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
        }
        #endif
    }
}
