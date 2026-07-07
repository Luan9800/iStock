//
//  FotoPerfilView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import PhotosUI
#endif

struct FotoPerfilView: View {
    var tamanho: CGFloat = 52
    var editavel = true

    @ObservedObject private var perfil = PerfilService.shared
    @ObservedObject private var auth = AuthService.shared

    #if os(iOS)
    @State private var selectedItem: PhotosPickerItem?
    #else
    @State private var showingFileImporter = false
    #endif

    var body: some View {
        Group {
            if editavel {
                botaoFoto
            } else {
                avatar
            }
        }
        .disabled(perfil.carregandoFoto)
    }

    @ViewBuilder
    private var botaoFoto: some View {
        #if os(iOS)
        PhotosPicker(selection: $selectedItem, matching: .images) {
            avatarComBadge
        }
        .onChange(of: selectedItem) { _, item in
            Task {
                if let item,
                   let data = try? await item.loadTransferable(type: Data.self) {
                    _ = await perfil.salvarFoto(data)
                }
                selectedItem = nil
            }
        }
        #else
        Button {
            showingFileImporter = true
        } label: {
            avatarComBadge
        }
        .buttonStyle(.plain)
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.image]) { result in
            if case .success(let url) = result,
               url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url) {
                    Task { _ = await perfil.salvarFoto(data) }
                }
            }
        }
        #endif
    }

    private var avatarComBadge: some View {
        ZStack(alignment: .bottomTrailing) {
            avatar

            if editavel {
                Image(systemName: "camera.fill")
                    .font(.system(size: tamanho * 0.22))
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(AppTheme.azulPrimario, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                    .offset(x: 2, y: 2)
            }
        }
    }

    private var avatar: some View {
        Group {
            if perfil.carregandoFoto {
                ProgressView()
            } else if let urlString = perfil.fotoURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: tamanho, height: tamanho)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [AppTheme.azulClaro.opacity(0.6), AppTheme.azulPrimario.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
    }

    private var placeholder: some View {
        ZStack {
            Circle()
                .fill(AppTheme.azulPrimario.opacity(0.25))
            Text(inicialNome)
                .font(.system(size: tamanho * 0.38, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.azulClaro)
        }
    }

    private var inicialNome: String {
        String(auth.nomeOuEmail.prefix(1)).uppercased()
    }
}

struct BarraPerfilSuperiorView: View {
    @ObservedObject private var auth = AuthService.shared
    @ObservedObject private var perfil = PerfilService.shared

    var body: some View {
        HStack(spacing: 14) {
            FotoPerfilView(tamanho: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(auth.nomeOuEmail)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if auth.usandoLoginLocal {
                        BadgeAppView(texto: "Conta local", cor: .orange)
                    } else if let email = auth.emailExibicao, !email.isEmpty {
                        Text(email)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(1)
                    }

                    Text("Toque na foto para alterar")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.35))
                }
            }

            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
        .overlay(alignment: .bottomTrailing) {
            if let erro = perfil.erro {
                Text(erro)
                    .font(.caption2)
                    .foregroundStyle(.red.opacity(0.9))
                    .padding(8)
            }
        }
    }
}
