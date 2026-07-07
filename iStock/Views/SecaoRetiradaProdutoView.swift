//
//  SecaoRetiradaProdutoView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import PhotosUI
#endif

struct SecaoRetiradaProdutoView: View {
    let avaliacao: Avaliacao
    let onRegistrar: (String, String?, String?, Data?) async -> Bool

    @State private var nomeRecebedor = ""
    @State private var documentoRecebedor = ""
    @State private var observacoes = ""
    @State private var fotoPendente: Data?
    @State private var salvando = false
    @State private var erroLocal: String?

    #if os(iOS)
    @State private var selectedItem: PhotosPickerItem?
    #else
    @State private var showingFileImporter = false
    #endif

    private var valido: Bool {
        !nomeRecebedor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        if let retirada = avaliacao.retirada {
            retiradaRegistrada(retirada)
        } else if avaliacao.status == .aprovado {
            formularioRetirada
        }
    }

    private var formularioRetirada: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Retirada do produto", systemImage: "hand.raised.fill")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Registre quem recebeu o aparelho e anexe uma foto do momento da retirada.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))

            CampoAppView(
                icone: "person.fill",
                placeholder: "Nome de quem recebeu (obrigatório)",
                texto: $nomeRecebedor
            )

            CampoAppView(
                icone: "person.text.rectangle",
                placeholder: "Documento (CPF/RG — opcional)",
                texto: $documentoRecebedor
            )

            CampoAppView(
                icone: "note.text",
                placeholder: "Observações da retirada (opcional)",
                texto: $observacoes
            )

            secaoFoto

            if let erroLocal {
                Text(erroLocal)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.9))
            }

            BotaoPrimarioView(
                titulo: "Confirmar retirada",
                desabilitado: !valido || salvando
            ) {
                Task { await confirmar() }
            }
        }
    }

    private var secaoFoto: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Foto da retirada")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))

            if let foto = fotoPendente {
                ZStack(alignment: .topTrailing) {
                    PlatformImageView(data: foto)
                        .scaledToFill()
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button {
                        fotoPendente = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white, .red)
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }
            } else {
                adicionarFotoButton
            }
        }
    }

    @ViewBuilder
    private var adicionarFotoButton: some View {
        #if os(iOS)
        PhotosPicker(selection: $selectedItem, matching: .images) {
            labelAdicionarFoto
        }
        .onChange(of: selectedItem) { _, item in
            Task {
                if let item,
                   let data = try? await item.loadTransferable(type: Data.self) {
                    fotoPendente = data
                }
                selectedItem = nil
            }
        }
        #else
        Button { showingFileImporter = true } label: {
            labelAdicionarFoto
        }
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.image]) { result in
            if case .success(let url) = result,
               url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url) {
                    fotoPendente = data
                }
            }
        }
        #endif
    }

    private var labelAdicionarFoto: some View {
        VStack(spacing: 8) {
            Image(systemName: "camera.fill")
                .font(.title3)
            Text("Anexar foto")
                .font(.caption)
        }
        .foregroundStyle(AppTheme.azulClaro)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(AppTheme.azulPrimario.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                .foregroundStyle(AppTheme.azulClaro.opacity(0.5))
        }
    }

    private func retiradaRegistrada(_ retirada: RetiradaProduto) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Retirada registrada", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.green)

            infoLinha("Recebido por", retirada.nomeRecebedor)

            if let documento = retirada.documentoRecebedor {
                infoLinha("Documento", documento)
            }

            infoLinha("Data", Formatters.dataCompleta.string(from: retirada.data))

            if let registradoPor = retirada.registradoPor {
                infoLinha("Registrado por", registradoPor)
            }

            if let obs = retirada.observacoes, !obs.isEmpty {
                Text(obs)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            if let foto = retirada.foto {
                FotoAvaliacaoThumbnail(foto: foto)
                    .frame(height: 160)
            }
        }
    }

    private func infoLinha(_ titulo: String, _ valor: String) -> some View {
        HStack {
            Text(titulo)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
            Spacer()
            Text(valor)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
    }

    private func confirmar() async {
        salvando = true
        erroLocal = nil
        defer { salvando = false }

        let doc = documentoRecebedor.trimmingCharacters(in: .whitespacesAndNewlines)
        let obs = observacoes.trimmingCharacters(in: .whitespacesAndNewlines)

        let sucesso = await onRegistrar(
            nomeRecebedor,
            doc.isEmpty ? nil : doc,
            obs.isEmpty ? nil : obs,
            fotoPendente
        )

        if !sucesso {
            erroLocal = AvaliacaoService.shared.erro ?? "Não foi possível registrar a retirada."
        }
    }
}
