//
//  NovaAvaliacaoView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import PhotosUI
#endif

struct NovaAvaliacaoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var service = AvaliacaoService.shared
    @ObservedObject private var auth = AuthService.shared

    @State private var dados = DadosProdutoFormulario()
    @State private var fotosPendentes: [Data] = []
    @State private var salvando = false

    #if os(iOS)
    @State private var selectedItem: PhotosPickerItem?
    #else
    @State private var showingFileImporter = false
    #endif

    private let colunasFotos = [GridItem(.adaptive(minimum: 90), spacing: 10)]

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    TituloTelaView(
                        titulo: "Nova avaliação",
                        subtitulo: "Envie fotos e dados do dispositivo Apple"
                    )

                    CartaoVidroView {
                        VStack(alignment: .leading, spacing: 20) {
                            FormularioProdutoView(
                                dados: $dados,
                                criadoPor: auth.nomeOuEmail,
                                mostrarGaleria: false,
                                modoAvaliacao: true
                            )

                            secaoFotos

                            if let erro = service.erro {
                                Text(erro)
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.9))
                            }

                            BotaoPrimarioView(
                                titulo: "Enviar para avaliação",
                                desabilitado: !podeSalvar || salvando
                            ) {
                                Task { await salvar() }
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
            }
        }
        .preferredColorScheme(.dark)
        .overlay {
            if salvando {
                ProgressView("Salvando avaliação...")
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var podeSalvar: Bool {
        !dados.nome.isEmpty && !dados.telefone.isEmpty && !fotosPendentes.isEmpty
    }

    private var secaoFotos: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fotos do dispositivo")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Adicione ao menos uma foto do aparelho.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))

            LazyVGrid(columns: colunasFotos, spacing: 10) {
                ForEach(fotosPendentes.indices, id: \.self) { indice in
                    ZStack(alignment: .topTrailing) {
                        PlatformImageView(data: fotosPendentes[indice])
                            .scaledToFill()
                            .frame(height: 90)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Button {
                            fotosPendentes.remove(at: indice)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white, .red)
                        }
                        .buttonStyle(.plain)
                        .padding(4)
                    }
                }

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
                    fotosPendentes.append(data)
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
                    fotosPendentes.append(data)
                }
            }
        }
        #endif
    }

    private var labelAdicionarFoto: some View {
        VStack(spacing: 6) {
            Image(systemName: "plus")
                .font(.title3)
            Text("Foto")
                .font(.caption2)
        }
        .foregroundStyle(AppTheme.azulClaro)
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(AppTheme.azulPrimario.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                .foregroundStyle(AppTheme.azulClaro.opacity(0.5))
        }
    }

    private func salvar() async {
        salvando = true
        service.erro = nil

        var avaliacao = Avaliacao(
            tipoProduto: dados.tipoProduto,
            nome: dados.nome.trimmingCharacters(in: .whitespaces),
            modelo: dados.modelo.isEmpty ? nil : dados.modelo,
            capacidade: dados.capacidade.isEmpty ? nil : dados.capacidade,
            cor: dados.cor.isEmpty ? nil : dados.cor,
            telefone: dados.telefone,
            serial: dados.serial.isEmpty ? nil : dados.serial,
            lacrado: dados.lacrado,
            condicaoPercentual: dados.lacrado ? nil : Int(dados.condicaoPercentual),
            observacoes: dados.observacoes.isEmpty ? nil : dados.observacoes,
            fotos: [],
            status: .emAvaliacao,
            criadoPor: auth.nomeOuEmail
        )

        guard let id = service.salvarRetornandoID(avaliacao) else {
            salvando = false
            return
        }

        avaliacao.id = id
        var fotosSalvas: [FotoAvaliacao] = []

        for data in fotosPendentes {
            if let foto = await service.adicionarFoto(data, avaliacaoId: id) {
                fotosSalvas.append(foto)
            }
        }

        avaliacao.fotos = fotosSalvas
        _ = service.atualizar(avaliacao)

        salvando = false
        if service.erro == nil {
            dismiss()
        }
    }
}

#Preview {
    NovaAvaliacaoView()
}
